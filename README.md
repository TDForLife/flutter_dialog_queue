A dialog queue for you to manage your dialogs to display on flutter platform

## Features

- **Support pop dialog orderly**
- **Support pop dialog by priority**
- **Support deduplicate dialog in the queue**
- **Support pause / resume the pop action**

## Getting started

Installation

Add the following lines to pubspec.yaml on your app module. Then run flutter pub get.

```yaml
dependencies:
  dialog_queue: ">=1.0.0"
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
    return _showModalBottomSheet(
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