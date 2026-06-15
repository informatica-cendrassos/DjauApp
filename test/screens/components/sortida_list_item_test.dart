import 'package:cendrassos/models/resum_sortida.dart';
import 'package:cendrassos/screens/components/sortida_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders fallback text when outing date is missing', (
    tester,
  ) async {
    final sortida = ResumSortida(7, 'Sortida sense data', '', true, false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SortidaListItem(
            sortida: sortida,
            showDetail: (_, __) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Data pendent de confirmar'), findsOneWidget);
  });
}
