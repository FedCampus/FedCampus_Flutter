// import 'package:fedcampus/utility/log.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class HealthPage extends StatefulWidget {
//   const HealthPage({super.key});

//   @override
//   createState() => _HealthPageState();
// }

// class _HealthPageState extends State<HealthPage> {
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     logger.d(width);
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('FedCampus'),
//         ),
//         body:
//         Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Card(
//             elevation: 8,
//             color: const Color.fromARGB(255, 250, 247, 226),
//             shadowColor: Colors.black,
//             shape: const RoundedRectangleBorder(
//               side: BorderSide(
//                   // color: Theme.of(context).colorScheme.outline,
//                   ),
//               borderRadius: BorderRadius.all(Radius.circular(28)),
//             ),
//             child: SizedBox(
//               width: 150,
//               child: Row(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
//                     // ↓ Make the following change.
//                     child: SvgPicture.asset(
//                       'assets/circle.svg',
//                       width: 40,
//                     ),
//                   ),
//                   const Padding(
//                     padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
//                     // ↓ Make the following change.
//                     child: Text('hello'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Card(
//             elevation: 8,
//             color: const Color.fromARGB(255, 250, 247, 226),
//             shadowColor: Colors.black,
//             shape: const RoundedRectangleBorder(
//               side: BorderSide(
//                   // color: Theme.of(context).colorScheme.outline,
//                   ),
//               borderRadius: BorderRadius.all(Radius.circular(28)),
//             ),
//             child: SizedBox(
//               width: 150,
//               child: Row(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
//                     // ↓ Make the following change.
//                     child: SvgPicture.asset(
//                       'assets/circle.svg',
//                       width: 40,
//                     ),
//                   ),
//                   const Padding(
//                     padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
//                     // ↓ Make the following change.
//                     child: Text('hello'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ])
//         );
//   }
// }

//TODO:find better way do adapt different screen size
import 'package:flutter/material.dart';
import 'package:fedcampus/utils.dart';
import '../utility/log.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    logger.d(MediaQuery.of(context).size.width);
    logger.d(fem);
    double ffem = fem * 0.97;
    logger.d(ffem);
    return Scaffold(
      appBar: AppBar(
        // title: TopBar(fem: fem),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Image.asset(
          'assets/page-1/images/-Q8H.png',
          height: 35,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // autogrouprnv5KqK (2RBzXWd3zKDPkcmZ7Grnv5)
            margin: EdgeInsets.fromLTRB(32 * fem, 19 * fem, 26 * fem, 11 * fem),
            width: double.infinity,
            height: 650 * fem,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LeftColumn(fem: fem, ffem: ffem),
                RightColumn(fem: fem, ffem: ffem),
              ],
            ),
          ),
          // BottomBar(fem: fem, ffem: ffem),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 40,
              child: Image.asset(
                'assets/page-1/images/noun-heart-59-0272-2-1-tLh.png',
                fit: BoxFit.contain,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 40,
              child: Image.asset(
                'assets/page-1/images/noun-heart-590-2272-1-Mvh.png',
                fit: BoxFit.contain,
              ),
            ),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 40,
              child: Image.asset(
                'assets/page-1/images/edge-intelligence-logo-1-guF.png',
                fit: BoxFit.contain,
              ),
            ),
            label: 'School',
          ),
        ],
      ),
    );

    // SizedBox(
    //   width: double.infinity,
    //   child: SingleChildScrollView(
    //     child: Container(
    //       // iphone141i2u (1:2)
    //       width: double.infinity,
    //       decoration: BoxDecoration(
    //         color: Theme.of(context).colorScheme.background,
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           TopBar(fem: fem),
    //           Container(
    //             // autogrouprnv5KqK (2RBzXWd3zKDPkcmZ7Grnv5)
    //             margin:
    //                 EdgeInsets.fromLTRB(32 * fem, 0 * fem, 26 * fem, 11 * fem),
    //             width: double.infinity,
    //             height: 650 * fem,
    //             child: Row(
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: [
    //                 LeftColumn(fem: fem, ffem: ffem),
    //                 RightColumn(fem: fem, ffem: ffem),
    //               ],
    //             ),
    //           ),
    //           // BottomBar(fem: fem, ffem: ffem),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}

class LeftColumn extends StatelessWidget {
  const LeftColumn({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // frame62Dw (30:152)
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 26 * fem, 0 * fem),
      width: 153 * fem,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
            // group8LkR (73:418)
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: Date(fem: fem, ffem: ffem),
          ),
          SizedBox(
            height: 20 * fem,
          ),
          Heartrate(fem: fem, ffem: ffem),
          SizedBox(
            height: 20 * fem,
          ),
          Distance(fem: fem, ffem: ffem),
          SizedBox(
            height: 20 * fem,
          ),
          Stress(fem: fem, ffem: ffem),
        ],
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // frame4jYD (30:27)
      padding: EdgeInsets.fromLTRB(50 * fem, 10 * fem, 94 * fem, 10 * fem),
      width: double.infinity,
      height: 196 * fem,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            offset: Offset(0 * fem, -2 * fem),
            blurRadius: 2 * fem,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Health(fem: fem, ffem: ffem),
          Activity(fem: fem, ffem: ffem),
          Me(fem: fem, ffem: ffem),
        ],
      ),
    );
  }
}

class Health extends StatelessWidget {
  const Health({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // component1Rfw (74:216)
      margin: EdgeInsets.fromLTRB(0 * fem, 1 * fem, 64 * fem, 0 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // nounheart59027221kTK (17:18)
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 2 * fem, 1 * fem),
            width: 27 * fem,
            height: 25 * fem,
            child: Image.asset(
              'assets/page-1/images/noun-heart-59-0272-2-1-tLh.png',
              fit: BoxFit.cover,
            ),
          ),
          Text(
            // health4D7 (50:238)
            'Health',
            style: SafeGoogleFont(
              'Inter',
              fontSize: 12 * ffem,
              fontWeight: FontWeight.w600,
              height: 1.2125 * ffem / fem,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class RightColumn extends StatelessWidget {
  const RightColumn({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // frame7hVj (30:153)
      width: 153 * fem,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Step(fem: fem, ffem: ffem),
          SizedBox(
            height: 21 * fem,
          ),
          Calorie(fem: fem, ffem: ffem),
          SizedBox(
            height: 21 * fem,
          ),
          IntenseExercise(fem: fem, ffem: ffem),
          SizedBox(
            height: 21 * fem,
          ),
          Sleep(fem: fem, ffem: ffem),
        ],
      ),
    );
  }
}

class Step extends StatelessWidget {
  const Step({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // group2d8V (30:142)
      padding: EdgeInsets.fromLTRB(16 * fem, 26 * fem, 16 * fem, 15 * fem),
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // groupg6m (56:257)
            margin: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 22 * fem),
            width: 40.23 * fem,
            height: 41 * fem,
            child: Image.asset(
              'assets/page-1/images/group-aLh.png',
              width: 40.23 * fem,
              height: 41 * fem,
            ),
          ),
          Text(
            // stepoBP (30:144)
            'Step',
            style: SafeGoogleFont(
              'Inter',
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w400,
              height: 1.2125 * ffem / fem,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class Sleep extends StatelessWidget {
  const Sleep({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // group6eNM (30:149)
      padding: EdgeInsets.fromLTRB(16 * fem, 16.93 * fem, 16 * fem, 113 * fem),
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // nounsleep45410901tnV (65:298)
            margin:
                EdgeInsets.fromLTRB(1.38 * fem, 0 * fem, 0 * fem, 7.93 * fem),
            width: 44.24 * fem,
            height: 45.15 * fem,
            child: Image.asset(
              'assets/page-1/images/noun-sleep-4541090-1.png',
              width: 44.24 * fem,
              height: 45.15 * fem,
            ),
          ),
          Text(
            // sleepoPf (30:137)
            'Sleep',
            style: SafeGoogleFont(
              'Inter',
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w400,
              height: 1.2125 * ffem / fem,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class IntenseExercise extends StatelessWidget {
  const IntenseExercise({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // group1P37 (30:132)
      padding: EdgeInsets.fromLTRB(11 * fem, 17 * fem, 11 * fem, 11 * fem),
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // vector2rm (65:297)
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15.23 * fem),
            width: 61.81 * fem,
            height: 62.77 * fem,
            child: Image.asset(
              'assets/page-1/images/vector-StH.png',
              width: 61.81 * fem,
              height: 62.77 * fem,
            ),
          ),
          Container(
            // intenseexercisexEd (30:130)
            margin: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 0 * fem),
            constraints: BoxConstraints(
              maxWidth: 64 * fem,
            ),
            child: Text(
              'Intense \nExercise',
              style: SafeGoogleFont(
                'Inter',
                fontSize: 16 * ffem,
                fontWeight: FontWeight.w400,
                height: 1.2125 * ffem / fem,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Calorie extends StatelessWidget {
  const Calorie({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // group3iJM (30:146)
      padding: EdgeInsets.fromLTRB(16 * fem, 22.99 * fem, 16 * fem, 11 * fem),
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // nouncalorieburn5123751kVw (56:277)
            margin:
                EdgeInsets.fromLTRB(7.32 * fem, 0 * fem, 0 * fem, 21.15 * fem),
            width: 37.67 * fem,
            height: 39.86 * fem,
            child: Image.asset(
              'assets/page-1/images/noun-calorie-burn-512375-1.png',
              width: 37.67 * fem,
              height: 39.86 * fem,
            ),
          ),
          Text(
            // calorieFSh (30:134)
            'Calorie',
            style: SafeGoogleFont(
              'Inter',
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w400,
              height: 1.2125 * ffem / fem,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class Stress extends StatelessWidget {
  const Stress({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // group7omj (30:150)
      padding: EdgeInsets.fromLTRB(14 * fem, 14 * fem, 14 * fem, 69 * fem),
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // vectorEc9 (65:307)
            margin: EdgeInsets.fromLTRB(2 * fem, 0 * fem, 0 * fem, 2 * fem),
            width: 41 * fem,
            height: 41 * fem,
            child: Image.asset(
              'assets/page-1/images/vector-ySR.png',
              width: 41 * fem,
              height: 41 * fem,
            ),
          ),
          Text(
            // stressm6H (30:138)
            'Stress',
            style: SafeGoogleFont(
              'Inter',
              fontSize: 16 * ffem,
              fontWeight: FontWeight.w400,
              height: 1.2125 * ffem / fem,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class Distance extends StatelessWidget {
  const Distance({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // group5ueR (30:148)
      padding: EdgeInsets.fromLTRB(14 * fem, 21 * fem, 14 * fem, 20 * fem),
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // groupk9F (65:290)
            margin: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 13 * fem),
            width: 43 * fem,
            height: 43 * fem,
            child: Image.asset(
              'assets/page-1/images/group.png',
              width: 43 * fem,
              height: 43 * fem,
            ),
          ),
          Container(
            // distance4fj (30:135)
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 18 * fem),
            child: Text(
              'Distance',
              style: SafeGoogleFont(
                'Inter',
                fontSize: 16 * ffem,
                fontWeight: FontWeight.w400,
                height: 1.2125 * ffem / fem,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          Container(
            // vectora8H (65:295)
            margin: EdgeInsets.fromLTRB(5 * fem, 0 * fem, 0 * fem, 7 * fem),
            width: 43 * fem,
            height: 24 * fem,
            child: Image.asset(
              'assets/page-1/images/vector.png',
              width: 43 * fem,
              height: 24 * fem,
            ),
          ),
          Text(
            // elevation5aq (30:136)
            'Elevation',
            style: SafeGoogleFont(
              'Inter',
              fontSize: 12 * ffem,
              fontWeight: FontWeight.w400,
              height: 1.2125 * ffem / fem,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class Me extends StatelessWidget {
  const Me({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // component3igy (74:218)
      margin: EdgeInsets.fromLTRB(0 * fem, 3 * fem, 0 * fem, 0 * fem),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: SizedBox(
          width: 23 * fem,
          height: 39 * fem,
          child: Stack(
            children: [
              Positioned(
                // edgeintelligencelogo1E9X (17:20)
                left: 0 * fem,
                top: 0 * fem,
                child: Align(
                  child: SizedBox(
                    width: 23 * fem,
                    height: 25 * fem,
                    child: Image.asset(
                      'assets/page-1/images/edge-intelligence-logo-1-guF.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                // meLTT (68:309)
                left: 3 * fem,
                top: 24 * fem,
                child: Align(
                  child: SizedBox(
                    width: 18 * fem,
                    height: 15 * fem,
                    child: Text(
                      'Me',
                      style: SafeGoogleFont(
                        'Inter',
                        fontSize: 12 * ffem,
                        fontWeight: FontWeight.w600,
                        height: 1.2125 * ffem / fem,
                        color: Theme.of(context).colorScheme.surfaceTint,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Activity extends StatelessWidget {
  const Activity({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // component2zMf (74:217)
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 70 * fem, 0 * fem),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // nounheart59022721sAZ (17:19)
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 1 * fem, 2 * fem),
              width: 26 * fem,
              height: 25 * fem,
              child: Image.asset(
                'assets/page-1/images/noun-heart-590-2272-1-Mvh.png',
                fit: BoxFit.cover,
              ),
            ),
            Text(
              // activityn2d (68:308)
              'Activity',
              style: SafeGoogleFont(
                'Inter',
                fontSize: 12 * ffem,
                fontWeight: FontWeight.w600,
                height: 1.2125 * ffem / fem,
                color: Theme.of(context).colorScheme.surfaceTint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Heartrate extends StatelessWidget {
  const Heartrate({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // group4p5F (68:381)
      padding: EdgeInsets.fromLTRB(14 * fem, 18 * fem, 14 * fem, 17 * fem),
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            // vectorFRT (68:380)
            width: 48 * fem,
            height: 39 * fem,
            child: Image.asset(
              'assets/page-1/images/vector-hJy.png',
              width: 48 * fem,
              height: 39 * fem,
            ),
          ),
          SizedBox(
            height: 11 * fem,
          ),
          Container(
            // heartrateZS9 (30:141)
            margin: EdgeInsets.fromLTRB(1 * fem, 0 * fem, 0 * fem, 0 * fem),
            constraints: BoxConstraints(
              maxWidth: 47 * fem,
            ),
            child: Text(
              'Heart \nRate',
              style: SafeGoogleFont(
                'Inter',
                fontSize: 16 * ffem,
                fontWeight: FontWeight.w400,
                height: 1.2125 * ffem / fem,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
          SizedBox(
            height: 11 * fem,
          ),
          Container(
            // vectorcQR (68:379)
            margin: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 0 * fem, 0 * fem),
            width: 45 * fem,
            height: 40 * fem,
            child: Image.asset(
              'assets/page-1/images/vector-6X3.png',
              width: 45 * fem,
              height: 40 * fem,
            ),
          ),
        ],
      ),
    );
  }
}

class Date extends StatelessWidget {
  const Date({
    super.key,
    required this.fem,
    required this.ffem,
  });

  final double fem;
  final double ffem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(17 * fem, 20 * fem, 20 * fem, 16 * fem),
      width: double.infinity,
      height: 88 * fem,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(24 * fem),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.background,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // nounheart59027222xvD (34:169)
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 11 * fem, 0 * fem),
            width: 51 * fem,
            height: 46 * fem,
            child: Image.asset(
              'assets/page-1/images/noun-heart-59-0272-2-2.png',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            // autogroup3nthGvu (2RBzsfi8fN6bLXXWWx3NtH)
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  // jan1D5T (34:166)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 5 * fem),
                  child: Text(
                    'Jan 1',
                    style: SafeGoogleFont(
                      'Inter',
                      fontSize: 22 * ffem,
                      fontWeight: FontWeight.w400,
                      height: 1.2125 * ffem / fem,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                ),
                Text(
                  // Hr1 (34:168)
                  '2023',
                  style: SafeGoogleFont(
                    'Inter',
                    fontSize: 16 * ffem,
                    fontWeight: FontWeight.w400,
                    height: 1.2125 * ffem / fem,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.fem,
  });

  final double fem;

  @override
  Widget build(BuildContext context) {
    return Container(
      // group25P2Z (73:416)
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 37 * fem),
      padding: EdgeInsets.fromLTRB(118 * fem, 44 * fem, 112 * fem, 11 * fem),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Align(
        // 2rD (36:231)
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: 160 * fem,
          height: 34 * fem,
          child: Image.asset(
            'assets/page-1/images/-Q8H.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
