A dialog queue for you to manage your dialogs to display on flutter platform

[中文](https://github.com/TDForLife/flutter_dialog_queue/blob/main/README_CN.md)

## Features

- **Support pop dialog orderly**
- **Support pop dialog by priority**
- **Support deduplicate dialog in the queue**
- **Support pause \ resume the pop action**

&emsp;&emsp;![queue-effect.gif](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/adadc7f36b674fdc8874d353deada169~tplv-k3u1fbpfcp-watermark.image?)

## Getting started

Installation

Add the following lines to pubspec.yaml on your app module. Then run flutter pub get.

```yaml
dependencies:
  dialog_queue: ">=1.0.1"
  ...
```

## Usage

**Step 1** : Add DialogQueueRouteObserver in your MaterialApp

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
**Step 2** : Replace "showDialog" with DialogQueue.instance.addDialog

Old usage

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

New usage

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

## Other usage

1. You can pause \ resume the pop action of queue at any time 

```dart
DialogQueue.instance.resume();
DialogQueue.instance.pause();
```

2. If you want to break off the queue when route to PageB，and resume it after PageA popped, then you can use:

```dart
DialogQueue.instance.pushNameThenResume(navigatorState, PageB);
```
![auto-resume-effect.gif](https://cstore-public.seewo.com/picbook-public/43c976e90440474095a96aacd1557a5f)
