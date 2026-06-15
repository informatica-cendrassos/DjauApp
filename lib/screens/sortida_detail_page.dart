import 'package:cendrassos/api/exceptions.dart';
import 'package:cendrassos/config_djau.dart';
import 'package:cendrassos/djau_theme.dart';
import 'package:cendrassos/models/sortida.dart';
import 'package:cendrassos/providers/djau.dart';
import 'package:cendrassos/screens/components/app_menu_bar.dart';
import 'package:cendrassos/screens/components/helpers.dart';
import 'package:cendrassos/screens/components/preview_helpers.dart';
import 'package:cendrassos/screens/payment_web_view_widget.dart';
import 'package:cendrassos/screens/sortides_page.dart';
import 'package:cendrassos/screens/users_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';

@Preview(name: 'Sortida Detail (Mock)')
Widget previewSortidaDetailPage() =>
    previewWithTheme(child: const _SortidaDetailPagePreview());

class _SortidaDetailPagePreview extends StatelessWidget {
  const _SortidaDetailPagePreview();

  @override
  Widget build(BuildContext context) {
    final sampleSortida = Sortida(
      'Sortida al Museu de la Ciencia',
      '2026-04-22 09:00:00',
      '2026-04-22 14:00:00',
      'Visita guiada i taller practic de tecnologia.',
      '12.50',
      '2026-04-20 23:59:59',
      false,
      1001,
    );

    return previewPage(
      appBar: const AppMenuBar(
        nom: 'Pagaments',
        haveleading: true,
        gotoUserPage: null,
        gotoSortides: null,
      ),
      body: Builder(
        builder: (innerContext) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: MediaQuery.of(innerContext).size.width * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(innerContext).size.height * 0.7,
                    child: SortidaDescription(
                      sortida: sampleSortida,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(innerContext).secondaryHeaderColor,
                          backgroundColor: Theme.of(innerContext).primaryColor),
                      onPressed: () {},
                      child: const Text('Pagar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SortidaDetailPage extends StatefulWidget {
  final int id;
  const SortidaDetailPage({super.key, this.id = 0});

  static const routeName = '/sortida';

  @override
  State<SortidaDetailPage> createState() => _SortidaDetailPageState();
}

class _SortidaDetailPageState extends State<SortidaDetailPage> {
  String? _paymentUrl;
  String? _token;

  @override
  Widget build(BuildContext context) {
    final djau = Provider.of<DjauModel>(context, listen: false);
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    return Scaffold(
      appBar: AppMenuBar(
        nom: "Pagaments",
        haveleading: true,
        gotoUserPage: () =>
            {Navigator.of(context).pushNamed(UsersPage.routeName)},
        gotoSortides: () =>
            {Navigator.of(context).pushNamed(SortidesPage.routeName)},
      ),
      body: _paymentUrl != null && _token != null
          ? PaymentWebViewWidget(url: _paymentUrl!, token: _token!)
          : SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      FutureBuilder<Sortida>(
                          future:
                              djau.loadSortida(arguments['id'], djau.alumne.id),
                          builder: (BuildContext build,
                              AsyncSnapshot<Sortida> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              return showData(
                                  context, snapshot.data as Sortida);
                            } else if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasError) {
                              final error = snapshot.error;
                              final errorType = error is AppException
                                  ? error.prefix()
                                  : defaultErrorMessage;
                              final errorMessage = error is AppException
                                  ? error.message()
                                  : error?.toString() ?? undefinedError;
                              return ErrorRetry(
                                errorType: errorType,
                                errorMessage: errorMessage,
                                textBoto: missatgeOk,
                                onRetryPressed: () => Navigator.pop(context),
                              );
                            } else {
                              return const Loading(
                                  loadingMessage: missatgeCarregantDades);
                            }
                          }),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget showData(BuildContext context, Sortida data) {
    var width = MediaQuery.of(context).size.width * 0.9;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: SortidaDescription(
              sortida: data,
            ),
          ),
          showButton(width, data, context)
        ],
      ),
    );
  }

  Container showButton(double width, Sortida sortida, BuildContext context) {
    final djau = Provider.of<DjauModel>(context, listen: false);
    final now = DateTime.now();
    final canPay = !sortida.realitzat && !sortida.isBefore(now);

    if (sortida.idPagament == null) {
      return Container();
    }
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).secondaryHeaderColor,
              backgroundColor: Theme.of(context).primaryColor),
          onPressed: canPay
              ? () {
                  debugPrint(
                    'Pagar premut: titol=${sortida.titol}, idPagament=${sortida.idPagament}, realitzat=${sortida.realitzat}',
                  );
                  setState(() {
                    _paymentUrl =
                        "$baseUrl$pathPagamentSortides${sortida.idPagament}/";
                    _token = djau.tutor.token;
                    debugPrint(
                      'Obrint WebView: paymentUrl=$_paymentUrl, tokenPresent=${_token != null}',
                    );
                  });
                }
              : null,
          child: const Text(
            'Pagar',
          )),
    );
  }
}

class SortidaDescription extends StatelessWidget {
  const SortidaDescription({
    super.key,
    required this.sortida,
  });

  final Sortida sortida;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                sortida.titol,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.apply(color: backgroundColor),
              ),
            ),
          ),
          ListTile(
            tileColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
                (sortida.preu != "0") ? "${sortida.preu} €" : "gratuita",
                style: Theme.of(context).textTheme.titleLarge),
            subtitle: Text(
                "${convertirDataPeninsular(context, sortida.desde)}\n${convertirDataPeninsular(context, sortida.finsa)}"),
            leading: const Icon(Icons.business_center),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sortida.programa),
                  if (sortida.idPagament != null &&
                      sortida.hasPaymentDeadline) ...[
                    const SizedBox(height: 16),
                    Text(
                      "Data límit pel Pagament:\n  ${convertirDataAmerica(context, sortida.dataLimit)}",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
