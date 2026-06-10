import 'package:cendrassos/models/notificacio.dart';
import 'package:cendrassos/screens/components/preview_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../config_djau.dart';

@Preview(name: 'Notificacio Dialog')
Widget previewNotificacioDialog() => previewWithTheme(
      child: Scaffold(
        body: Center(
          child: NotificacioDialog(
            notificacio: Notificacio(
              DateTime(2026, 6, 7),
              '10:30',
              'M. Roca',
              'Recordatori: demà hi ha reunió de coordinació a la sala 2.',
              tipusNotificacio.first,
            ),
          ),
        ),
      ),
    );

class NotificacioDialog extends StatelessWidget {
  final Notificacio notificacio;

  static const routeName = '/notificacio';

  const NotificacioDialog({
    super.key,
    required this.notificacio,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isCompactHeight = mediaQuery.size.height < 700;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        top: isCompactHeight ? 36 : 60,
        right: 20,
        bottom: 20,
      ),
      margin: EdgeInsets.only(top: isCompactHeight ? 20 : 45),
      height: mediaQuery.size.height * 0.8,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).shadowColor,
                offset: const Offset(0, 10),
                blurRadius: 10),
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${notificacio.getDia()}  ${notificacio.hora}',
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: notificacio.getColor(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                      notificacio.tipus,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Divider(
                color: Theme.of(context).primaryColor,
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "$etiquetaProfessor: ",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Flexible(
                    child: Text(
                      notificacio.professor,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).primaryColor,
            height: 36,
          ),
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                notificacio.text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          const SizedBox(
            height: 22,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  missatgeOk,
                )),
          ),
        ],
      ),
    );
  }
}
