import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as v_math;

typedef OnChange = void Function(int index);

class ReviewSlider extends StatefulWidget {
  const ReviewSlider({
    Key? key,
    required this.onChange,
    this.initialValue = 2,
    this.options = const ['Terrible', 'Bad', 'Okay', 'Good', 'Great'],
    this.optionStyle,
    this.width,
    this.circleDiameter = 60,
  })  : assert(
          initialValue >= 0 && initialValue <= 4,
          'Initial value should be between 0 and 4',
        ),
        assert(
          options.length == 5,
          'Reviews options should be 5',
        ),
        super(key: key);

  /// The onChange callback calls every time when a pointer have changed
  /// the value of the slider and is no longer in contact with the screen.
  /// Callback function argument is an int number from 0 to 4, where
  /// 0 is the worst review value and 4 is the best review value

  /// ```dart
  /// ReviewSlider(
  ///  onChange: (int value){
  ///    print(value);
  ///  }),
  /// ),
  /// ```

  final OnChange onChange;
  final int initialValue;
  final List<String> options;
  final TextStyle? optionStyle;
  final double? width;
  final double circleDiameter;
  @override
  _ReviewSliderState createState() => _ReviewSliderState();
}

class _ReviewSliderState extends State<ReviewSlider>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late double _animationValue;
  late double _xOffset;

  late AnimationController _controller;
  late Tween<double> _tween;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    var initValue = widget.initialValue.toDouble();
    _controller = AnimationController(
      value: initValue,
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _tween = Tween(end: initValue);
    _animation = _tween.animate(
      CurvedAnimation(
        curve: Curves.easeIn,
        parent: _controller,
      ),
    )..addListener(() {
        setState(() {
          _animationValue = _animation.value;
        });
      });
    _animationValue = initValue;
    WidgetsBinding.instance!.addPostFrameCallback(_afterLayout);
  }

  _afterLayout(_) {
    widget.onChange(widget.initialValue);
  }

  void handleTap(int state) {
    _controller.duration = Duration(milliseconds: 400);
    _tween.begin = _tween.end;
    _tween.end = state.toDouble();
    _controller.reset();
    _controller.forward();

    widget.onChange(state);
  }

  void _onDrag(double dx, innerWidth) {
    var newAnimatedValue = _calcAnimatedValueFormDragX(dx, innerWidth);

    if (newAnimatedValue > 0 && newAnimatedValue < widget.options.length - 1) {
      setState(
        () {
          _animationValue = newAnimatedValue;
        },
      );
    }
  }

  void _onDragEnd(_) {
    _controller.duration = Duration(milliseconds: 100);
    _tween.begin = _animationValue;
    _tween.end = _animationValue.round().toDouble();
    _controller.reset();
    _controller.forward();

    widget.onChange(_animationValue.round());
  }

  void _onDragStart(x, width) {
    var oneStepWidth =
        (width - widget.circleDiameter) / (widget.options.length - 1);
    _xOffset = x - (oneStepWidth * _animationValue);
  }

  _calcAnimatedValueFormDragX(x, innerWidth) {
    x = x - _xOffset;
    return x /
        (innerWidth - widget.circleDiameter) *
        (widget.options.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingSize),
      height: 100,
      child: LayoutBuilder(
        builder: (context, size) {
          return Stack(
            children: <Widget>[
              MeasureLine(
                states: widget.options,
                handleTap: handleTap,
                animationValue: _animationValue,
//                width: size.maxWidth,
                width: widget.width != null && widget.width! < size.maxWidth
                    ? widget.width!
                    : size.maxWidth,
                optionStyle: widget.optionStyle,
                circleDiameter: widget.circleDiameter,
              ),
              MyIndicator(
                circleDiameter: widget.circleDiameter,
                animationValue: _animationValue,
                width: widget.width != null && widget.width! < size.maxWidth
                    ? widget.width
                    : size.maxWidth,
                onDragStart: (details) {
                  _onDragStart(
                      details.globalPosition.dx,
                      widget.width != null && widget.width! < size.maxWidth
                          ? widget.width
                          : size.maxWidth);
                },
                onDrag: (details) {
                  _onDrag(
                      details.globalPosition.dx,
                      widget.width != null && widget.width! < size.maxWidth
                          ? widget.width
                          : size.maxWidth);
                },
                onDragEnd: _onDragEnd,
              ),
            ],
          );
        },
      ),
    );
  }
}

//const double circleDiameter = 30;
const double paddingSize = 10;

class MeasureLine extends StatelessWidget {
  MeasureLine({
    required this.handleTap,
    required this.animationValue,
    required this.states,
    required this.width,
    this.optionStyle,
    required this.circleDiameter,
  });

  final double animationValue;
  final Function handleTap;
  final List<String> states;
  final double width;
  final TextStyle? optionStyle;
  final double circleDiameter;
  List<Widget> _buildUnits() {
    var res = <Widget>[];
    var animatingUnitIndex = animationValue.round();
    var unitAnimatingValue = (animationValue * 10 % 10 / 10 - 0.5).abs() * 2;

    states.asMap().forEach((index, text) {
      var paddingTop = 0.0;
      var scale = 0.7;
      var opacity = .3;
      if (animatingUnitIndex == index) {
        paddingTop = unitAnimatingValue * 5;
        scale = (1 - unitAnimatingValue) * 0.7;
        opacity = 0.3 + unitAnimatingValue * 0.7;
      }
      res.add(LimitedBox(
        key: ValueKey(text),
        maxWidth: circleDiameter,
        child: GestureDetector(
          onTap: () {
            handleTap(index);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Transform.scale(
                  scale: scale,
                  child: Stack(
                    children: [
                      Head(
                        circleDiameter: circleDiameter,
                      ),
                      Face(
                        circleDiameter: circleDiameter,
                        color: Colors.white,
                        animationValue: index.toDouble(),
                      )
                    ],
                  )),
              Padding(
                padding: EdgeInsets.only(top: paddingTop),
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    text,
                    style: optionStyle ?? TextStyle(color: Colors.black),
                  ),
                ),
              )
            ],
          ),
        ),
      ));
    });
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: circleDiameter / 2,
            left: 20,
            width: width - 40,
            child: Container(
              width: width,
              color: Color(0xFFeceeef),
              height: 3,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildUnits(),
          ),
        ],
      ),
    );
  }
}

class Face extends StatelessWidget {
  Face({
    this.color = const Color(0xFF616154),
    required this.animationValue,
    required this.circleDiameter,
  });

  final double animationValue;
  final Color color;
  final double circleDiameter;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: circleDiameter,
      width: circleDiameter,
      child: CustomPaint(
        size: Size(300, 300),
        painter: MyPainter(animationValue, color: color),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter(
    animationValue, {
    this.color = const Color(0xFF615f56),
  })  : activeIndex = animationValue.floor(),
        unitAnimatingValue = (animationValue * 10 % 10 / 10);

  final int activeIndex;
  Color color;
  final double unitAnimatingValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawEye(canvas, size);
    _drawMouth(canvas, size);
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    return unitAnimatingValue != oldDelegate.unitAnimatingValue ||
        activeIndex != oldDelegate.activeIndex;
  }

  _drawEye(canvas, size) {
    var angle = 0.0;
    var wide = 0.0;

    switch (activeIndex) {
      case 0:
        angle = 55 - unitAnimatingValue * 50;
        wide = 80.0;
        break;
      case 1:
        wide = 80 - unitAnimatingValue * 80;
        angle = 5;
        break;
    }
    var degree1 = 90 * 3 + angle;
    var degree2 = 90 * 3 - angle + wide;
    var x1 = size.width / 2 * 0.65;
    var x2 = size.width - x1;
    var y = size.height * 0.41;
    var eyeRadius = 5.0;

    var paint = Paint()..color = color;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(x1, y),
        radius: eyeRadius,
      ),
      v_math.radians(degree1),
      v_math.radians(360 - wide),
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(x2, y),
        radius: eyeRadius,
      ),
      v_math.radians(degree2),
      v_math.radians(360 - wide),
      false,
      paint,
    );
  }

  _drawMouth(Canvas canvas, size) {
    var upperY = size.height * 0.70;
    var lowerY = size.height * 0.77;
    var middleY = (lowerY - upperY) / 2 + upperY;

    var leftX = size.width / 2 * 0.65;
    var rightX = size.width - leftX;
    var middleX = size.width / 2;

    late double y1, y3, x2, y2;
    Path? path2;
    switch (activeIndex) {
      case 0:
        y1 = lowerY;
        x2 = middleX;
        y2 = upperY;
        y3 = lowerY;
        break;
      case 1:
        y1 = lowerY;
        x2 = middleX;
        y2 = unitAnimatingValue * (middleY - upperY) + upperY;
        y3 = lowerY - unitAnimatingValue * (lowerY - upperY);
        break;
      case 2:
        y1 = unitAnimatingValue * (upperY - lowerY) + lowerY;
        x2 = middleX;
        y2 = unitAnimatingValue * (lowerY + 3 - middleY) + middleY;
        y3 = upperY;
        break;
      case 3:
        y1 = upperY;
        x2 = middleX;
        y2 = lowerY + 3;
        y3 = upperY;
        path2 = Path()
          ..moveTo(leftX, y1)
          ..quadraticBezierTo(
            x2,
            y2,
            upperY - 2.5,
            y3 - 2.5,
          )
          ..quadraticBezierTo(
            x2,
            y2 - unitAnimatingValue * (y2 - upperY + 2.5),
            leftX,
            upperY - 2.5,
          )
          ..close();
        break;
      case 4:
        y1 = upperY;
        x2 = middleX;
        y2 = lowerY + 3;
        y3 = upperY;
        path2 = Path()
          ..moveTo(leftX, y1)
          ..quadraticBezierTo(
            x2,
            y2,
            upperY - 2.5,
            y3 - 2.5,
          )
          ..quadraticBezierTo(
            x2,
            upperY - 2.5,
            leftX,
            upperY - 2.5,
          )
          ..close();
        break;
    }
    var path = Path()
      ..moveTo(leftX, y1)
      ..quadraticBezierTo(
        x2,
        y2,
        rightX,
        y3,
      );

    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5);

    if (path2 != null) {
      canvas.drawPath(
        path2,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

class MyIndicator extends StatelessWidget {
  MyIndicator({
    required this.animationValue,
    required width,
    required this.onDrag,
    required this.onDragStart,
    required this.onDragEnd,
    required this.circleDiameter,
  })   : width = width - circleDiameter,
        possition = animationValue == 0 ? 0 : animationValue / 4;

  final double animationValue;
  final Function(DragUpdateDetails) onDrag;
  final Function(DragEndDetails) onDragEnd;
  final Function(DragStartDetails) onDragStart;
  final double possition;
  final double width;
  final double circleDiameter;

  _buildIndicator() {
    var opacityOfYellow = possition > 0.5 ? 1.0 : possition * 2;
    return GestureDetector(
      onHorizontalDragStart: onDragStart,
      onHorizontalDragUpdate: onDrag,
      onHorizontalDragEnd: onDragEnd,
      child: Container(
        width: circleDiameter,
        height: circleDiameter,
        child: Stack(
          children: <Widget>[
            Head(
              color: Color(0xFFf4b897),
              hasShadow: true,
              circleDiameter: circleDiameter,
            ),
            Opacity(
              opacity: opacityOfYellow,
              child: Head(
                color: Color(0xFFfee385),
                circleDiameter: circleDiameter,
              ),
            ),
            Face(
              animationValue: animationValue,
              circleDiameter: circleDiameter,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Positioned(
        top: 0,
        left: width * possition,
        child: _buildIndicator(),
      ),
    );
  }
}

class Head extends StatelessWidget {
  Head({
    this.color = const Color(0xFFc9ced2),
    this.hasShadow = false,
    required this.circleDiameter,
  });

  final Color color;
  final bool hasShadow;
  final double circleDiameter;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: circleDiameter,
      width: circleDiameter,
      decoration: BoxDecoration(
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 5.0,
                )
              ]
            : null,
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
