import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:rate_my_app/src/core.dart';
import 'package:rate_my_app/src/style.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

/// A simple dialog button click listener.
typedef RateMyAppDialogButtonClickListener = bool Function(
    RateMyAppDialogButton button);

/// Validates a state when called in a function.
typedef Validator = bool Function();

/// Allows to change the default dialog content.
typedef DialogContentBuilder = Widget Function(
    BuildContext context, Widget defaultContent);

/// Allows to dynamically build actions.
typedef DialogActionsBuilder = List<Widget> Function(BuildContext context);

/// Allows to dynamically build actions according to the specified rating.
typedef StarDialogActionsBuilder = List<Widget> Function(
    BuildContext context, double stars);

/// The Android Rate my app dialog.
class RateMyAppDialog extends StatelessWidget {
  /// The Rate my app instance.
  final RateMyApp rateMyApp;

  /// The dialog's title.
  final String title;

  /// The dialog's message.
  final String message;

  /// The content builder.
  final DialogContentBuilder contentBuilder;

  /// The actions builder.
  final DialogActionsBuilder actionsBuilder;

  /// The dialog's rate button.
  final String rateButton;

  /// The dialog's no button.
  final String noButton;

  /// The dialog's later button.
  final String laterButton;

  /// The buttons listener.
  final RateMyAppDialogButtonClickListener listener;

  /// The dialog's style.
  final DialogStyle dialogStyle;

  /// Creates a new Rate my app dialog.
  const RateMyAppDialog(
    this.rateMyApp, {
    @required this.title,
    @required this.message,
    @required this.contentBuilder,
    this.actionsBuilder,
    @required this.rateButton,
    @required this.noButton,
    @required this.laterButton,
    this.listener,
    @required this.dialogStyle,
  })  : assert(title != null),
        assert(message != null),
        assert(rateButton != null),
        assert(noButton != null),
        assert(laterButton != null),
        assert(dialogStyle != null);

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      child: Padding(
        padding: dialogStyle.messagePadding,
        child: Text(
          message,
          style: dialogStyle.messageStyle,
          textAlign: dialogStyle.messageAlign,
        ),
      ),
    );

    return AlertDialog(
      title: Padding(
        padding: dialogStyle.titlePadding,
        child: Text(
          title,
          style: dialogStyle.titleStyle,
          textAlign: dialogStyle.titleAlign,
        ),
      ),
      content: contentBuilder(context, content),
      contentPadding: dialogStyle.contentPadding,
      shape: dialogStyle.dialogShape,
      actions: (actionsBuilder ?? _defaultActionsBuilder)(context),
    );
  }

  List<Widget> _defaultActionsBuilder(BuildContext context) => [
        RateMyAppRateButton(
          rateMyApp,
          text: rateButton,
          validator: () =>
              listener == null || listener(RateMyAppDialogButton.rate),
        ),
        RateMyAppLaterButton(
          rateMyApp,
          text: laterButton,
          validator: () =>
              listener == null || listener(RateMyAppDialogButton.later),
        ),
        RateMyAppNoButton(
          rateMyApp,
          text: noButton,
          validator: () =>
              listener == null || listener(RateMyAppDialogButton.no),
        ),
      ];
}

/// The Rate my app star dialog.
class RateMyAppStarDialog extends StatefulWidget {
  /// The Rate my app instance.
  final RateMyApp rateMyApp;

  /// The smooth star rating style.
  final StarRatingOptions starRatingOptions;

  /// Text Style button
  final TextStyle textStyle;

  /// Creates a new Rate my app star dialog.
  const RateMyAppStarDialog(
    this.rateMyApp, {
    @required this.starRatingOptions,
    this.textStyle,
  }) : assert(starRatingOptions != null);

  @override
  State<StatefulWidget> createState() => RateMyAppStarDialogState();
}

/// The Rate my app star dialog state.
class RateMyAppStarDialogState extends State<RateMyAppStarDialog> {
  /// The current rating.
  double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.starRatingOptions.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmoothStarRating(
            onRatingChanged: (rating) async {
              setState(() => _currentRating = rating);
              widget.starRatingOptions.fuctionClickStar();
              Future.delayed(
                const Duration(milliseconds: 300),
                () async {
                  await widget.rateMyApp
                      .callEvent(RateMyAppEventType.rateButtonPressed);
                  Navigator.pop<RateMyAppDialogButton>(
                      context, RateMyAppDialogButton.rate);

                  await widget.rateMyApp.launchStore();
                },
              );
            },
            filledSVG: widget.starRatingOptions.filledSVG,
            halFilledSVG: widget.starRatingOptions.halFilledSVG,
            color: widget.starRatingOptions.starsFillColor,
            borderColor: widget.starRatingOptions.starsBorderColor,
            spacing: widget.starRatingOptions.starsSpacing,
            size: widget.starRatingOptions.starsSize,
            allowHalfRating: widget.starRatingOptions.allowHalfRating,
            rating: _currentRating == null ? 0.0 : _currentRating.toDouble(),
          ),
        ],
      ),
    );

    return content;
  }
}

/// A Rate my app dialog button with a text, a validator and a callback.
abstract class _RateMyAppDialogButton extends StatelessWidget {
  /// The Rate my app instance.
  final RateMyApp rateMyApp;

  /// The button text.
  final String text;

  /// The state validator (whether this button should have an effect).
  final Validator validator;

  /// Called when the action has been executed.
  final VoidCallback callback;

  ///style text button
  final TextStyle textStyle;

  /// Creates a new Rate my app button widget instance.
  const _RateMyAppDialogButton(
    this.rateMyApp, {
    @required this.text,
    this.validator = _validatorTrue,
    this.callback,
    this.textStyle,
  }) : assert(text != null);

  @override
  Widget build(BuildContext context) => FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(45.0),
        ),
        child: Text(
          text,
          style: textStyle ??
              const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
        ),
        onPressed: () async {
          if (validator != null && !validator()) {
            return;
          }

          await onButtonClicked(context);
          if (callback != null) {
            callback();
          }
        },
      );

  /// Triggered when a button has been clicked.
  Future<void> onButtonClicked(BuildContext context);

  /// A validator that always return true.
  static bool _validatorTrue() => true;
}

/// The Rate my app "rate" button widget.
class RateMyAppRateButton extends _RateMyAppDialogButton {
  /// Creates a new Rate my app "rate" button widget instance.
  const RateMyAppRateButton(
    RateMyApp rateMyApp, {
    @required String text,
    Validator validator,
    VoidCallback callback,
  }) : super(
          rateMyApp,
          text: text,
          validator: validator,
          callback: callback,
        );

  @override
  Future<void> onButtonClicked(BuildContext context) async {
    await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
    Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.rate);
    await rateMyApp.launchStore();
  }
}

/// The Rate my app "later" button widget.
class RateMyAppLaterButton extends _RateMyAppDialogButton {
  /// Creates a new Rate my app "later" button widget instance.
  const RateMyAppLaterButton(
    RateMyApp rateMyApp, {
    @required String text,
    Validator validator,
    VoidCallback callback,
    TextStyle textStyle,
  }) : super(
          rateMyApp,
          text: text,
          validator: validator,
          callback: callback,
          textStyle: textStyle,
        );

  @override
  Future<void> onButtonClicked(BuildContext context) async {
    await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
    Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.later);
  }
}

/// The Rate my app "no" button widget.
class RateMyAppNoButton extends _RateMyAppDialogButton {
  /// Creates a new Rate my app "no" button widget instance.
  const RateMyAppNoButton(
    RateMyApp rateMyApp, {
    @required String text,
    Validator validator,
    VoidCallback callback,
  }) : super(
          rateMyApp,
          text: text,
          validator: validator,
          callback: callback,
        );

  @override
  Future<void> onButtonClicked(BuildContext context) async {
    await rateMyApp.callEvent(RateMyAppEventType.noButtonPressed);
    Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.no);
  }
}

/// Represents a Rate my app dialog button.
enum RateMyAppDialogButton {
  /// The "rate" button.
  rate,

  /// The "later" button.
  later,

  /// The "no" button.
  no,
}
