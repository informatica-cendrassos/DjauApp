import 'dart:io';

import 'package:cendrassos/config_djau.dart';
import 'package:cendrassos/providers/djau.dart';
import 'package:cendrassos/screens/components/preview_helpers.dart';
import 'package:cendrassos/screens/components/helpers.dart';
import 'package:cendrassos/screens/dashboard_page.dart';
import 'package:cendrassos/screens/login_page.dart';
import 'package:cendrassos/screens/users_page.dart';
import 'package:cendrassos/utils/global_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widget_previews.dart';

@Preview(name: 'LoadingPage')
Widget previewLoadingPage() => previewWithDjauModel(child: const LoadingPage());

class LoadingPage extends StatefulWidget {
  static const routeName = '/loading';

  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  static String carregant = missatgeCarregantDades;
  String _message = carregant;
  String _errorMessage = "";
  String _errorType = "";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    String initialRoute = UsersPage.routeName;
    setState(() {
      _message = carregant;
      _errorMessage = "";
      _errorType = "";
    });

    var djau = Provider.of<DjauModel>(context, listen: false);
    // - Si: Carregar el darrer alumne i mirar si pot fer login
    var desti = await djau.determineInitialPage();

    if (djau.isError()) {
      setState(() {
        _message = "";
        _errorMessage = djau.errorMessage;
        _errorType = djau.errorType;
      });
      return;
    }

    switch (desti) {
      case 0: // No hi ha tutor, demanar login
        GlobalNavigator.gotoLoginPageWithPop();
        break;
      case 1: // Hi ha tutor. S'ha de mirar si pot entrar
        await djau.loginWithStoredCredentials();
        if (djau.isLogged()) {
          try {
            await djau.loadDefaultAlumne();
            initialRoute = Dashboard.routeName;
          } catch (e) {
            // No s'ha pogut carregar l'alumne per defecte,
            // però com que s'ha fet login correcte,
            // enviar a la llista d'alumnes
            initialRoute = UsersPage.routeName;
          }
        } else {
          // No s'ha pogut fer login, les credencials són
          // incorrectes,anar a la pantalla de login
          // per tornar a demanar les credencials
          initialRoute = LoginPage.routeName;
        }
        GlobalNavigator.forgetAndGo(initialRoute);
        break;
    }
  }

  // redirigeix a la pantalla de login.
  // Es fa servir quan hi ha un error perquè es pugui
  // tornar a intentar fer login
  void _gotoLogin() {
    var route = UsersPage.routeName;
    if (!Platform.isAndroid && !Platform.isIOS) {
      route = LoginPage.routeName;
    }
    GlobalNavigator.forgetAndGo(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = (constraints.maxHeight * 0.25).clamp(120.0, 260.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/icon.png',
                        height: iconSize,
                        width: iconSize,
                      ),

                      /// Loader Animation Widget
                      _errorMessage.isEmpty
                          ? Loading(loadingMessage: _message)
                          : ErrorRetryLogin(
                              errorType: _errorType,
                              errorMessage: _errorMessage,
                              onRetryPressed: _load,
                              onLogin: _gotoLogin,
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
