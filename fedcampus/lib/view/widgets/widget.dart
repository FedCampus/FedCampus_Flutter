import 'package:flutter/material.dart';

class FedCard extends StatelessWidget {
  const FedCard({
    super.key,
    required this.fem,
    required this.ffem,
    required this.widget,
  });
  final double fem;
  final double ffem;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14 * fem, 18 * fem, 14 * fem, 17 * fem),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(24 * fem),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            offset: Offset(0 * fem, 4 * fem),
            blurRadius: 2 * fem,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * fem, -1 * fem),
            blurRadius: 1 * fem,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * fem, 4 * fem),
            blurRadius: 2 * fem,
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
    required this.fem,
    required this.imagePath,
    this.height = 39,
    this.width = 48,
  });

  final double fem;
  final String imagePath;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width * fem,
      height: height * fem,
    );
  }
}

class SignInUpTextField extends StatefulWidget {
  const SignInUpTextField({
    super.key,
    required this.field,
    required this.label,
    required this.onChanged,
  });

  final String field;
  final String label;
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
    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _focused,
          builder: (context, value, child) {
            Color color = Theme.of(context).colorScheme.surfaceVariant;
            if (value) {
              color = Theme.of(context).colorScheme.primary;
            } else {
              Theme.of(context).colorScheme.surfaceVariant;
            }
            return Text(
              widget.label,
              style: TextStyle(fontSize: 18, color: color),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Focus(
            onFocusChange: onTextFieldFocus,
            child: TextFormField(
              initialValue: widget.field,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    width: 1.0,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
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
