import 'package:cendrassos/screens/sortides_page.dart';
import 'package:cendrassos/screens/components/preview_helpers.dart';
import 'package:cendrassos/api/exceptions.dart';

import '../config_djau.dart';
import 'components/helpers.dart';
import 'components/alumne_item.dart';
import 'dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';

import '../providers/djau.dart';
import '../utils/global_navigator.dart';
import 'components/app_menu_bar.dart';

const spaceAroundCells = 10.0;

@Preview(name: 'Users Page (Mock)')
Widget previewUsersPage() => previewWithTheme(child: const _UsersPagePreview());

class _UsersPagePreview extends StatelessWidget {
  const _UsersPagePreview();

  @override
  Widget build(BuildContext context) {
    final alumnes = const {
      1: 'Arnau Roca',
      2: 'Berta Puig',
      3: 'Clara Solà',
    };

    return previewPage(
      appBar: const AppMenuBar(
        nom: 'Tutor Prova',
        haveleading: true,
        gotoUserPage: null,
        gotoSortides: null,
      ),
      body: ListView.separated(
        itemCount: alumnes.length,
        itemBuilder: (context, index) {
          final idAlumne = alumnes.keys.elementAt(index);
          final nom = alumnes[idAlumne] ?? '...';
          return AlumneItem(
            id: idAlumne,
            nom: nom,
            enabled: idAlumne == 2,
            tryToGotoDashboard: (_, __) {},
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}

class UsersPage extends StatefulWidget {
  static const routeName = '/users';

  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  Map<int, String> _users = {};
  bool _isLoading = true;
  String _errorType = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
      _errorType = '';
      _errorMessage = '';
    });

    final djau = Provider.of<DjauModel>(context, listen: false);

    try {
      final alumnes = await djau.getAlumnesMap();
      if (!mounted) return;
      setState(() {
        _users = alumnes;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _users = {};
        _isLoading = false;
        _errorType = e.prefix();
        _errorMessage = e.message();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _users = {};
        _isLoading = false;
        _errorType = defaultErrorMessage;
        _errorMessage = errorCarregant;
      });
    }
  }

  void gotoSortidesPage() {
    GlobalNavigator.forgetAndGo(SortidesPage.routeName);
  }

  void _gotoDashboard(BuildContext context, int idAlumne) async {
    final djau = Provider.of<DjauModel>(context, listen: false);
    try {
      await djau.loadAlumne(idAlumne);
      // TODO: No sé si fer popuntil?
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

    return Scaffold(
      appBar: AppMenuBar(
          nom: nom,
          haveleading: true,
          gotoUserPage: null,
          gotoSortides: gotoSortidesPage),
      body: _isLoading
          ? const Loading(
              loadingMessage: missatgeCarregantDades,
            )
          : _errorMessage.isNotEmpty
              ? ErrorRetry(
                  errorType: _errorType,
                  errorMessage: _errorMessage,
                  textBoto: missatgeTornaAProvar,
                  onRetryPressed: loadData,
                )
              : ListView.separated(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    int idAlumne = _users.keys.elementAt(index);
                    var nom = _users[idAlumne];

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
                ),
    );
  }
}
