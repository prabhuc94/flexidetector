import 'dart:async';
import 'package:flexidetector/alertdetectionmodel.dart';
import 'package:flexidetector/enumeration.dart';
import 'package:flexidetector/keboard_mouse_detector.dart';
import 'package:flutter/foundation.dart';

class AlertDetector {

  static final AlertDetector instance = AlertDetector._internal();
  factory AlertDetector() => instance;
  AlertDetector._internal();

  DateTime _lastActivityTime = DateTime.now();
  DateTime _lastWorkTime = DateTime.now();
  DateTime _currentDateTime = DateTime.now();

  Duration _idleDuration = const Duration(minutes: 1);
  Duration _privateDuration = const Duration(minutes: 1);
  Duration _currentAccountDuration = const Duration(minutes: 4);
  Duration _workingDuration = const Duration(minutes: 5);

  int? _oldAccount, _currentAccount;

  final ValueNotifier<AlertDetectionModel> onChange = ValueNotifier(AlertDetectionModel());
  final ValueNotifier<DateTime> currentDateNotifier = ValueNotifier(DateTime.now());
  int _currentCount = 0, _newCurrentCount = 0;
  int _workCount = 0, _newWorkCount = 0;
  int _privateCount = 0, _newPrivateCount = 0;
  bool _disableIDLE = false, _disableWork = false, _disableCurrent = false, _disablePrivate = false;
  bool _isActive = false;

  Timer? _timer;

  void initialize() {
    keyboardMouseDetector.listenKeyMouseEvent.listen((_) => _updateActivityTime());
    _lastActivityTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    if ((_timer == null) || (_timer?.isActive == false)) {
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _updateCurrentDateTime(); // UPDATE CURRENT DATE
        final now = DateTime.now();
        final difference = now.difference(_lastActivityTime);
        if (_disableIDLE == false && _idleDuration.inMinutes != 0 && _isActive) {
          if (difference >= _idleDuration) {
            _resetWorkCount();
            onChange.value = AlertDetectionModel(
                status: ActivityStatus.IDLE, minute: difference.inMinutes);
          }
        }

        if (_disableCurrent == false && _currentAccountDuration.inMinutes != 0) {
          _currentCount++;
          if (_currentCount == _currentAccountDuration.inMinutes ||
              _newCurrentCount == _currentCount) {
            _newCurrentCount = _currentCount + _currentAccountDuration.inMinutes;
            if (_currentAccount == null || _oldAccount == null ||
                (_oldAccount == _currentAccount)) {
              _oldAccount = _currentAccount;
              onChange.value = AlertDetectionModel(status: ActivityStatus.CURRENT, minute: _currentCount);
            }
          }
        }

        if (_disableWork == false && _workingDuration.inMinutes != 0 && _isActive) {
          _workCount++;
          var workDifference = DateTime.now().difference(_lastWorkTime);
          if (_workCount == _workingDuration.inMinutes || _newWorkCount == _workCount) {
            _newWorkCount = _workCount + _workingDuration.inMinutes;
            if ((workDifference.inMinutes <= _workingDuration.inMinutes) && _isActive) {
              if (onChange.value.minute != _workCount || onChange.value.status != ActivityStatus.WORK) {
                onChange.value = AlertDetectionModel(
                    status: ActivityStatus.WORK,
                    minute: _workCount);
              }
            } else {
              _resetWorkCount();
            }
          }
        } else {
          _resetWorkCount();
        }
        if (_disablePrivate == false && _privateDuration.inMinutes != 0 && !_isActive) {
          _privateCount++;
          if (_privateCount == _privateDuration.inMinutes || _newPrivateCount == _privateCount) {
            _newPrivateCount = _privateCount + _privateDuration.inMinutes;
            onChange.value = AlertDetectionModel(status: ActivityStatus.PRIVATE, minute: _privateCount);
          }
        }
      });
    }
  }

  void _updateCurrentDateTime() {
    if (currentDateNotifier.value != _currentDateTime || _currentDateTime != DateTime.now()) {
      _currentDateTime = DateTime.now();
      currentDateNotifier.value = _currentDateTime;
    }
  }

  void _updateActivityTime() {
    _lastActivityTime = DateTime.now();
    _lastWorkTime = DateTime.now();
  }

  set workingDuration(Duration value) {
    _workingDuration = value;
    _disableWork = (value.inMinutes <= 0);
    _resetWorkCount();
  }

  set currentAccountDuration(Duration value) {
    _currentAccountDuration = value;
    _disableCurrent = (value.inMinutes <= 0);
    _resetCurrentCount();
  }

  set privateDuration(Duration value) {
    _privateDuration = value;
    _disablePrivate = _isActive;
    _resetPrivateCount();
  }

  set idleDuration(Duration value) {
    _idleDuration = value;
    _disableIDLE = (value.inMinutes <= 0);
  }


  set isActive(bool value) => _isActive = value;

  void _resetWorkCount() {
    _workCount = 0;
    _newWorkCount = 0;
  }

  void _resetCurrentCount() {
    _currentCount = 0;
    _newCurrentCount = 0;
  }

  void _resetPrivateCount() {
    _privateCount = 0;
    _newPrivateCount = 0;
  }

  set disablePrivate(value) {
    _disablePrivate = value;
    _resetPrivateCount();
    _resetWorkCount();
  }

  set currentAccount(int? accountId) {
    if (_currentAccount == null && _oldAccount == null) {
      _currentAccount = accountId;
      _oldAccount = _currentAccount;
    } else {
      if (_oldAccount != accountId) {
        _oldAccount = _currentAccount;
        _currentAccount = accountId;
      }
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}