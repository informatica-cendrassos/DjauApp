import 'package:cendrassos/config_djau.dart';
import 'package:cendrassos/api/exceptions.dart';
import 'package:cendrassos/screens/components/preview_helpers.dart';
import 'package:cendrassos/utils/global_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

@Preview(name: 'ErrorRetry')
Widget previewErrorRetry() => previewWithTheme(
      child: const Scaffold(
        body: ErrorRetry(
          errorType: 'Error de connexio',
          errorMessage: 'No s\'ha pogut obtenir la informacio.',
          textBoto: missatgeTornaAProvar,
          onRetryPressed: _noop,
        ),
      ),
    );

@Preview(name: 'ErrorRetryLogin')
Widget previewErrorRetryLogin() => previewWithTheme(
      child: const Scaffold(
        body: ErrorRetryLogin(
          errorType: 'Sessio caducada',
          errorMessage: 'Torna a iniciar sessio per continuar.',
          onRetryPressed: _noop,
          onLogin: _noop,
        ),
      ),
    );

@Preview(name: 'Loading Widget')
Widget previewLoadingWidget() => previewWithTheme(
      child: const Scaffold(
        body: Loading(
          loadingMessage: 'Carregant dades...',
        ),
      ),
    );

void _noop() {}

bool _isUnauthorised(String errorType) =>
    errorType.trim() == notAuthorizedExceptionMessage.trim();

Future<void> showAppErrorDialog(BuildContext context, Object error) {
  final errorType =
      error is AppException ? error.prefix().trim() : defaultErrorMessage;
  final errorMessage =
      error is AppException ? error.message().trim() : undefinedError;

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(errorType.isEmpty ? defaultErrorMessage : errorType),
      content: Text(errorMessage.isEmpty ? undefinedError : errorMessage),
      actions: [
        if (error is UnauthorisedException)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              GlobalNavigator.gotoLoginPageWithPop();
            },
            child: const Text(missatgeTornaALogin),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(missatgeOk),
        ),
      ],
    ),
  );
}

class ErrorRetry extends StatelessWidget {
  final String errorType;
  final String errorMessage;
  final String textBoto;
  final VoidCallback onRetryPressed;

  const ErrorRetry(
      {super.key,
      required this.errorType,
      required this.errorMessage,
      required this.textBoto,
      required this.onRetryPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 10),
            child: Column(
              children: [
                Text(
                  errorType,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 22,
                ),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 22,
          ),
          ElevatedButton(
              onPressed: onRetryPressed,
              child: const Text(
                missatgeOk,
              )),
          if (_isUnauthorised(errorType)) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: GlobalNavigator.gotoLoginPageWithPop,
              child: const Text(missatgeTornaALogin),
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorRetryLogin extends StatelessWidget {
  final String errorMessage;
  final String errorType;
  final VoidCallback onRetryPressed;
  final VoidCallback onLogin;

  const ErrorRetryLogin(
      {super.key,
      required this.errorType,
      required this.errorMessage,
      required this.onRetryPressed,
      required this.onLogin});

  Widget _boto(BuildContext context, String text, VoidCallback metode) {
    return ElevatedButton(
      onPressed: metode,
      child: Text(
        text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 10),
            child: Column(
              children: [
                Text(
                  errorType,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _boto(context, missatgeTornaAProvar, onRetryPressed),
              const SizedBox(height: 10),
              _boto(context, missatgeTornaALogin, onLogin),
            ],
          ),
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  final String loadingMessage;

  const Loading({super.key, required this.loadingMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColorLight),
          ),
        ],
      ),
    );
  }
}

String convertirDataPeninsular(BuildContext context, String textData) {
  var data = _parseFlexibleDate(textData);

  return " ${DateFormat('d MMMM hh:mm', Localizations.localeOf(context).toString()).format(data)}";
}

String convertirDataAmerica(BuildContext context, String textData) {
  var data = _parseFlexibleDate(textData);

  return convertirDataAmericaDate(context, data);
}

String convertirDataAmericaDate(BuildContext context, DateTime data) {
  return " ${DateFormat('d MMMM hh:mm', Localizations.localeOf(context).toString()).format(data)}";
}

DateTime _parseFlexibleDate(String rawValue) {
  final value = rawValue.trim();

  final formats = <String>[
    'yyyy-MM-dd HH:mm:ss',
    'yyyy-MM-dd HH:mm',
    'yyyy/MM/dd HH:mm:ss',
    'yyyy/MM/dd HH:mm',
    'dd/MM/yyyy HH:mm:ss',
    'dd/MM/yyyy HH:mm',
  ];

  for (final pattern in formats) {
    try {
      return DateFormat(pattern).parseStrict(value);
    } catch (_) {
      // Try next known format.
    }
  }

  throw FormatException('No s\'ha pogut interpretar la data: $rawValue');
}
