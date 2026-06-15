import 'package:cendrassos/models/resum_sortida.dart';
import 'package:cendrassos/screens/components/helpers.dart';
import 'package:flutter/material.dart';

typedef TryShowDetail = void Function(BuildContext context, int id);

class SortidaListItem extends StatelessWidget {
  const SortidaListItem({
    super.key,
    required this.sortida,
    required this.showDetail,
  });

  final ResumSortida sortida;
  final TryShowDetail showDetail;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDetail(context, sortida.id),
      child: sortidaItemContent(context),
    );
  }

  Widget sortidaItemContent(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        sortida.titol,
        textAlign: TextAlign.left,
      ),
      subtitle: Text(
        sortida.data.trim().isEmpty
            ? 'Data pendent de confirmar'
            : convertirDataAmerica(context, sortida.data),
      ),
      trailing: calculaIcona(context),
    );
  }

  Icon calculaIcona(BuildContext context) {
    // Si la data és posterior a avui mostra la sortida desactivada
    var color = Theme.of(context).primaryColor;
    if (sortida.isBefore(DateTime.now()) || sortida.realitzat) {
      color = Theme.of(context).disabledColor;
    }

    return !sortida.pagament
        ? Icon(Icons.output, color: color)
        : Icon(Icons.payment, color: color);
  }
}
