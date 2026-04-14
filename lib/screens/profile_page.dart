import 'package:cendrassos/api/exceptions.dart';
import 'package:cendrassos/config_djau.dart';
import 'package:cendrassos/models/perfil.dart';
import 'package:cendrassos/providers/djau.dart';
import 'package:cendrassos/screens/components/app_menu_bar.dart';
import 'package:cendrassos/screens/components/helpers.dart';
import 'package:cendrassos/screens/components/preview_helpers.dart';
import 'package:cendrassos/screens/sortides_page.dart';
import 'package:cendrassos/screens/users_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';

@Preview(name: 'Profile Page (Mock)')
Widget previewProfilePage() =>
    previewWithTheme(child: const _ProfilePagePreview());

class _ProfilePagePreview extends StatelessWidget {
  const _ProfilePagePreview();

  @override
  Widget build(BuildContext context) {
    final samplePerfil = Perfil(
      '4t ESO A',
      '12/04/2010',
      '600123123',
      'Carrer Major 12, Girona',
      [
        Responsable('Anna Soler', 'anna.soler@example.com', '699111222'),
        Responsable('Jordi Soler', 'jordi.soler@example.com', '699333444'),
      ],
    );

    return previewPage(
      appBar: const AppMenuBar(
        nom: 'Alumne Prova',
        haveleading: true,
        gotoUserPage: null,
        gotoSortides: null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const ProfilePage().showData(context, samplePerfil),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  static const routeName = '/profile';

  const ProfilePage({super.key});

  Widget responsableColumn(
      BuildContext context, String nom, String email, String telefon) {
    return Column(
      children: [
        Text(
          nom,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Divider(
          indent: 20,
          endIndent: 20,
        ),
        ListTile(
          tileColor: Theme.of(context).scaffoldBackgroundColor,
          leading: Icon(
            Icons.email,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            email,
          ),
        ),
        ListTile(
          tileColor: Theme.of(context).scaffoldBackgroundColor,
          leading: Icon(
            Icons.phone,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            telefon,
          ),
        ),
      ],
    );
  }

  Widget showData(BuildContext context, Perfil dades) {
    return Column(
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        const AssetImage('assets/images/student.png'),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ]),
          ],
        ),
        Center(
          child: Text(
            dades.grup,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(children: [
            ListTile(
              tileColor: Theme.of(context).scaffoldBackgroundColor,
              leading: Icon(
                Icons.cake,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                dades.datanaixement,
              ),
            ),
            ListTile(
              tileColor: Theme.of(context).scaffoldBackgroundColor,
              leading: Icon(
                Icons.home,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                dades.adreca,
              ),
            ),
            ListTile(
              tileColor: Theme.of(context).scaffoldBackgroundColor,
              leading: Icon(
                Icons.phone,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                dades.telefon,
              ),
            ),
          ]),
        ),
        Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 4.0,
          shadowColor: Theme.of(context).primaryColorLight,
          child: Column(
              children: dades.responsables
                  .map((element) => responsableColumn(
                        context,
                        element.nom,
                        element.mail,
                        element.telefon,
                      ))
                  .toList()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final djau = Provider.of<DjauModel>(context, listen: false);

    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    return Scaffold(
      appBar: AppMenuBar(
        nom: arguments['nom'],
        haveleading: true,
        gotoUserPage: () =>
            {Navigator.of(context).pushNamed(UsersPage.routeName)},
        gotoSortides: () =>
            {Navigator.of(context).pushNamed(SortidesPage.routeName)},
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              FutureBuilder<Perfil>(
                  future: djau.loadPerfil(),
                  builder:
                      (BuildContext build, AsyncSnapshot<Perfil> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return showData(context, snapshot.data as Perfil);
                    } else if (snapshot.connectionState ==
                            ConnectionState.done &&
                        snapshot.hasError) {
                      var e = snapshot.error as AppException;
                      return ErrorRetry(
                        errorType: e.prefix(),
                        errorMessage: e.message(),
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
    );
  }
}
