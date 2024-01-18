import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utility/log.dart';

class FedCard extends StatelessWidget {
  const FedCard({
    super.key,
    required this.child,
    this.left = 9,
    this.top = 15,
    this.right = 9,
    this.bottom = 13,
  });
  final Widget child;
  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Container(
      padding: EdgeInsets.fromLTRB(
          left * pixel, top * pixel, right * pixel, bottom * pixel),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground,
        borderRadius: BorderRadius.circular(24 * pixel),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            offset: Offset(0 * pixel, 4 * pixel),
            blurRadius: 2 * pixel,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * pixel, -1 * pixel),
            blurRadius: 1 * pixel,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * pixel, 4 * pixel),
            blurRadius: 2 * pixel,
          ),
        ],
      ),
      child: child,
    );
  }
}

class ClickableFedCard extends StatelessWidget {
  const ClickableFedCard({
    super.key,
    required this.child,
    required this.callBack,
    this.left = 9,
    this.top = 15,
    this.right = 9,
    this.bottom = 13,
  });
  final Widget child;
  final void Function() callBack;
  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground,
        borderRadius: BorderRadius.circular(24 * pixel),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            offset: Offset(0 * pixel, 4 * pixel),
            blurRadius: 2 * pixel,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * pixel, -1 * pixel),
            blurRadius: 1 * pixel,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * pixel, 4 * pixel),
            blurRadius: 2 * pixel,
          ),
        ],
      ),
      child: TextButton(
        onPressed: callBack,
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.onBackground,
          padding: EdgeInsets.fromLTRB(
              left * pixel, top * pixel, right * pixel, bottom * pixel),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24 * pixel)),
        ),
        child: child,
      ),
    );
  }
}

class FedIcon extends StatelessWidget {
  const FedIcon({
    super.key,
    required this.imagePath,
    this.height = 39,
    this.width = 48,
  });

  final String imagePath;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      width: width * pixel,
      height: height * pixel,
    );
  }
}

class SvgIcon extends StatelessWidget {
  const SvgIcon({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit,
    this.colorFilter,
  });

  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final ColorFilter? colorFilter;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      imagePath,
      colorFilter: colorFilter,
      fit: fit ?? BoxFit.contain,
      width: width,
      height: height,
    );
  }
}

class SignInUpTextField extends StatefulWidget {
  const SignInUpTextField(
      {super.key,
      required this.field,
      required this.label,
      required this.onChanged,
      required this.ifObscure});

  final String field;
  final String label;
  final bool ifObscure;

  final void Function(String) onChanged;

  @override
  State<SignInUpTextField> createState() => _SignInUpTextFieldState();
}

class _SignInUpTextFieldState extends State<SignInUpTextField> {
  final ValueNotifier<bool> _focused = ValueNotifier(false);

  onTextFieldFocus(bool focuse) {
    _focused.value = focuse;
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _focused,
          builder: (context, value, child) {
            Color color = Theme.of(context).colorScheme.onTertiaryContainer;
            if (value) {
              color = Theme.of(context).colorScheme.onTertiaryContainer;
            } else {
              Theme.of(context).colorScheme.onTertiaryContainer;
            }
            return Text(
              widget.label,
              style: TextStyle(fontSize: pixel * 18, color: color),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30 * pixel),
          child: Focus(
            onFocusChange: onTextFieldFocus,
            child: TextFormField(
              obscureText: widget.ifObscure,
              initialValue: widget.field,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    width: 1.0 * pixel,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    width: 1.5 * pixel,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void showToastMessage(String msg, BuildContext context, {Color? color}) {
  FocusManager.instance.primaryFocus?.unfocus();
  double pixel = MediaQuery.of(context).size.width / 400;
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: color ?? Colors.red,
      textColor: Colors.white,
      fontSize: pixel * 16.0);
}

void showDialogMessage(String message, String title, BuildContext context) {
  showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("Confirm"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

abstract class LoadingDialog {
  bool cancelled = false;
  void showLoading();
  void cancel();
  void showIfDialogNotCancelled(Exception e, String message);
}

class FullScreenLoadingDialog extends LoadingDialog {
  FullScreenLoadingDialog({required this.context});
  final BuildContext context;
  @override
  void showLoading() {
    // we do not use AlertDialog here because it has an intrinsic constraint of minimum width,
    // as suggested here: https://stackoverflow.com/a/53913355
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, __, ___) {
        double pixel = MediaQuery.of(context).size.width / 400;
        return PopScope(
          // https://stackoverflow.com/a/59755386
          canPop: false,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: SizedBox(
                height: 40 * pixel,
                width: 40 * pixel,
                child: const CircularProgressIndicator(strokeWidth: 2.0),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void cancel() {
    cancelled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop(true);
    });
  }

  @override
  void showIfDialogNotCancelled(Exception e, String message) {
    // TODO: implement showIfDialogNotCancelled
  }
}

class SmallLoadingDialog extends LoadingDialog {
  SmallLoadingDialog({
    required this.context,
    this.showAfterMilliseconds = 500,
  });
  final BuildContext context;
  final int showAfterMilliseconds;
  bool _shown = false;
  @override
  void showLoading() async {
    double pixel = MediaQuery.of(context).size.width / 400;

    // wait `showAfterMilliseconds` second to show the dialog, if it survives till that moment (due to early loading done), set [_shown] to true
    await Future.delayed(Duration(milliseconds: showAfterMilliseconds));
    _shown = true;

    if (cancelled) return;

    if (context.mounted) {
      showDialog<bool>(
          context: context,
          builder: (context) {
            return PopScope(
              onPopInvoked: (bool didPop) {
                cancelled = true;
              },
              child: AlertDialog(
                title: const Text("Loading"),
                content: Row(
                  children: [
                    const Spacer(),
                    SizedBox(
                      height: 40 * pixel,
                      width: 40 * pixel,
                      child: const CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                    const Spacer(),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: cancel,
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            );
          });
    }
  }

  @override
  void cancel() {
    cancelled = true;
    if (_shown && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop(true);
      });
    }
  }

  @override
  void showIfDialogNotCancelled(Exception e, String message) {
    logger.e(e);
    if (context.mounted && !cancelled) {
      showToastMessage(message, context);
      cancel();
    }
  }
}

class WidgetListWithDivider extends StatelessWidget {
  const WidgetListWithDivider({
    super.key,
    required this.children,
    required this.color,
  });

  final List<Widget> children;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget elementToInsert = MeDivider(
      color: color,
    );
    List<Widget> childrenWithMeDividerInserted = [];
    childrenWithMeDividerInserted = children
        .sublist(0, children.length - 1)
        .expand((Widget item) => [item, elementToInsert])
        .toList()
      ..add(children.last);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: childrenWithMeDividerInserted,
    );
  }
}

class MeDivider extends StatelessWidget {
  const MeDivider({
    super.key,
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return Divider(
      height: 1 * pixel,
      thickness: 1,
      indent: 50,
      endIndent: 50,
      color: color,
    );
  }
}
