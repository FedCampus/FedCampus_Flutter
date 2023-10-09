import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utility/event_bus.dart';
import '../../utility/log.dart';

class FedCard extends StatelessWidget {
  const FedCard({
    super.key,
    required this.widget,
    this.left = 10,
    this.top = 17,
    this.right = 10,
    this.bottom = 14,
  });
  final Widget widget;
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
      child: widget,
    );
  }
}

class ClickableFedCard extends StatelessWidget {
  const ClickableFedCard({
    super.key,
    required this.widget,
    required this.callBack,
    this.left = 10,
    this.top = 17,
    this.right = 10,
    this.bottom = 14,
  });
  final Widget widget;
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
              14 * pixel, 18 * pixel, 14 * pixel, 17 * pixel),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24 * pixel)),
        ),
        child: widget,
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
    this.height = 50,
    this.width = 50,
    this.colorFilter,
  });

  final String imagePath;
  final double height;
  final double width;
  final ColorFilter? colorFilter;
  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return SvgPicture.asset(
      imagePath,
      colorFilter: colorFilter,
      fit: BoxFit.contain,
      width: width * pixel,
      height: height * pixel,
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

void showToastMessage(String msg, BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
  double pixel = MediaQuery.of(context).size.width / 400;
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
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
        return WillPopScope(
          // https://stackoverflow.com/a/59755386
          onWillPop: () async => false,
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
}

class SmallLoadingDialog extends LoadingDialog {
  SmallLoadingDialog({required this.context});
  final BuildContext context;
  @override
  void showLoading() {
    double pixel = MediaQuery.of(context).size.width / 400;

    bus.on("loading_done", (arg) {
      logger.e("loading_done");
      bus.off("loading_done");
      if (!cancelled) cancel();
    });

    showDialog<bool>(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              cancelled = true;
              return true;
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

  @override
  void cancel() {
    cancelled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop(true);
    });
  }
}
