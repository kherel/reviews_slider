import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as v_math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('How was the help you recived?', style: TextStyle(color: Color(0xFF6f7478), fontSize: 18),),
              SizedBox(height: 20),
              ReviewSlider()
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewSlider extends StatefulWidget {
  @override
  _ReviewSliderState createState() => _ReviewSliderState();
}

class _ReviewSliderState extends State<ReviewSlider> with SingleTickerProviderStateMixin {
  double intitalReviewValue = 2;
  final List<String> reviews = ['Terrible', 'Bad', 'Okay', 'Good', 'Great'];

  Animation<double> _animation;
  AnimationController _controller;
  Tween<double> _tween;
  double _innerWidth;
  double _animationValue;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      value: intitalReviewValue,
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _tween = Tween(end: intitalReviewValue);
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
    _animationValue = intitalReviewValue;
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  _afterLayout(_) {
    setState(() {
      _innerWidth = MediaQuery.of(context).size.width - 2 * paddingSize;
    });
  }

  void handleTap(int state) {
    _controller.duration = Duration(milliseconds: 400);

    _tween.begin = _tween.end;
    _tween.end = state.toDouble();
    _controller.reset();
    _controller.forward();
  }

  _onDrag(details) {
    var newAnimatedValue = _calcAnimatedValueFormDragX(
      details.globalPosition.dx,
    );
    if (newAnimatedValue > 0 && newAnimatedValue < reviews.length - 1) {
      setState(
        () {
          _animationValue = newAnimatedValue;
        },
      );
    }
  }

  _calcAnimatedValueFormDragX(x) {
    return (x - circleDiameter / 2 - paddingSize * 2) / _innerWidth * reviews.length;
  }

  _onDragEnd(_) {
    _controller.duration = Duration(milliseconds: 100);
    _tween.begin = _animationValue;
    _tween.end = _animationValue.round().toDouble();
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _innerWidth == null
          ? Container()
          : Container(
              padding: EdgeInsets.symmetric(horizontal: paddingSize),
              height: 200,
              child: Stack(children: <Widget>[
                MeasureLine(
                  states: reviews,
                  handleTap: handleTap,
                  animationValue: _animationValue,
                  width: _innerWidth,
                ),
                MyIndicator(
                  animationValue: _animationValue,
                  width: _innerWidth,
                  onDrag: _onDrag,
                  onDragEnd: _onDragEnd,
                ),
                Text(_animationValue.round().toString()),
              ]),
            ),
    );
  }
}

const double circleDiameter = 60;
const double paddingSize = 10;

class MeasureLine extends StatelessWidget {
  MeasureLine({this.handleTap, this.animationValue, this.states, this.width});

  final double animationValue;
  final Function handleTap;
  final List<String> states;
  final double width;

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
                      Head(),
                      Face(
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
                    style: TextStyle(color: Colors.black),
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
    return Stack(
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
    );
  }
}

class Face extends StatelessWidget {
  Face({
    this.color = const Color(0xFF616154),
    this.animationValue,
  });

  final Color color;
  final double animationValue;

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

  Color color;
  final int activeIndex;
  final double unitAnimatingValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawEye(canvas, size);
    _drawMouth(canvas, size);
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

    double y1, y3, x2, y2;
    Path path2;
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

  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    return unitAnimatingValue != oldDelegate.unitAnimatingValue ||
        activeIndex != oldDelegate.activeIndex;
  }
}

class MyIndicator extends StatelessWidget {
  MyIndicator({
    this.animationValue,
    width,
    this.onDrag,
    this.onDragStart,
    this.onDragEnd,
  })  : width = width - circleDiameter,
        possition = animationValue == 0 ? 0 : animationValue / 4;

  final double possition;
  final Function onDrag;
  final Function onDragStart;
  final Function onDragEnd;
  final double width;
  final double animationValue;

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

  _buildIndicator() {
    var opacityOfYellow = possition > 0.5 ? 1.0 : possition * 2;
    return GestureDetector(
      
      onPanDown: onDragStart,
      onPanUpdate: onDrag,
      onPanStart: onDrag,
      onPanEnd: onDragEnd,
      child: Container(
        width: circleDiameter,
        height: circleDiameter,
        child: Stack(
          children: <Widget>[
            Head(
              color: Color(0xFFf4b897),
              hasShadow: true,
            ),
            Opacity(
              opacity: opacityOfYellow,
              child: Head(
                color: Color(0xFFfee385),
              ),
            ),
            Face(
              animationValue: animationValue,
            )
          ],
        ),
      ),
    );
  }
}

class Head extends StatelessWidget {
  Head({this.color = const Color(0xFFc9ced2), this.hasShadow = false});

  final Color color;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: circleDiameter,
      width: circleDiameter,
      decoration: BoxDecoration(
        boxShadow: hasShadow
            ? [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 5.0)]
            : null,
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
