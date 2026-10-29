import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/features/arrowbox/arrowbox_board_widgets.dart';
import 'package:locate/features/arrowbox/arrowbox_screen.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrow_designs/arrow_designs.dart';

// Robust Fake for testing serialization and failures
class AuditFakePrefs implements SharedPreferences {
  final Map<String, Object> _data = {};
  Completer<void>? nextWriteCompleter;
  bool failNextWrite = false;

  Future<void> _handleWrite(String key, Object value) async {
    if (nextWriteCompleter != null) await nextWriteCompleter!.future;
    if (failNextWrite) {
      failNextWrite = false;
      throw Exception('Simulated persistence failure');
    }
    _data[key] = value;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    await _handleWrite(key, value);
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    await _handleWrite(key, value);
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    await _handleWrite(key, value);
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    await _handleWrite(key, value);
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    await _handleWrite(key, value);
    return true;
  }

  @override
  bool? getBool(String key) => _data[key] as bool?;
  @override
  double? getDouble(String key) => _data[key] as double?;
  @override
  int? getInt(String key) => _data[key] as int?;
  @override
  String? getString(String key) => _data[key] as String?;
  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;

  @override
  Future<bool> remove(String key) async {
    if (nextWriteCompleter != null) await nextWriteCompleter!.future;
    if (failNextWrite) {
      failNextWrite = false;
      throw Exception('Simulated persistence failure');
    }
    _data.remove(key);
    return true;
  }

  @override
  bool containsKey(String key) => _data.containsKey(key);
  @override
  Set<String> getKeys() => _data.keys.toSet();
  @override
  Object? get(String key) => _data[key];
  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }
  @override
  Future<bool> commit() async => true;
  @override
  Future<void> reload() async {}
}

void main() {
  late AuditFakePrefs fakePrefs;
  late AppStore store;

  setUp(() {
    fakePrefs = AuditFakePrefs();
    store = AppStore.forTesting(fakePrefs);
  });

  group('AppStore Persistence Audit', () {
    test('resetSettings ordering and serialization', () async {
      // 1. Queue an update that we will delay
      fakePrefs.nextWriteCompleter = Completer<void>();
      final firstUpdate = store.setBool('soundEnabled', false);

      // 2. Queue resetSettings
      final reset = store.resetSettings();

      // 3. Queue another update
      final secondUpdate = store.setBool('hapticsEnabled', false);

      // Release the first write
      fakePrefs.nextWriteCompleter!.complete();

      await Future.wait([firstUpdate, reset, secondUpdate]);

      // Verify final state: soundEnabled should be true (from reset),
      // hapticsEnabled should be false (from second update).
      expect(store.soundEnabled, isTrue, reason: 'Reset should have overwritten the first update');
      expect(store.hapticsEnabled, isFalse, reason: 'Second update should have happened after reset');

      // Verify persisted state
      expect(fakePrefs.getBool('soundEnabled'), isNull, reason: 'Reset should have removed the key');
      expect(fakePrefs.getBool('hapticsEnabled'), isFalse);
    });

    test('write queue failure recovery', () async {
      // 1. Make the next write fail
      fakePrefs.failNextWrite = true;
      final failedWrite = store.setBool('soundEnabled', false);

      // 2. Queue a second successful write
      final successfulWrite = store.setBool('hapticsEnabled', false);

      // The first one should fail but not crash the app (it's caught in _enqueueWrite)
      await failedWrite.catchError((_) => true);
      await successfulWrite;

      // Verify the queue continued and the second write succeeded
      expect(store.hapticsEnabled, isFalse);
      expect(fakePrefs.getBool('hapticsEnabled'), isFalse);
    });

    test('Reload restores defaults after reset', () async {
      await store.setBool('soundEnabled', false);
      await store.resetSettings();

      // Simulate a fresh load
      final newStore = AppStore.forTesting(fakePrefs);
      expect(newStore.soundEnabled, isTrue);
    });
  });

  group('ArrowBox Animation Audit', () {
    testWidgets('animation ID prevents premature removal after undo and re-tap', (tester) async {
      // Build ArrowBoxScreen
      final game = ArrowBoxState.initial(level: 1);
      await tester.pumpWidget(MaterialApp(
        home: ArrowBoxScreen(
          store: store,
          initialState: game,
        ),
      ));

      // 1. Tap an arrow to start exit animation
      await tester.tap(find.byType(GradientArrowTile).first);
      await tester.pump(); // Start animation

      // 2. Tap Undo immediately
      await tester.tap(find.text('Undo'));
      await tester.pump();

      // 3. Tap the same arrow again
      await tester.tap(find.byType(GradientArrowTile).first);
      await tester.pump();

      // Now we have two animation callbacks scheduled for the same cell index.
      // The first one should have a different ID than the second one.

      // 4. Wait for the FIRST animation's duration (e.g. 320ms)
      // but NOT long enough for the second one to finish if it started later.
      await tester.pump(const Duration(milliseconds: 300));

      // If the bug existed, the first callback would have removed the second
      // animation record from _exiting, and we'd see an EmptyBoardCell
      // or the tile would disappear/snap.

      // We check that the GradientArrowTile with isEscaping: true still exists
      expect(find.byWidgetPredicate((w) => w is GradientArrowTile && w.isEscaping), findsOneWidget);
    });
  });
}
