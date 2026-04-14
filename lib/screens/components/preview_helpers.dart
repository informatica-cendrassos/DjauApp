import 'package:cendrassos/djau_theme.dart';
import 'package:cendrassos/providers/djau.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget previewWithTheme({required Widget child}) {
  return MaterialApp(
    theme: cendrassosTheme,
    home: child,
  );
}

Widget previewPage({
  PreferredSizeWidget? appBar,
  required Widget body,
  Widget? floatingActionButton,
}) {
  return previewWithTheme(
    child: Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
    ),
  );
}

Widget previewWithDjauModel({required Widget child}) {
  return ChangeNotifierProvider(
    create: (_) => DjauModel(),
    child: previewWithTheme(child: child),
  );
}

Widget previewPageWithDjauModel({
  PreferredSizeWidget? appBar,
  required Widget body,
  Widget? floatingActionButton,
}) {
  return previewWithDjauModel(
    child: Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
    ),
  );
}
