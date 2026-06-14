import 'package:cendrassos/screens/profile_page.dart';
import 'package:cendrassos/screens/dashboard_page.dart';
import 'package:flutter/material.dart';

class AppMenuBar extends StatelessWidget implements PreferredSizeWidget {
  final String nom;
  final bool haveleading;
  final VoidCallback? gotoUserPage;
  final VoidCallback? gotoSortides;

  const AppMenuBar(
      {super.key,
      required this.nom,
      required this.haveleading,
      required this.gotoUserPage,
      required this.gotoSortides});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return AppBar(
      automaticallyImplyLeading: haveleading,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      title: InkWell(
        onTap: currentRoute == Dashboard.routeName
            ? null
            : () => Navigator.of(context).pushNamed(Dashboard.routeName),
        child: Text(
          nom,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_rounded),
          disabledColor: Theme.of(context).disabledColor,
          onPressed: enableProfileButton(context, currentRoute, {'nom': nom}),
        ),
        IconButton(
          icon: const Icon(Icons.directions_bus),
          disabledColor: Theme.of(context).disabledColor,
          onPressed: gotoSortides,
        ),
        IconButton(
          icon: const Icon(Icons.switch_account),
          disabledColor: Theme.of(context).disabledColor,
          onPressed: gotoUserPage,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  VoidCallback? enableProfileButton(BuildContext context, String? currentRoute,
      Map<String, String> arguments) {
    if (currentRoute != ProfilePage.routeName) {
      return () => Navigator.of(context)
          .pushNamed(ProfilePage.routeName, arguments: arguments);
    }
    return null;
  }
}
