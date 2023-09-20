# flexidetector

I've created this library with the help of `HidListener library that allows you to listen to hid events cross-platform`. 
So kindly add these necessary lines with respective places.


## Windows

Add this into your `main.cpp` file

```cpp
#include <hid_listener/hid_listener_plugin_windows.h>
```

and add this inside `wWinMain` function

```cpp
HidListener listener;
```

## MacOS

Add this into your `MainFlutterWindow.swift` file

```swift
import hid_listener
```

and add this inside `MainFlutterWindow` class

```swift
let listener = HidListener()
```

The file should now look something like this:

```swift
...
import hid_listener

class MainFlutterWindow: NSWindow {
  let listener = HidListener()
...
```

## Linux

Add this into your `main.cc` file

```cpp
#include <hid_listener/hid_listener_plugin.h>
```

and add this inside `main` funciton

```cpp
HidListener listener;
```

## Dart
To use the `IBDetector` kindly follow add the necessary values

```dart
ibDetector.idleDuration = Duration(minutes: 1);
ibDetector.breakDuration = Duration(minutes: 2);
ibDetector.statusStream.listen((event) {
if (kDebugMode) {
print("STATUS[${DateTime.now().toLocal().time}]:\t${event.name}");
}
});```

