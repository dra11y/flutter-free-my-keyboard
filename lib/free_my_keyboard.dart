import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Avoids Flutter bug in deprecated [KeyEventManager.handleKeyData] causing the app
/// to not respond to keyboard events if a modifier key is pressed during startup.
///
/// A symptom of the bug is the following console error message during `flutter run`:
/// ```
/// [ERROR:flutter/runtime/dart_vm_initializer.cc(41)]
/// Unhandled Exception: 'package:flutter/src/services/hardware_keyboard.dart':
/// Failed assertion: line 509 pos 16: '!_pressedKeys.containsKey(event.physicalKey)':
/// A KeyDownEvent is dispatched, but the state shows that the physical key is already
/// pressed. If this occurs in real application, please report this bug to Flutter.
/// If this occurs in unit tests, please ensure that simulated events follow Flutter's
/// event model as documented in `HardwareKeyboard`. This was the event: KeyDownEvent...
/// ... [followed by the key event details].
///
/// #0      _AssertionError._doThrowNew (dart:core-patch/errors_patch.dart:50:61)
/// #1      _AssertionError._throwNew (dart:core-patch/errors_patch.dart:40:5)
/// #2      HardwareKeyboard._assertEventIsRegular.<anonymous closure> (package:flutter/src/services/hardware_keyboard.dart:509:16)
/// #3      HardwareKeyboard._assertEventIsRegular (package:flutter/src/services/hardware_keyboard.dart:524:6)
/// #4      HardwareKeyboard.handleKeyEvent (package:flutter/src/services/hardware_keyboard.dart:646:5)
/// #5      KeyEventManager.handleKeyData (package:flutter/src/services/hardware_keyboard.dart:1087:29)
/// ...
/// ```
///
/// This function works around the bug by overriding the [PlatformDispatcher.onKeyData]
/// event to avoid the deprecated and faulty [KeyEventManager.handleKeyData] method
/// where the assertion is thrown. The replacement method returns `true` (handled)
/// during app initialization, and `false` thereafter.
///
/// Hopefully this issue will be fixed soon and this plugin will become obsolete.
///
/// Usage:
/// ```dart
/// void main() {
///   freeMyKeyboard();
///   runApp(const MainApp());
/// }
/// ```
void freeMyKeyboard() {
  PlatformDispatcher.instance.onKeyData = _onKeyData;
  WidgetsFlutterBinding.ensureInitialized();
  HardwareKeyboard.instance.syncKeyboardState().then((_) {
    // Flutter resets the callback after `syncKeyboardState`.
    PlatformDispatcher.instance.onKeyData = _onKeyData;
  });
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // After the first frame, allow all key events to pass through.
    _initialized = true;
  });
}

bool _initialized = false;

bool _onKeyData(KeyData data) {
  if (!_initialized) {
    debugPrint("Ignoring keyboard event during initialization: $data");
    // Tell Flutter the event was handled.
    return true;
  }

  // Allow Flutter to continue handling the event.
  return false;
}
