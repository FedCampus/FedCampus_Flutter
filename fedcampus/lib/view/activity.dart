import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  const Activity({
    super.key,
  });

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  @override
  Widget build(BuildContext context) {
    double logicalWidth = MediaQuery.of(context).size.width;
    return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 11),
        itemCount: 20,
        padding: EdgeInsets.all(logicalWidth / 20),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Date(fem: 1, callback: () => {});
          }
          // the use of IntrinsicHeight is explained here:
          // because ActivityCard() is flexible vertically, when placed in ListView, the height becomes an issue
          // IntrinsicHeight forces the column to be exactly as big as its contents
          // https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html
          return const IntrinsicHeight(child: ActivityCard());
        });
  }
}

class FedIcon extends StatelessWidget {
  const FedIcon({
    super.key,
    required this.imagePath,
    this.width = 48,
    this.height = 39,
  });

  final String imagePath;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      height: height,
      width: width,
    );
  }
}

class FedCard extends StatelessWidget {
  const FedCard({
    super.key,
    required this.smallSize,
    required this.widget,
  });
  final double smallSize;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          14 * smallSize, 18 * smallSize, 14 * smallSize, 17 * smallSize),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(24 * smallSize),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            offset: Offset(0 * smallSize, 4 * smallSize),
            blurRadius: 2 * smallSize,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * smallSize, -1 * smallSize),
            blurRadius: 1 * smallSize,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * smallSize, 4 * smallSize),
            blurRadius: 2 * smallSize,
          ),
        ],
      ),
      child: widget,
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double logicalWidth = MediaQuery.of(context).size.width;
    logger.d(logicalWidth / 10);
    return FedCard(
        smallSize: logicalWidth / 360,
        widget: Row(
          children: <Widget>[
            // As stated in https://api.flutter.dev/flutter/widgets/Image/height.html,
            // it is recommended to specify the image size (in order to avoid
            // widget size suddenly changes when the app just loads another page)
            Image.asset(
              'assets/images/step_activity.png',
              fit: BoxFit.contain,
              height: logicalWidth / 6,
              width: logicalWidth / 6,
            ),
            const Expanded(
              child: SizedBox(),
            ),
            Expanded(
              flex: 7,
              child: Text(
                '1111',
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: <Widget>[
                  const Expanded(
                    flex: 2,
                    child: SizedBox(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'steps',
                      style: TextStyle(
                          fontFamily: 'Montserrat Alternates',
                          fontSize: 20,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: SizedBox(),
            ),
            Expanded(
              flex: 7,
              child: Text(
                '88/88',
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontFamily: 'Montserrat Alternates',
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.secondaryContainer),
              ),
            ),
          ],
        ));
  }
}

class Date extends StatelessWidget {
  const Date({
    super.key,
    required this.fem,
    required this.callback,
  });

  final double fem;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: BorderRadius.circular(24),
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
      child: TextButton(
        onPressed: callback,
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceTint,
          padding: EdgeInsets.fromLTRB(40 * fem, 18 * fem, 40 * fem, 17 * fem),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const FedIcon(imagePath: 'assets/images/activity_nav_icon.png'),
            SizedBox(
              width: 11 * fem,
            ),
            SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 5 * fem),
                    child: Text(
                      'Jan 1',
                      style: TextStyle(
                          fontSize: 20,
                          shadows: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow,
                              offset: Offset(0 * fem, 2 * fem),
                              blurRadius: 1,
                            ),
                          ],
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                  Text(
                    '2023',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
