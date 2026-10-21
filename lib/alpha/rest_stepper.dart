import 'package:flexify/alpha/plates.dart';
import 'package:flutter/material.dart';

class RestDurationStepper extends StatelessWidget {
  const RestDurationStepper({
    required this.seconds,
    required this.onChanged,
    super.key,
  });

  final int seconds;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final shown = nearestRest(seconds);
    return Row(
      children: [
        IconButton(
          onPressed: shown <= restMinSeconds
              ? null
              : () => onChanged(shown - restStepSeconds),
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: Text(
            '${shown}s',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 28),
          ),
        ),
        IconButton(
          onPressed: shown >= restMaxSeconds
              ? null
              : () => onChanged(shown + restStepSeconds),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
