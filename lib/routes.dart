import 'package:cendrassos/djau_theme.dart';
import 'package:cendrassos/providers/djau.dart';
import 'package:cendrassos/screens/dashboard_page.dart';
import 'package:cendrassos/screens/loading_page.dart';
import 'package:cendrassos/screens/login_page.dart';
import 'package:cendrassos/screens/profile_page.dart';
import 'package:cendrassos/screens/sortida_detail_page.dart';
import 'package:cendrassos/screens/sortides_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cendrassos/screens/users_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config_djau.dart';
import 'navitator_key.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({required this.initialRoute, super.key});

  static final Map<String, WidgetBuilder> routes = {
    LoginPage.routeName: (context) => const LoginPage(),
    Dashboard.routeName: (context) => const Dashboard(),
    LoadingPage.routeName: (context) => const LoadingPage(),
    UsersPage.routeName: (context) => UsersPage(),
    ProfilePage.routeName: (context) => const ProfilePage(),
    SortidesPage.routeName: (context) => const SortidesPage(),
    SortidaDetailPage.routeName: (context) => const SortidaDetailPage(),
  };

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DjauModel()),
        Provider<BuildContext>(create: (c) => c),
      ],
      child: MaterialApp(
        title: nomInstitut,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale("ca", "ES"),
        supportedLocales: const [
          Locale("ca", "ES"),
        ],
        theme: cendrassosTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        initialRoute: initialRoute,
        routes: routes,
      ),
    );
  }
}
