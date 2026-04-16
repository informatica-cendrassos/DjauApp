import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:cendrassos/screens/components/app_menu_bar.dart';
import 'package:cendrassos/screens/sortides_page.dart';
import 'package:cendrassos/screens/users_page.dart';

class SortidaWebViewPage extends StatefulWidget {
  final String url;

  const SortidaWebViewPage({super.key, required this.url});

  @override
  State<SortidaWebViewPage> createState() => _SortidaWebViewPageState();
}

class _SortidaWebViewPageState extends State<SortidaWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppMenuBar(
        nom: "Pagaments",
        haveleading: true,
        gotoUserPage: () =>
            Navigator.of(context).pushNamed(UsersPage.routeName),
        gotoSortides: () =>
            Navigator.of(context).pushNamed(SortidesPage.routeName),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
