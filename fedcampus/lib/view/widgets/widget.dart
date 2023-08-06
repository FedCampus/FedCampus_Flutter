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
