// TODO: Add velocity speed.
// TODO: Add auto repeat option.
// TODO: Use dynamic width for counter.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Default widget height.
const double kStepperHeight = 44.0;

/// Drag distance to reach to fire an action.
const double kStepDistance = 0.1;

/// Amount of time for animations.
const Duration kAnimationDuration = Duration(milliseconds: 300);

/// Determines the draggable counter state.
enum StepperState { stable, shouldIncrease, shouldDecrease }

/// The concept of the widget highly inspired
/// from [Rahiche/stepper_touch](https://github.com/Rahiche/stepper_touch)
/// and [gmertk/GMStepper](https://github.com/gmertk/GMStepper).
class GradualStepper extends StatefulWidget {
  const GradualStepper({
    Key key,
    this.initialValue = 0,
    this.minimumValue,
    this.maximumValue,
    this.stepValue = 1,
    this.onChanged,
    this.locale,
    this.elevation = 0.0,
    this.cornerRadius = kStepperHeight / 2,
    this.backgroundColor = Colors.grey,
    this.buttonsColor = Colors.white,
    this.counterElevation = 5.0,
    this.counterCornerRadius = kStepperHeight / 2,
    this.counterBackgroundColor = Colors.white,
    this.counterTextStyle = const TextStyle(
      fontSize: 24,
    ),
  })  : assert(initialValue != null),
        assert(minimumValue == null || minimumValue <= initialValue),
        assert(maximumValue == null || maximumValue >= initialValue),
        assert(stepValue != null && stepValue > 0),
        assert(elevation != null && elevation >= 0.0),
        assert(cornerRadius != null && cornerRadius >= 0.0),
        assert(counterElevation != null && counterElevation >= 0.0),
        assert(counterCornerRadius != null && counterCornerRadius >= 0.0),
        super(key: key);

  /// The first displaying value of the stepper.
  /// Defaults to 0.
  final int initialValue;

  /// The smallest value the counter can reach.
  /// Must be less than maximumValue.
  /// Restricted to [dart:core] int representation.
  final int minimumValue;

  /// The greatest value the counter can reach.
  /// Must be more than minimumValue.
  /// Restricted to [dart:core] int representation.
  final int maximumValue;

  /// The value added or subtracted when increasing or decreasing.
  /// Defaults to 1.
  final int stepValue;

  /// Called whenever the value of the stepper changed.
  final ValueChanged<int> onChanged;

  /// Locale for thousands separator.
  /// If the locale is not specified it will print in a basic format
  /// of one integer with no fraction digits.
  final String locale;

  /// The size of the shadow below the stepper.
  /// Defaults to 0.
  final double elevation;

  /// The corner radius of the stepper's layer.
  /// Defaults to 22.0 (half of default height).
  final double cornerRadius;

  /// Background color of the stepper's layer.
  /// Defaults to [Colors.grey].
  final Color backgroundColor;

  /// Text color of the buttons.
  /// Defaults to [Colors.white].
  final Color buttonsColor;

  /// The size of the shadow below the counter.
  /// Defaults to 5.
  final double counterElevation;

  /// The corner radius of the counter's layer.
  /// Defaults to 22.0 (half of default height).
  final double counterCornerRadius;

  /// Text color of the counter drag button.
  /// Defaults to [Colors.white].
  final Color counterBackgroundColor;

  /// Text style of the counter label. Defaults to
  /// ```dart
  /// TextStyle(
  ///   fontSize: 24,
  /// ).
  final TextStyle counterTextStyle;

  @override
  _Stepper2State createState() => _Stepper2State();
}

class _Stepper2State extends State<GradualStepper>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  StepperState _stepperState;
  NumberFormat _formatter;
  int _value;
  int _minimum;
  int _maximum;

  /// Timer used for auto repeat option.
  Timer timer;

  /// When the stepper reaches its top speed, it alters the value
  /// with a time interval of ~0.05 sec.
  ///
  /// The user pressing and holding on the stepper repeatedly:
  /// * First 2.5 sec, the stepper changes the value every 0.5 sec.
  /// * For the next 1.5 sec, it changes the value every 0.1 sec.
  /// * Then, every 0.05 sec.
  final int timerInterval = 50; // 50 milliseconds = 0.05 sec

  /// Check the timerCallback: function.
  /// While it is counting the number of fires,
  /// it decreases the mod value so that the value is altered more frequently.
  int timerFireCount = 0;
  int get timerFireCountModulo {
    if (timerFireCount > 80) {
      return 1; // 0.05 sec * 1 = 0.05 sec
    } else if (timerFireCount > 50) {
      return 2; // 0.05 sec * 2 = 0.1 sec
    } else {
      return 10; // 0.05 sec * 10 = 0.5 sec
    }
  }

  bool get _canIncrease =>
      (widget.maximumValue == null) ||
      (widget.maximumValue >= _value + widget.stepValue);
  bool get _canDecrease =>
      (widget.minimumValue == null) ||
      (widget.minimumValue <= _value - widget.stepValue);

  String get _formattedValue {
    return (_formatter != null) ? _formatter.format(_value) : '$_value';
  }

  set value(int newValue) {
    setState(() => _value = newValue);

    if (widget.onChanged != null) {
      widget.onChanged(_value);
    }
  }

  set state(StepperState state) {
    _stepperState = state;

    if (_stepperState != StepperState.stable) {
      _updateValue();
      _scheduleTimer();
    }
  }

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _stepperState = StepperState.stable;
    _controller = AnimationController(
      vsync: this,
      lowerBound: -0.5,
      upperBound: 0.5,
    )..value = 0;
    _animation = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(1.5, 0.0))
        .animate(_controller);

    if (widget.locale != null) {
      _formatter = NumberFormat.decimalPattern(widget.locale);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kStepperHeight,
      child: Material(
        type: MaterialType.canvas,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(widget.cornerRadius),
        color: widget.backgroundColor,
        elevation: widget.elevation,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              left: 10.0,
              child: IgnorePointer(
                ignoring: !_canDecrease,
                child: Listener(
                  onPointerDown: _leftButtonPointerDown,
                  onPointerUp: _buttonPointerUp,
                  child: IconButton(
                    icon: Icon(
                      Icons.remove,
                      size: 25.0,
                      color: widget.buttonsColor,
                    ),
                    onPressed: _canDecrease ? () {} : null,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10.0,
              child: IgnorePointer(
                ignoring: !_canIncrease,
                child: Listener(
                  onPointerDown: _rightButtonPointerDown,
                  onPointerUp: _buttonPointerUp,
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 25.0,
                      color: widget.buttonsColor,
                    ),
                    onPressed: _canIncrease ? () {} : null,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onHorizontalDragStart: _onPanStart,
              onHorizontalDragUpdate: _onPanUpdate,
              onHorizontalDragEnd: _onPanEnd,
              child: SlideTransition(
                position: _animation,
                child: FractionallySizedBox(
                  widthFactor: 2 / 5,
                  child: Material(
                    color: widget.counterBackgroundColor,
                    borderRadius:
                        BorderRadius.circular(widget.counterCornerRadius),
                    elevation: widget.counterElevation,
                    child: Center(
                      child: Text(
                        _formattedValue,
                        key: ValueKey<int>(_value),
                        style: widget.counterTextStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateValue() {
    final oldValue = _value;
    int newValue = oldValue;

    if (_stepperState == StepperState.shouldIncrease) {
      if (_canIncrease) {
        newValue = oldValue + widget.stepValue;
      } else {
        // TODO: Handle max limit, show toast maybe.
        _resetTimer();
      }
    } else if (_stepperState == StepperState.shouldDecrease) {
      if (_canDecrease) {
        newValue = oldValue - widget.stepValue;
      } else {
        // TODO: Handle min limit, show toast maybe.
        _resetTimer();
      }
    }

    if (oldValue != newValue) {
      value = newValue;
    }
  }

  void _resetTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
      timerFireCount = 0;
    }
  }

  void _reset() {
    state = StepperState.stable;
    _resetTimer();
  }

  void _scheduleTimer() {
    timer =
        Timer.periodic(Duration(milliseconds: timerInterval), _timerCallback);
  }

  void _timerCallback(Timer timer) {
    timerFireCount++;

    if (timerFireCount % timerFireCountModulo == 0) {
      _updateValue();
    }
  }

  /// Buttons events

  void _rightButtonPointerDown(PointerDownEvent event) {
    _resetTimer();
    state = StepperState.shouldIncrease;
  }

  void _leftButtonPointerDown(PointerDownEvent event) {
    _resetTimer();
    state = StepperState.shouldDecrease;
  }

  void _buttonPointerUp(PointerUpEvent event) {
    _reset();
  }

  /// Swipe gesture events

  /// Returns a value used to snap counter position in limitation conditions.
  ///
  /// * If decreasing and counter value reaches min, returns snap value.
  /// * If increasing and counter value reaches max, returns snap value.
  /// * Otherwise returns 1 and counter position follows drag.
  double snapDividerFrom(double offset) {
    final snap =
        (offset.isNegative && !_canDecrease) || (offset >= 0 && !_canIncrease);
    return (_stepperState == StepperState.stable && snap) ? 5 : 1;
  }

  double offsetFromGlobalPos(Offset globalPosition) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(globalPosition);
    final offset = ((local.dx * 0.75) / box.size.width) - 0.4;
    final divider = snapDividerFrom(offset);
    return offset / divider;
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    _controller.value = offsetFromGlobalPos(details.globalPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _controller.value = offsetFromGlobalPos(details.globalPosition);

    if (_controller.value.abs() <= kStepDistance) {
      if (timer != null) {
        _reset();
      }
      return;
    } else if (timer == null) {
      _resetTimer();

      if (_value == _minimum && _controller.value.isNegative) {
        // limit
        // Show toast maybe
      } else if (_value == _maximum && !_controller.value.isNegative) {
        // limit
        // Show toast maybe
      } else {
        state = (_controller.value.isNegative)
            ? StepperState.shouldDecrease
            : StepperState.shouldIncrease;
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _reset();
    _controller.stop();
    _controller.animateTo(0.0,
        curve: Curves.bounceOut, duration: kAnimationDuration);
  }
}
