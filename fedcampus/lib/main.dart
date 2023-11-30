import 'package:fedcampus/models/activity_data_model.dart';
import 'package:fedcampus/models/health_data_model.dart';
import 'package:fedcampus/models/user_model.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/utility/global.dart';
import 'package:fedcampus/view/navigator.dart';
import 'package:fedcampus/view/splash.dart';
import 'package:fedcampus/view/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'utility/event_bus.dart';

//make sure you use a context that contains a Navigator instance as parent.
//https://stackoverflow.com/a/51292613

void main() {
  // https://stackoverflow.com/a/57775690
  WidgetsFlutterBinding.ensureInitialized();
  userApi
      .init()
      .then((e) => runApp(MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => MyAppState(),
              ),
              ChangeNotifierProvider(
                create: (context) => UserModel(),
              ),
              ChangeNotifierProvider(
                create: (context) => HealthDataModel(),
              ),
              ChangeNotifierProvider(
                create: (context) => ActivityDataModel(),
              ),
            ],
            child: const MyApp(),
          )))
      .onError((Exception error, stackTrace) => runApp(ErrorApp(
            error: error,
          )));
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key, required this.error});

  final Exception error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Error :(')),
        body: Text(error.getMessage),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initSettings(context);
  }

  void initSettings(BuildContext context) async {
    // receives all toast error message from the beginning of the app
    initEventBus(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    MyAppState myAppState = Provider.of<MyAppState>(context, listen: false);
    // dark mode settings:
    // if dark mode is not set in shared preferences, default to systemwide preferences
    bool systemIsDark;
    if (MediaQuery.platformBrightnessOf(context) == Brightness.light) {
      systemIsDark = false;
    } else {
      systemIsDark = true;
    }
    bool isDark = prefs.getBool('isDarkModeOn') ?? systemIsDark;
    myAppState.toggleTheme(isDark);
    // locale settings
    String localeString = prefs.getString('locale') ?? 'en_US';
    Locale locale;
    try {
      locale = Locale(localeString.split('_')[0], localeString.split('_')[1]);
    } catch (e) {
      locale = const Locale('en', 'US');
      logger.e(e);
    }
    myAppState.setLocale(locale);
  }

  void initEventBus(BuildContext context) {
    bus.on("toast_error", (arg) {
      showToastMessage(arg, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // https: //stackoverflow.com/a/50884081
    // disable landsacpe orientation because we do not need it
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var appState = context.watch<MyAppState>();
    return MaterialApp(
      builder: (context, widget) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          // https://stackoverflow.com/a/69336477
          // override textScaleFactor to 1
          // this is a good feature (also error-prone), sadly it is not implemented now
          data: mediaQueryData.copyWith(textScaler: TextScaler.noScaling),
          child: widget!,
        );
      },
      title: 'Fedcampus Flutter',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
        Locale('ja', 'JP'),
      ],
      locale: appState.locale,
      theme: ThemeData(
        dialogBackgroundColor: Colors.white,
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 229, 85, 85),
          background: const Color.fromARGB(255, 255, 255, 255),
          onBackground: const Color.fromARGB(255, 255, 255, 255),
          inversePrimary: const Color.fromARGB(255, 255, 255, 255),
          primary: Colors.black,
          primaryContainer: const Color.fromARGB(255, 229, 85, 85),
          onPrimaryContainer: const Color.fromARGB(255, 254, 232, 232),
          secondary: const Color.fromARGB(102, 0, 0, 0),
          surfaceTint: const Color.fromARGB(255, 249, 255, 231),
          onSecondary: const Color.fromARGB(255, 82, 75, 75),
          secondaryContainer: const Color.fromARGB(255, 206, 229, 109),
          onSecondaryContainer: const Color.fromARGB(255, 176, 196, 93),
          tertiaryContainer: const Color.fromARGB(255, 174, 197, 242),
          onTertiaryContainer: const Color.fromARGB(255, 132, 139, 218),
          surface: const Color.fromARGB(85, 165, 187, 231),
          shadow: const Color.fromARGB(38, 229, 85, 85),
          outline: const Color.fromARGB(25, 0, 0, 0),
          onPrimary: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        dialogBackgroundColor: const Color.fromARGB(255, 24, 24, 26),
        brightness: Brightness.dark,
        useMaterial3: false,
        colorScheme: const ColorScheme.dark(
          background: Color.fromARGB(255, 24, 24, 26),
          onBackground: Color.fromARGB(255, 53, 53, 57),
          primary: Color.fromARGB(255, 249, 255, 231),
          primaryContainer: Color.fromARGB(255, 242, 116, 116),
          onPrimaryContainer: Color.fromARGB(255, 53, 53, 60),
          surfaceTint: Color.fromARGB(255, 63, 63, 67),
          secondary: Color.fromARGB(255, 243, 219, 135),
          onSecondary: Color.fromARGB(255, 174, 166, 166),
          secondaryContainer: Color.fromARGB(255, 206, 229, 109),
          onSecondaryContainer: Color.fromARGB(255, 176, 196, 93),
          tertiaryContainer: Color.fromARGB(255, 174, 197, 242),
          onTertiaryContainer: Color.fromARGB(255, 132, 139, 240),
          shadow: Color.fromARGB(38, 75, 85, 125),
          outline: Color.fromARGB(25, 0, 0, 0),
          onPrimary: Color.fromARGB(255, 5, 5, 5),
        ),
      ),
      themeMode: appState.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
      home: startUpPage(),
    );
  }

  StatefulWidget startUpPage() {
    String? splashScreenPolicy = userApi.prefs.getString("slpash_screen");
    switch (splashScreenPolicy) {
      case "always": // default
        return const Splash();
      case "is_logged_in":
        return (userApi.prefs.getBool("login") ?? false)
            ? const BottomNavigator()
            : const Splash();
      case "never":
        return const BottomNavigator();
      default:
        return const Splash();
    }
  }
}

class MyAppState extends ChangeNotifier {
  Locale locale = const Locale('en', 'US');
  bool isDarkModeOn = false;

  void toggleTheme(bool b) {
    isDarkModeOn = b;
    notifyListeners();
  }

  void setLocale(Locale value) {
    locale = value;
    notifyListeners();
  }

  void resetPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }
}
