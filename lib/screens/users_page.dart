import 'package:cendrassos/screens/sortides_page.dart';

import '../config_djau.dart';
import 'components/helpers.dart';
import 'components/alumne_item.dart';
import 'dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/djau.dart';
import '../utils/global_navigator.dart';
import 'components/app_menu_bar.dart';

const spaceAroundCells = 10.0;

class UsersPage extends StatelessWidget {
  static const routeName = '/users';

  final ValueNotifier<Map<int, String>> _users =
      ValueNotifier<Map<int, String>>({});

  UsersPage({super.key});

  void loadData(BuildContext context) async {
    final djau = Provider.of<DjauModel>(context, listen: false);
    _users.value = await djau.getAlumnes();
  }

  void gotoSortidesPage() {
    GlobalNavigator.forgetAndGo(SortidesPage.routeName);
  }

  void _gotoDashboard(BuildContext context, int idAlumne) async {
    final djau = Provider.of<DjauModel>(context, listen: false);
    try {
      await djau.loadAlumne(idAlumne);
      // TODO: No sé si fer popuntil
      GlobalNavigator.go(Dashboard.routeName);
    } catch (e) {
      // No volen distingir els tipus d'errors
      GlobalNavigator.showAlertPopup(
          "Error", "No s'ha pogut carregar l'alumne");
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DjauModel>();
    var nom = model.alumne.nomComplet();
    var currentAlumneId = model.alumne.id;

    if (_users.value.isEmpty) {
      loadData(context);
    }

    return Scaffold(
      appBar: AppMenuBar(
          nom: nom,
          haveleading: true,
          gotoUserPage: null,
          gotoSortides: gotoSortidesPage),
      body: ValueListenableBuilder<Map<int, String>>(
        valueListenable: _users,
        builder: (context, value, _) => value.isNotEmpty
            ? ListView.separated(
                itemCount: _users.value.length,
                itemBuilder: (context, index) {
                  int idAlumne = _users.value.keys.elementAt(index);
                  var nom = _users.value[idAlumne];

                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      color: Theme.of(context).primaryColorDark,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    key: Key(idAlumne.toString()),
                    onDismissed: (direction) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("$missatgeEliminant $nom")));
                    },
                    child: AlumneItem(
                      id: idAlumne,
                      nom: nom ?? "...",
                      enabled: idAlumne == currentAlumneId,
                      tryToGotoDashboard: _gotoDashboard,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              )
            : const Loading(
                loadingMessage: missatgeCarregantDades,
              ),
      ),
    );
  }
}
