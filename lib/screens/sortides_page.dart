import 'dart:async';

import 'package:cendrassos/api/api_response.dart';
import 'package:cendrassos/api/sortides_bloc.dart';
import 'package:cendrassos/config_djau.dart';
import 'package:cendrassos/models/resum_sortida.dart';
import 'package:cendrassos/providers/djau.dart';
import 'package:cendrassos/screens/components/app_menu_bar.dart';
import 'package:cendrassos/screens/components/helpers.dart';
import 'package:cendrassos/screens/components/preview_helpers.dart';
import 'package:cendrassos/screens/components/sortida_list_item.dart';
import 'package:cendrassos/screens/users_page.dart';
import 'package:cendrassos/utils/global_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';

@Preview(name: 'Sortides Page (Mock)')
Widget previewSortidesPage() =>
    previewWithTheme(child: const _SortidesPagePreview());

class _SortidesPagePreview extends StatelessWidget {
  const _SortidesPagePreview();

  @override
  Widget build(BuildContext context) {
    final sampleSortides = [
      ResumSortida(
          1, 'ColOnies a la Cerdanya', '2026-05-03 08:00:00', true, false),
      ResumSortida(2, 'Teatre en anglEs', '2026-05-19 10:30:00', false, true),
      ResumSortida(
          3, 'Visita a la depuradora', '2026-06-02 09:15:00', true, true),
    ];

    return previewPage(
      appBar: const AppMenuBar(
        nom: 'Alumne Prova',
        haveleading: true,
        gotoUserPage: null,
        gotoSortides: null,
      ),
      body: ListView.builder(
        itemCount: sampleSortides.length,
        itemBuilder: (context, index) {
          return SortidaListItem(
            sortida: sampleSortides[index],
            showDetail: (_, __) {},
          );
        },
      ),
    );
  }
}

class SortidesPage extends StatefulWidget {
  static const routeName = '/sortides';
  const SortidesPage({super.key});

  @override
  State<SortidesPage> createState() => _SortidesPageState();
}

class _SortidesPageState extends State<SortidesPage> {
  List<ResumSortida> _sortides = [];

  late SortidesBlock _bloc;

  @override
  void initState() {
    super.initState();
    final djau = Provider.of<DjauModel>(context, listen: false);
    _bloc = SortidesBlock(djau.tutor, djau.alumne.id);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  void _retryComunicacion() {
    setState(() {
      _bloc.fetchSortides();
    });
  }

  FutureOr onGoBack(dynamic value) {
    final djau = Provider.of<DjauModel>(context, listen: false);
    if (_bloc.getToken() != djau.tutor.token) {
      _bloc.setTutor(djau.tutor);
      _retryComunicacion();
    }
  }

  void gotoUserPage() {
    Navigator.of(context).pushNamed(UsersPage.routeName).then(onGoBack);
  }

  void _gotoUsuaris() {
    GlobalNavigator.forgetAndGo(UsersPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final currentLogin = context.watch<DjauModel>();

    var nom = currentLogin.alumne.nom;

    return Scaffold(
      appBar: AppMenuBar(
          nom: nom,
          haveleading: true,
          gotoUserPage: gotoUserPage,
          gotoSortides: null),
      body: RefreshIndicator(
        onRefresh: () => _bloc.fetchSortides(),
        child: StreamBuilder<ApiResponse<List<ResumSortida>>>(
            stream: _bloc.resumSortidaListStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data!.status) {
                  case Status.loading:
                    return Loading(loadingMessage: snapshot.data!.message);
                  case Status.completed:
                    _sortides = snapshot.data!.data;
                    return buildLlistaSortides(_sortides);
                  case Status.error:
                    return ErrorRetryLogin(
                      errorType: "ERROR",
                      errorMessage: snapshot.data!.message,
                      onLogin: _gotoUsuaris,
                      onRetryPressed: _retryComunicacion,
                    );
                }
              } else {
                return const Loading(loadingMessage: missatgeCarregantDades);
              }
            }),
      ),
    );
  }

  void _showDetails(BuildContext context, int id) async {
    GlobalNavigator.gotoSortidaDetail(context, id);
  }

  Widget buildLlistaSortides(List<ResumSortida> sortides) {
    return ListView.builder(
      itemCount: sortides.length,
      itemBuilder: (context, index) {
        final post = sortides[index];
        return SortidaListItem(
          sortida: post,
          showDetail: _showDetails,
        );
      },
    );
  }
}
