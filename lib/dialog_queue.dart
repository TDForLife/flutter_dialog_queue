library dialog_queue;

import 'dart:async';
import 'package:dialog_queue/dialog_queue_element.dart';
import 'package:flutter/material.dart';

class DialogQueueRouteObserver extends RouteObserver {
  Route<dynamic>? _pushRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _pushRoute = route;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (DialogQueue.instance.isShowing) {
      DialogQueue.instance.handlePushRemoveEvent(_pushRoute);
    }
  }

}

class DialogQueue {
  // 请求队列
  final Map<DialogQueueElement, Completer> _dialogQueue = {};
  List<DialogQueueElement> _sortedKeys = [];

  // 构建单例
  static final DialogQueue _instance = DialogQueue._();
  static DialogQueue get instance => _instance;
  DialogQueue._();

  // 对话框状态
  bool _isShowing = false;
  @protected
  bool get isShowing => _isShowing;
  Completer? _currentCompleter;

  // 队列状态
  bool _isActive = true;
  bool get isActive => _isActive;

  // 外部回调
  Function(Route<dynamic>? pushRoute)? _onPushRemovedEvent;

  set onPushRemovedEvent(Function(Route<dynamic>? pushRoute) function) {
    _onPushRemovedEvent = function;
  }

  @protected
  handlePushRemoveEvent(Route<dynamic>? pushRoute) {
    // 取消展示的对话框
    _isShowing = false;
    _currentCompleter?.complete();
    _currentCompleter = null;
    // 尝试将异常中断告知业务方，让其决定 DialogQueue 的行为，否则执行默认行为
    Future.delayed(Duration.zero, () {
      if (_onPushRemovedEvent != null) {
        _onPushRemovedEvent?.call(pushRoute);
      } else {
        resume();
      }
    });
  }

  Future<T?> addDialog<T>(DialogQueueElement dialog) {
    // 入列前查重，直接替换已存在的并复用与之对应的 Completer
    List<DialogQueueElement> keyList = _dialogQueue.keys.cast<DialogQueueElement>().toList();
    int existIndex = keyList.indexOf(dialog);
    if (existIndex >= 0) {
      DialogQueueElement currentDialog = keyList.elementAt(existIndex);
      Completer<T?> existCompleter = _dialogQueue[currentDialog] as Completer<T?>;
      // 更新对话框
      currentDialog.update(dialog);
      // 更新排序
      _sortQueue();
      return existCompleter.future;
    }
    Completer<T?> dialogCompleter = Completer();
    _dialogQueue[dialog] = dialogCompleter;
    // 按优先级排序
    _sortQueue();
    // 弹出最近对话框
    _showNext();
    return dialogCompleter.future;
  }

  _sortQueue() {
    _sortedKeys = _dialogQueue.keys.toList();
    _sortedKeys.sort((a, b) {
      if (a.priority > b.priority) {
        return -1;
      } else if (a.priority < b.priority) {
        return 1;
      }
      return 0;
    });
  }

  _showNext() {
    if (!_isActive) {
      return;
    }
    if (!_isShowing && _dialogQueue.isNotEmpty) {
      _isShowing = true;
      DialogQueueElement nextDialog = _sortedKeys.first;
      _currentCompleter = _dialogQueue[nextDialog];
      _dialogQueue.remove(nextDialog);
      _sortedKeys.remove(nextDialog);
      nextDialog.showDialog().then((value) {
        _currentCompleter?.complete(value);
        _currentCompleter = null;
        // 继续下一个弹框
        _isShowing = false;
        _showNext();
      });
    }
  }

  resume() {
    _isActive = true;
    _showNext();
  }

  pause() {
    _isActive = false;
  }

  Future<T?> pushThenResume<T extends Object?, TO extends Object?>(NavigatorState navigator, Route<dynamic> pushRoute, [TO? result,]) async {
    pause();
    navigator.pop(result);
    Completer<T> completer = Completer();
    unawaited(navigator.push(pushRoute).then((value) {
      resume();
      completer.complete(value);
    }));
    return completer.future;
  }

  Future<T?> pushNameThenResume<T extends Object?, TO extends Object?>(
      NavigatorState navigator,
      String pushName, {
        TO? result,
        Object? arguments,
      }) async {
    pause();
    navigator.pop(result);
    Completer<T?> completer = Completer();
    unawaited(navigator.pushNamed<T>(pushName, arguments: arguments).then((value) {
      resume();
      completer.complete(value);
    }));
    return completer.future;
  }

  clear() {
    _isActive = true;
    _isShowing = false;
    for (var completer in _dialogQueue.values) {
      completer.complete();
    }
    _sortedKeys.clear();
    _dialogQueue.clear();
    _currentCompleter = null;
  }
}
