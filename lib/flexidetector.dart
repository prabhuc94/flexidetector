library flexidetector;

import 'dart:async';

import 'package:flexidetector/enumeration.dart';
import 'package:flexidetector/keboard_mouse_detector.dart';

/// [IBDetector] is detect [IDLE] / [BREAK] / [ACTIVE] based on keyboard / mouse detection
class IBDetector {
  static final IBDetector instance = IBDetector._internal();
  factory IBDetector() => instance;
  IBDetector._internal();

  final keyboardDetection = KeyboardMouseDetector();

  final StreamController<ActivityStatus> _statusStreamController = StreamController<ActivityStatus>.broadcast(sync: true);
  Stream<ActivityStatus> get statusStream => _statusStreamController.stream;

  Duration _idleDuration = const Duration(minutes: 1);
  Duration _breakDuration = const Duration(minutes: 2);

  Timer? _timer;
  ActivityStatus _currentStatus = ActivityStatus.ACTIVE;
  late DateTime _lastActivityTime;

  void startService() {
    keyboardDetection.initialize();
    keyboardDetection.listenKeyMouseEvent.listen((_) => _updateActivityTime());
    _lastActivityTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    if (_timer == null || !(_timer?.isActive ?? false)) {
      _timer = Timer(const Duration(minutes: 1), () {
        final now = DateTime.now();
        final difference = now.difference(_lastActivityTime);
        if (difference >= _breakDuration &&
            _currentStatus != ActivityStatus.ACTIVE &&
            _currentStatus != ActivityStatus.BREAK) {
          _currentStatus = ActivityStatus.BREAK;
          _streamUpdate(ActivityStatus.BREAK);
        } else if (difference >= _idleDuration &&
            _currentStatus != ActivityStatus.IDLE &&
            _currentStatus != ActivityStatus.BREAK) {
          _currentStatus = ActivityStatus.IDLE;
          _streamUpdate(ActivityStatus.IDLE);
        }
      });
    }
  }

  void _updateActivityTime() {
    _lastActivityTime = DateTime.now();
    if (_currentStatus != ActivityStatus.ACTIVE) {
      _currentStatus = ActivityStatus.ACTIVE;
      _streamUpdate(ActivityStatus.ACTIVE);
    }
  }

  void _streamUpdate(ActivityStatus status) {
    if (_statusStreamController.isPaused) {
      _statusStreamController.onResume;
    }
    _statusStreamController.add(status);
  }

  set breakDuration(Duration value) => _breakDuration = value;
  set idleDuration(Duration value) => _idleDuration = value;

  void dispose() {
    _timer?.cancel();
    _statusStreamController.close();
  }
}
