import 'package:fedcampus/models/user_model.dart';
import 'package:fedcampus/utility/log.dart';
import 'package:fedcampus/view/home.dart';
import 'package:fedcampus/view/me/user_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//make sure you use a context that contains a Navigator instance as parent.
//https://stackoverflow.com/a/51292613
void main() {
  // https://stackoverflow.com/a/57775690
  WidgetsFlutterBinding.ensureInitialized();
  userApi.init().then((e) => runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MyAppState(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserModel(),
          ),
        ],
        child: const MyApp(),
      )));
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

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return MaterialApp(
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
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 229, 85, 85),
          primary: Colors.black,
          primaryContainer: const Color.fromARGB(255, 229, 85, 85),
          secondary: const Color.fromARGB(255, 217, 217, 217),
          secondaryContainer: const Color.fromARGB(255, 206, 229, 109),
          tertiary: const Color.fromARGB(102, 0, 0, 0),
          tertiaryContainer: const Color.fromARGB(255, 174, 197, 242),
          surfaceTint: const Color.fromARGB(255, 249, 255, 231),
          surfaceVariant: const Color.fromARGB(255, 132, 139, 218),
          surface: const Color.fromARGB(85, 165, 187, 231),
          shadow: const Color.fromARGB(38, 229, 85, 85),
          outline: const Color.fromARGB(25, 0, 0, 0),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: appState.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
      home: const HomeRoute(),
    );
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
