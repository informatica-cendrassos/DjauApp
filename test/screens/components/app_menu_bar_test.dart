import 'dart:async';

import 'package:cendrassos/api/exceptions.dart';
import 'package:cendrassos/screens/components/app_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildHarness({
    bool qualitativeEvaluationVisible = false,
    Future<void> Function()? onQualitativeEvaluation,
  }) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppMenuBar(
          nom: 'Alumne de prova',
          haveleading: false,
          gotoUserPage: null,
          gotoSortides: null,
          qualitativeEvaluationVisible: qualitativeEvaluationVisible,
          onQualitativeEvaluation: onQualitativeEvaluation,
        ),
      ),
    );
  }

  testWidgets('hides the qualitative evaluation button when unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(buildHarness());

    expect(
      find.byKey(const Key('qualitative-evaluation-button')),
      findsNothing,
    );
  });

  testWidgets('shows the qualitative evaluation button when available', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        qualitativeEvaluationVisible: true,
        onQualitativeEvaluation: () async {},
      ),
    );

    expect(
      find.byKey(const Key('qualitative-evaluation-button')),
      findsOneWidget,
    );
    expect(find.byTooltip('Avaluació qualitativa'), findsOneWidget);
  });

  testWidgets('prevents duplicate PDF actions while one is running', (
    tester,
  ) async {
    final completer = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      buildHarness(
        qualitativeEvaluationVisible: true,
        onQualitativeEvaluation: () {
          calls++;
          return completer.future;
        },
      ),
    );

    final button = find.byKey(const Key('qualitative-evaluation-button'));
    await tester.tap(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();

    expect(calls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows a Catalan error dialog when opening the PDF fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        qualitativeEvaluationVisible: true,
        onQualitativeEvaluation: () async {
          throw OpenDocumentException('No hi ha cap visor de PDF disponible.');
        },
      ),
    );

    await tester.tap(find.byKey(const Key('qualitative-evaluation-button')));
    await tester.pump();
    await tester.pump();

    expect(find.text('ERROR'), findsOneWidget);
    expect(find.text('No hi ha cap visor de PDF disponible.'), findsOneWidget);
    expect(find.text('D\'acord'), findsOneWidget);
  });
}
