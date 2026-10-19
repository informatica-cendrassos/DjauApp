import 'package:cendrassos/screens/profile_page.dart';
import 'package:cendrassos/screens/dashboard_page.dart';
import 'package:cendrassos/screens/components/helpers.dart';
import 'package:flutter/material.dart';

class AppMenuBar extends StatefulWidget implements PreferredSizeWidget {
  final String nom;
  final bool haveleading;
  final VoidCallback? gotoUserPage;
  final VoidCallback? gotoSortides;
  final bool qualitativeEvaluationVisible;
  final Future<void> Function()? onQualitativeEvaluation;

  const AppMenuBar(
      {super.key,
      required this.nom,
      required this.haveleading,
      required this.gotoUserPage,
      required this.gotoSortides,
      this.qualitativeEvaluationVisible = false,
      this.onQualitativeEvaluation});

  @override
  State<AppMenuBar> createState() => _AppMenuBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppMenuBarState extends State<AppMenuBar> {
  bool _isOpeningQualitativeEvaluation = false;

  Future<void> _openQualitativeEvaluation() async {
    final action = widget.onQualitativeEvaluation;
    if (action == null || _isOpeningQualitativeEvaluation) {
      return;
    }

    setState(() {
      _isOpeningQualitativeEvaluation = true;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        await showAppErrorDialog(context, error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningQualitativeEvaluation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return AppBar(
      automaticallyImplyLeading: widget.haveleading,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      title: InkWell(
        onTap: currentRoute == Dashboard.routeName
            ? null
            : () => Navigator.of(context).pushNamed(Dashboard.routeName),
        child: Text(
          widget.nom,
        ),
      ),
      actions: [
        if (widget.qualitativeEvaluationVisible &&
            widget.onQualitativeEvaluation != null)
          IconButton(
            key: const Key('qualitative-evaluation-button'),
            tooltip: 'Avaluació qualitativa',
            icon: _isOpeningQualitativeEvaluation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.description_outlined),
            onPressed: _isOpeningQualitativeEvaluation
                ? null
                : _openQualitativeEvaluation,
          ),
        IconButton(
          icon: const Icon(Icons.account_circle_rounded),
          disabledColor: Theme.of(context).disabledColor,
          onPressed:
              enableProfileButton(context, currentRoute, {'nom': widget.nom}),
        ),
        IconButton(
          icon: const Icon(Icons.directions_bus),
          disabledColor: Theme.of(context).disabledColor,
          onPressed: widget.gotoSortides,
        ),
        IconButton(
          icon: const Icon(Icons.switch_account),
          disabledColor: Theme.of(context).disabledColor,
          onPressed: widget.gotoUserPage,
        ),
      ],
    );
  }

  VoidCallback? enableProfileButton(BuildContext context, String? currentRoute,
      Map<String, String> arguments) {
    if (currentRoute != ProfilePage.routeName) {
      return () => Navigator.of(context)
          .pushNamed(ProfilePage.routeName, arguments: arguments);
    }
    return null;
  }
}
