import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/alpha/plates.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlateCalculatorPage extends StatefulWidget {
  const PlateCalculatorPage({super.key, this.initialKg});

  final double? initialKg;

  @override
  State<PlateCalculatorPage> createState() => _PlateCalculatorPageState();
}

class _PlateCalculatorPageState extends State<PlateCalculatorPage> {
  late final TextEditingController _weight;
  late String _mode;

  @override
  void initState() {
    super.initState();
    _weight = TextEditingController(
      text: widget.initialKg == null ? '' : _text(widget.initialKg!),
    );
    _mode = 'barbell';
  }

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
    final prefs = alphaPrefs;
    final total = double.tryParse(_weight.text.replaceAll(',', '.')) ?? 0;
    final load = _mode == 'barbell'
        ? barbellLoad(totalKg: total, barKg: prefs.barKg, plates: prefs.plates)
        : cableLoad(totalKg: total, stepKg: prefs.cableStep);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: Text(l10n.plateCalculator)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'barbell', label: Text(l10n.barbellCalc)),
              ButtonSegment(value: 'cable', label: Text(l10n.cableCalc)),
            ],
            selected: {_mode},
            onSelectionChanged: (value) => setState(() => _mode = value.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: l10n.columnKg,
              suffixText: 'kg',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          if (_mode == 'barbell')
            _BarbellView(load: load, barKg: prefs.barKg, palette: palette)
          else
            _CableView(load: load, step: prefs.cableStep, palette: palette),
          if (load.extraKg > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('${l10n.extraWeight}: ${_text(load.extraKg)} kg'),
            ),
          const SizedBox(height: 24),
          Text(
            l10n.plateSetLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final plate in const [
                25.0,
                20.0,
                15.0,
                10.0,
                5.0,
                2.5,
                1.25,
              ])
                FilterChip(
                  label: Text(_text(plate)),
                  selected: prefs.plates.contains(plate),
                  onSelected: (selected) async {
                    setState(() {
                      if (selected) {
                        prefs.plates = [...prefs.plates, plate]
                          ..sort((a, b) => b.compareTo(a));
                      } else {
                        prefs.plates = [
                          for (final item in prefs.plates)
                            if (item != plate) item,
                        ];
                      }
                    });
                    await prefs.save();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_mode == 'barbell')
            _NumberRow(
              label: l10n.barWeightLabel,
              value: prefs.barKg,
              onChanged: (value) async {
                setState(() => prefs.barKg = value);
                await prefs.save();
              },
            )
          else
            _NumberRow(
              label: l10n.cableStepLabel,
              value: prefs.cableStep,
              choices: const [5, 10, 15, 1.25, 2.5],
              onChanged: (value) async {
                setState(() => prefs.cableStep = value);
                await prefs.save();
              },
            ),
        ],
      ),
    );
  }
}

class _BarbellView extends StatelessWidget {
  const _BarbellView({
    required this.load,
    required this.barKg,
    required this.palette,
  });

  final PlateLoad load;
  final double barKg;
  final AlphaPalette palette;

  @override
  Widget build(BuildContext context) {
    final plates = [
      for (final side in load.sides)
        for (var index = 0; index < side.count; index++) side.kg,
    ];
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          _sleeve(plates.reversed.toList()),
          Expanded(
            child: Container(
              height: 14,
              color: palette.muted,
              alignment: Alignment.center,
              child: Text(
                '${_text(barKg)} kg',
                style: TextStyle(color: palette.background, fontSize: 11),
              ),
            ),
          ),
          _sleeve(plates),
        ],
      ),
    );
  }

  Widget _sleeve(List<double> plates) {
    return Row(
      children: [
        for (final plate in plates)
          Container(
            width: plate >= 15 ? 16 : 12,
            height: 36 + plate,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: _plateColor(plate, palette),
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.center,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                _text(plate),
                style: TextStyle(color: palette.onAccent, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}

class _CableView extends StatelessWidget {
  const _CableView({
    required this.load,
    required this.step,
    required this.palette,
  });

  final PlateLoad load;
  final double step;
  final AlphaPalette palette;

  @override
  Widget build(BuildContext context) {
    final count = load.sides.isEmpty ? 0 : load.sides.first.count;
    final shown = count.clamp(0, 16);
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Container(width: 10, color: palette.muted),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (var index = 0; index < shown; index++)
                Container(
                  width: 92,
                  height: 12,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: index == shown - 1 ? palette.accent : palette.card,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: palette.border),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    _text(step),
                    style: TextStyle(
                      fontSize: 10,
                      color: index == shown - 1
                          ? palette.onAccent
                          : palette.text,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberRow extends StatelessWidget {
  const _NumberRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.choices,
  });

  final String label;
  final double value;
  final List<double>? choices;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = choices ?? const [15, 20, 25];
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(label),
        for (final option in options)
          ChoiceChip(
            label: Text(_text(option.toDouble())),
            selected: value == option,
            onSelected: (_) => onChanged(option.toDouble()),
          ),
      ],
    );
  }
}

Color _plateColor(double kg, AlphaPalette palette) {
  if (kg >= 25) return const Color(0xFFE53935);
  if (kg >= 20) return const Color(0xFF1565C0);
  if (kg >= 15) return const Color(0xFFF9A825);
  if (kg >= 10) return const Color(0xFF2E7D32);
  return palette.accent;
}

String _text(double value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toString();
}
