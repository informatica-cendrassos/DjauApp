import 'package:cendrassos/models/alumne.dart';
import 'package:cendrassos/models/sortida.dart';
import 'package:cendrassos/models/tutor.dart';
import 'package:cendrassos/providers/djau.dart';
import 'package:cendrassos/screens/sortida_detail_page.dart';
import 'package:cendrassos/screens/sortides_page.dart';
import 'package:cendrassos/screens/users_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class FakeDjauModel extends DjauModel {
  FakeDjauModel(this._sortida) {
    tutor = Tutor('demo', 'demo', 'token');
    alumne = Alumne(1, 'Nom', 'Cognoms');
  }

  final Sortida _sortida;

  @override
  Future<Sortida> loadSortida(int id, int alumneId) async {
    return _sortida;
  }
}

Widget buildTestApp(DjauModel model) {
  return ChangeNotifierProvider<DjauModel>.value(
    value: model,
    child: MaterialApp(
      initialRoute: SortidaDetailPage.routeName,
      onGenerateRoute: (settings) {
        if (settings.name == SortidaDetailPage.routeName) {
          return MaterialPageRoute(
            settings: const RouteSettings(
              name: SortidaDetailPage.routeName,
              arguments: {'id': 7},
            ),
            builder: (_) => const SortidaDetailPage(),
          );
        }
        if (settings.name == UsersPage.routeName) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('USERS_SCREEN')),
          );
        }
        if (settings.name == SortidesPage.routeName) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('SORTIDES_SCREEN')),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const SizedBox.shrink(),
        );
      },
    ),
  );
}

void main() {
  group('SortidaDetailPage payment button', () {
    testWidgets(
      'disables pay button when payment deadline is before today',
      (tester) async {
        final sortidaLimitPassat = Sortida(
          'Sortida passada',
          '2999-01-10 09:00:00',
          '2999-01-10 14:00:00',
          'Programa',
          '12.50',
          '2020-01-01 23:59:59',
          false,
          123,
        );

        await tester
            .pumpWidget(buildTestApp(FakeDjauModel(sortidaLimitPassat)));
        await tester.pumpAndSettle();

        final payButtonFinder = find.widgetWithText(ElevatedButton, 'Pagar');
        expect(payButtonFinder, findsOneWidget);

        final payButton = tester.widget<ElevatedButton>(payButtonFinder);
        expect(payButton.onPressed, isNull);
      },
    );

    testWidgets(
      'keeps pay button enabled when outing date is past but payment deadline is future',
      (tester) async {
        final sortidaPassadaDeadlineFutur = Sortida(
          'Sortida passada',
          '2020-01-10 09:00:00',
          '2020-01-10 14:00:00',
          'Programa',
          '12.50',
          '2999-12-31 23:59:59',
          false,
          123,
        );

        await tester.pumpWidget(
          buildTestApp(FakeDjauModel(sortidaPassadaDeadlineFutur)),
        );
        await tester.pumpAndSettle();

        final payButtonFinder = find.widgetWithText(ElevatedButton, 'Pagar');
        expect(payButtonFinder, findsOneWidget);

        final payButton = tester.widget<ElevatedButton>(payButtonFinder);
        expect(payButton.onPressed, isNotNull);
      },
    );
  });
}
