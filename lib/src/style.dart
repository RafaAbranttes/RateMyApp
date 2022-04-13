import 'package:flutter/material.dart';

/// Allows to tweak the plugin dialogs.
class DialogStyle {
  /// The title padding.
  final EdgeInsetsGeometry titlePadding;

  /// The content padding.
  final EdgeInsetsGeometry contentPadding;

  /// The title text align.
  final TextAlign titleAlign;

  /// The title text style.
  final TextStyle titleStyle;

  /// The message padding.
  final EdgeInsetsGeometry messagePadding;

  /// The message text align.
  final TextAlign messageAlign;

  /// The message padding.
  final TextStyle messageStyle;

  /// The dialog shape.
  final ShapeBorder dialogShape;

  /// Creates a new dialog style instance.
  const DialogStyle({
    this.titlePadding = const EdgeInsets.all(0),
    this.contentPadding = const EdgeInsets.all(24),
    this.titleAlign,
    this.titleStyle,
    this.messagePadding = const EdgeInsets.all(0),
    this.messageAlign,
    this.messageStyle,
    this.dialogShape,
  });
}

/// Just a little class that allows to customize some rating bar options.
class StarRatingOptions {
  /// The fill color of the stars.
  final Color starsFillColor;

  /// The border color for the stars.
  final Color starsBorderColor;

  /// The stars size.
  final double starsSize;

  /// The space between two stars.
  final double starsSpacing;

  /// The initial rating.
  final double initialRating;

  /// Whether we allow half-stars ratings.
  final bool allowHalfRating;

  /// Fill Button
  final String filledSVG;

  /// HalFilledSVG button
  final String halFilledSVG;

  final Function fuctionClickStar;

  /// Creates a new star rating options instance.
  const StarRatingOptions({
    this.starsFillColor = Colors.orangeAccent,
    this.starsBorderColor = Colors.orangeAccent,
    this.starsSize = 40,
    this.starsSpacing = 0,
    this.initialRating = 0.0,
    this.allowHalfRating = false,
    this.fuctionClickStar,
    @required this.filledSVG,
    @required this.halFilledSVG,
  })  : assert(starsSize != null),
        assert(allowHalfRating != null);
}
