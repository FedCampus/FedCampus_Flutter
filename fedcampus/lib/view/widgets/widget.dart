import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
