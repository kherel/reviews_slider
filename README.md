# reviews_slider

Flutter reviews slider;

![example](example.gif)

## Getting started

You should ensure that you add the router as a dependency in your flutter project.

```yaml
dependencies:
 reviews_slider: "^1.0.0"
```

### How To Use

Import the following package in your dart file

```dart
import 'package:reviews_slider/reviews_slider.dart';
```

Basic Widget

```dart
  ReviewSlider(
    onChange: (int value){
      // active value is an int number from 0 to 4, where:
      // 0 is the worst review value
      // and 4 is the best review value
      print(value);
    }),
  ),
```

 Parameter | Default | Description |
| :------------------------ | :--------------------------------------------------------------------: | :----------------- |
| initialValue | 2 | the init value of the slider
| onChange|  | Triggered every time when a pointer have changed the value of the slider and is no longer in contact with the screen.
| options| ['Terrible', 'Bad', 'Okay', 'Good', 'Great'] | Review titles
| optionStyle| TextStyle(color:  Colors.black) | Text style of review titles
