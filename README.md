# gradual_stepper

A real world useful widget for selecting values in natural ways.

<img src="steppergif.gif?raw=true" width="300"/>

### Created & Maintained by

[Moustapha Chadly](https://github.com/moustaphachadly)

### Highly inspired from

- [Rahiche/stepper_touch](https://github.com/Rahiche/stepper_touch)
- [gmertk/GMStepper](https://github.com/gmertk/GMStepper)

## Usage

[Example](https://github.com/moustaphachadly/gradual_stepper/blob/develop/example/lib/main.dart)

To use this package :

* Add the dependency to your **pubspec.yaml** file.

```yaml
  dependencies:
    flutter:
      sdk: flutter
    gradual_stepper:
```

* Usage example.

```dart
import 'package:gradual_stepper/gradual_stepper.dart';
// ...
Container(
  padding: const EdgeInsets.all(8.0),
  child: GradualStepper(
    initialValue: 0,
    minimumValue: -100,
    maximumValue: 100,
    stepValue: 2,
    onChanged: (int value) => print('new value $value'),
  ),
),
// ...
```

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
