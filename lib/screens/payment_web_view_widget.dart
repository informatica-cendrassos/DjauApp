import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewWidget extends StatefulWidget {
  final String url;
  final String token;

  const PaymentWebViewWidget(
      {super.key, required this.url, required this.token});

  @override
  State<PaymentWebViewWidget> createState() => _PaymentWebViewWidgetState();
}

class _PaymentWebViewWidgetState extends State<PaymentWebViewWidget> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void didUpdateWidget(covariant PaymentWebViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.token != widget.token) {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    setState(() {
      _isLoading = true;
      _initializationError = null;
    });

    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _initializationError = error.description;
                });
              }
            },
          ),
        );

      _controller = controller;
      controller.loadRequest(
        Uri.parse(widget.url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _controller = null;
          _initializationError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializationError != null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'No s\'ha pogut inicialitzar la passarel·la de pagament.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _initializationError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeWebView,
                  child: const Text('Tornar-ho a provar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_controller == null) {
      return SafeArea(
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    return SafeArea(
      child: Stack(
        children: [
          WebViewWidget(controller: _controller!),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
