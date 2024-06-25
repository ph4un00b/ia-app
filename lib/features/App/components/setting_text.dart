import 'package:flutter/material.dart';

class SettingAppText extends StatelessWidget {
  const SettingAppText({
    super.key,
    required this.scale,
    required this.onChangedValue,
  });

  final double scale;
  final void Function(double) onChangedValue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Text(
              '${scale.toStringAsFixed(2)} - Ajuste de texto',
              textScaler: TextScaler.linear(1.6 * scale),
            ),
          ),
          Expanded(
            child: Slider(
              value: scale,
              // value: 1.0,
              min: 0.5,
              max: 3.0,
              // divisions: 5,
              label: scale.toString(),
              onChanged: (double value) {
                onChangedValue(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
