import 'package:flutter/material.dart';

const setTableSetFlex = 2;
const setTablePreviousFlex = 5;
const setTableKgFlex = 3;
const setTableRepsFlex = 3;
const setTableActionWidth = 48.0;

const setTableActionConstraints = BoxConstraints.tightFor(
  width: setTableActionWidth,
  height: setTableActionWidth,
);

class SetTableRow extends StatelessWidget {
  const SetTableRow({
    super.key,
    required this.set,
    required this.previous,
    required this.kg,
    required this.reps,
    required this.check,
    this.menu,
  });

  final Widget set;
  final Widget previous;
  final Widget kg;
  final Widget reps;
  final Widget check;
  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: setTableSetFlex, child: set),
        Expanded(flex: setTablePreviousFlex, child: previous),
        Expanded(flex: setTableKgFlex, child: kg),
        Expanded(flex: setTableRepsFlex, child: reps),
        SizedBox(width: setTableActionWidth, child: check),
        SizedBox(
          width: setTableActionWidth,
          child: menu ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}

Widget setTableLabel(String text, {Key? key, TextStyle? style}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.center,
    child: Text(
      key: key,
      text,
      maxLines: 1,
      softWrap: false,
      textAlign: TextAlign.center,
      style: style,
    ),
  );
}
