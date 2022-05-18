import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

const defaultPriority = 0;

typedef onShow<T> = Future<T?> Function();

class DialogQueueElement<T> extends Equatable {
  onShow<T> _show;
  late int? _priority;
  late String? _uniqueKey;
  late String? _tag;
  late String _uuid;

  DialogQueueElement(
    this._show, {
    int? priority = defaultPriority,
    String? uniqueKey,
    String? tag,
  }) {
    _uuid = const Uuid().v1();
    _priority = priority;
    _uniqueKey = uniqueKey ?? _uuid;
    _tag = tag;
  }

  int get priority => _priority ?? defaultPriority;

  update(DialogQueueElement<T>? dialog) {
    if (dialog == null) {
      return;
    }
    _show = dialog._show;
    _priority = dialog._priority ?? _priority;
    _uniqueKey = dialog._uniqueKey ?? _uniqueKey;
    _tag = dialog._tag ?? _tag;
  }

  Future<T?> showDialog() {
    return _show.call();
  }

  @override
  String toString() {
    return 'DialogQueueElement { tag : $_tag, priority : $_priority, uniqueKey : $_uniqueKey }';
  }

  @override
  List<Object?> get props => [_uniqueKey];
}
