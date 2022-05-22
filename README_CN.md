基于 Flutter 的弹窗队列

[掘金 · 实现过程](https://juejin.cn/post/7099834211418243103/)

## 功能特性

- **支持按序弹框**
- **支持按优先级弹框**
- **支持队列中对话框去重**
- **支持暂停 \ 恢复队列弹框**

&emsp;&emsp;![co0aq-4ahs2.gif](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/adadc7f36b674fdc8874d353deada169~tplv-k3u1fbpfcp-watermark.image?)

## 快速上手 

安装

往 pubspec.yaml 添加下述依赖，并执行 flutter pub get.

```yaml
dependencies:
  dialog_queue: ">=1.0.1"
  ...
```

## 如何使用

**Step 1** : 在你的 MaterialApp 的 navigatorObservers 添加 DialogQueueRouteObserver 实例

```dart

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [DialogQueueRouteObserver()],
    );
  }
}

```
**Step 2** : 将业务中执行弹框的地方，替换为 DialogQueue.instance.addDialog

原用法：

```dart
showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    isDismissible: false,
    builder: (BuildContext context) {
      return SafeArea(child: Text('Hello DialogQueue'));
    },
  );
```

现用法：

```dart
DialogQueue.instance.addDialog(DialogQueueElement(() {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        isDismissible: false,
        builder: (BuildContext context) {
            return SafeArea(child: Text('Hello DialogQueue'));
        }
    );
}, tag: tag, priority: priority, uniqueKey: uniqueKey));
```

## 其他用法

1. 在任意时候可以暂停 \ 恢复弹框队列的工作

```dart
DialogQueue.instance.resume();
DialogQueue.instance.pause();
```

2. 暂停弹窗队列，跳转到 PageB，并希望在 PageB pop 的时候恢复弹窗队列的工作

```dart
DialogQueue.instance.pushNameThenResume(navigatorState, PageB);
```

![auto-resume-effect.gif](https://cstore-public.seewo.com/picbook-public/43c976e90440474095a96aacd1557a5f)
