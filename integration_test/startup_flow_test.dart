import 'package:cendrassos/navitator_key.dart';
import 'package:cendrassos/providers/djau.dart';
import 'package:cendrassos/screens/dashboard_page.dart';
import 'package:cendrassos/screens/loading_page.dart';
import 'package:cendrassos/screens/login_page.dart';
import 'package:cendrassos/screens/users_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

class ScriptedDjauModel extends DjauModel {
  ScriptedDjauModel({
    required this.initialPages,
    required this.storedLoginResults,
    this.loadDefaultAlumneShouldThrow = false,
  });

  final List<int> initialPages;
  final List<LoginResult> storedLoginResults;
  final bool loadDefaultAlumneShouldThrow;

  int _initialIndex = 0;
  int _storedLoginIndex = 0;
  bool _logged = false;
  bool _error = false;

  @override
  Future<int> determineInitialPage() async {
    final page = initialPages[_initialIndex < initialPages.length
        ? _initialIndex
        : initialPages.length - 1];
    _initialIndex++;
    _error = false;
    return page;
  }

  @override
  Future<LoginResult> loginWithStoredCredentials() async {
    final result = storedLoginResults[
        _storedLoginIndex < storedLoginResults.length
            ? _storedLoginIndex
            : storedLoginResults.length - 1];
    _storedLoginIndex++;
    _logged = result.isLogged == DjauStatus.loaded;
    _error = result.isLogged == DjauStatus.error;
    errorType = result.errorType;
    errorMessage = result.errorMessage;
    return result;
  }

  @override
  bool isLogged() => _logged;

  @override
  bool isError() => _error;

  @override
  Future loadDefaultAlumne() async {
    if (loadDefaultAlumneShouldThrow) {
      throw Exception('No default alumne');
    }
  }
}

Widget buildHarness(DjauModel model) {
  return ChangeNotifierProvider<DjauModel>.value(
    value: model,
    child: MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: LoadingPage.routeName,
      routes: {
        LoadingPage.routeName: (_) => const LoadingPage(),
        LoginPage.routeName: (_) => const Scaffold(
              body: Center(child: Text('LOGIN_SCREEN')),
            ),
        UsersPage.routeName: (_) => const Scaffold(
              body: Center(child: Text('USERS_SCREEN')),
            ),
        Dashboard.routeName: (_) => const Scaffold(
              body: Center(child: Text('DASHBOARD_SCREEN')),
            ),
      },
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Startup flow with stored credentials', () {
    testWidgets(
        'goes to users when stored login succeeds but no default alumne',
        (tester) async {
      final model = ScriptedDjauModel(
        initialPages: [1],
        storedLoginResults: [
          LoginResult(DjauStatus.loaded, '', ''),
        ],
        loadDefaultAlumneShouldThrow: true,
      );

      await tester.pumpWidget(buildHarness(model));
      await tester.pumpAndSettle();

      expect(find.text('USERS_SCREEN'), findsOneWidget);
      expect(find.text('LOGIN_SCREEN'), findsNothing);
    });

    testWidgets('goes to login when stored credentials are unauthorized',
        (tester) async {
      final model = ScriptedDjauModel(
        initialPages: [1],
        storedLoginResults: [
          LoginResult(
            DjauStatus.error,
            'No Autoritzat:',
            'Credencials caducades',
          ),
        ],
      );

      await tester.pumpWidget(buildHarness(model));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
      expect(find.text('USERS_SCREEN'), findsNothing);
    });

    testWidgets('goes to login when there is no stored user', (tester) async {
      final model = ScriptedDjauModel(
        initialPages: [0],
        storedLoginResults: const [],
      );

      await tester.pumpWidget(buildHarness(model));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
    });
  });
}
