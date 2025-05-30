import 'package:fedcampus/pigeon/datawrapper.dart';
import 'package:fedcampus/view/stats.dart';
import 'package:fedcampus/view/me.dart';
import 'package:fedcampus/view/widgets/sliding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utility/log.dart';
import 'health.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const Health(),
    const Activity(),
    const Me()
  ];

  @override
  void initState() {
    super.initState();
    sendFAData();
  }

  Color getAppBarColor(int index, BuildContext context) {
    switch (index) {
      case 0:
        return Theme.of(context).colorScheme.primaryContainer;
      case 1:
        return Theme.of(context).colorScheme.secondaryContainer;
      case 2:
        return Theme.of(context).colorScheme.tertiaryContainer;
      default:
        return Theme.of(context).colorScheme.primaryContainer;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void spawnTraining() async {
    var dw = DataWrapper();
    final now = DateTime.now();
    final dateNumber = now.year * 10000 + now.month * 100 + now.day;
    dw.getDataAndTrain(dateNumber);
  }

  void sendFAData() async {
    var dw = DataWrapper();
    var now = DateTime.now().add(const Duration(days: -1));
    var dateNumber = now.year * 10000 + now.month * 100 + now.day;
    while (true) {
      now = DateTime.now().add(const Duration(days: -1));
      dateNumber = now.year * 10000 + now.month * 100 + now.day;
      try {
        await dw.getDayDataAndSendAndTrain(dateNumber);
      } on Exception catch (e) {
        logger.w(e);
      }
      await Future.delayed(const Duration(hours: 3));
    }
  }

  Widget _getSlidingPage(int idx) {
    logger.e(idx);
    return switch (idx) {
      0 => const HealthSlidingPages(),
      1 => const StatsSlidingPages(),
      _ => const HealthSlidingPages()
    };
  }

  void helpDialog() {
    double pixel = MediaQuery.of(context).size.width / 400;
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Guide"),
          contentPadding:
              EdgeInsets.fromLTRB(10 * pixel, 0 * pixel, 10 * pixel, 0),
          content: SizedBox(
            height: 280 * pixel,
            // [AlertDialog] calls `IntrinsicWidth` therefore [ListView], [GridView],
            // and [PageView] have to be wrapped in `SizedBox` to ensure it has width
            // https://github.com/flutter/flutter/issues/19613
            width: 350 * pixel,
            child: _getSlidingPage(_selectedIndex),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    TextStyle textStyle = TextStyle(
      fontSize: 13 * pixel,
      fontFamily: 'Noto Sans',
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50 * pixel,
        backgroundColor: getAppBarColor(_selectedIndex, context),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/title.png',
          height: 35 * pixel,
        ),
        actions: [
          if (_selectedIndex == 0 || _selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.question_mark_rounded),
              tooltip: 'Help',
              onPressed: helpDialog,
            ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      // https://stackoverflow.com/a/55174433
      bottomNavigationBar: BottomNavigationBar(
        unselectedLabelStyle: textStyle,
        selectedLabelStyle: textStyle,
        // https://stackoverflow.com/a/57126622
        items: [
          BottomNavigationBarItem(
            label: AppLocalizations.of(context)!.navigator_health,
            icon: const NavIcon(
              imagePath: 'assets/images/health_nav_icon.png',
              color: Colors.grey,
            ),
            activeIcon:
                const NavIcon(imagePath: 'assets/images/health_nav_icon.png'),
          ),
          BottomNavigationBarItem(
            label: AppLocalizations.of(context)!.navigator_stats,
            icon: const NavIcon(
              imagePath: 'assets/images/activity_nav_icon.png',
              color: Colors.grey,
            ),
            activeIcon:
                const NavIcon(imagePath: 'assets/images/activity_nav_icon.png'),
          ),
          BottomNavigationBarItem(
            label: AppLocalizations.of(context)!.navigator_account,
            icon: const NavIcon(
              imagePath: 'assets/images/me_nav_icon.png',
              color: Colors.grey,
            ),
            activeIcon:
                const NavIcon(imagePath: 'assets/images/me_nav_icon.png'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (i) => _onItemTapped(i),
        selectedItemColor: getAppBarColor(_selectedIndex, context),
      ),
    );
  }
}

class NavIcon extends StatelessWidget {
  const NavIcon({
    super.key,
    required this.imagePath,
    this.color,
  });

  final String imagePath;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    double pixel = MediaQuery.of(context).size.width / 400;
    return SizedBox(
      width: 32 * pixel,
      height: 32 * pixel,
      child: Image.asset(
        imagePath,
        color: color,
        fit: BoxFit.contain,
      ),
    );
  }
}
