import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hid_listener/hid_listener.dart';

class KeyboardMouseDetector {

  static final KeyboardMouseDetector _instance = KeyboardMouseDetector._internal();
  factory KeyboardMouseDetector () => _instance;
  KeyboardMouseDetector._internal();

  int? _keyboardId, _mouseId;

  final _streamKeyboard = StreamController<RawKeyEvent>.broadcast(sync: true);
  final _streamMouse = StreamController<MouseEvent>.broadcast(sync: true);
  final _keyMouseDetection = StreamController<dynamic>.broadcast(sync: true);
  ValueNotifier<bool> isKeyboardMouseActive = ValueNotifier(false);

  Stream<MouseEvent> get mouseDetection => _streamMouse.stream;
  Stream<RawKeyEvent> get keyBoardDetection => _streamKeyboard.stream;
  Stream<dynamic> get listenKeyMouseEvent => _keyMouseDetection.stream;

  Future<KeyboardMouseDetector> initialize() async {
    if (getListenerBackend()?.initialize() == false) {
      throw Exception("Failed to initialize listener backend");
    }
    _keyboardId ??= getListenerBackend()?.addKeyboardListener((key) { _updateNotifier(true); _setKeyboardDetection(key); });
    _mouseId ??= getListenerBackend()?.addMouseListener((mouse) { _updateNotifier(true);  _setMouseDetection(mouse); });

    if (_keyboardId == null || _mouseId == null) {
      _setError("Keyboard / Mouse detection failed");
    } else {
      if (kDebugMode) {
        print("Keyboard / Mouse Detection successfully!");
      }
    }
    return this;
  }

  void _setKeyboardDetection(RawKeyEvent event) {
    _keyMouseDetection.sink.add(event);
    _streamKeyboard.sink.add(event);
  }

  void _setMouseDetection(MouseEvent event) {
    _keyMouseDetection.sink.add(event);
    _streamMouse.sink.add(event);
  }

  void _setError(String error) {
    _streamKeyboard.sink.addError(error);
    _streamMouse.sink.addError(error);
    _keyMouseDetection.sink.addError(error);
    _updateNotifier(false);
  }

  void _updateNotifier(bool status) {
    if (isKeyboardMouseActive.value != status) {
      if (kDebugMode) {
        print("Keyboard / Mouse detection started");
      }
      isKeyboardMouseActive.value = status;
    }
  }

  void dispose() {
    _streamKeyboard.close();
    _streamMouse.close();
    _keyMouseDetection.close();
  }
}