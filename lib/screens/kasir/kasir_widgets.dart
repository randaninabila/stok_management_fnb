import 'package:flutter/material.dart';

import 'kasir_theme.dart';

class KasirAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const KasirAddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(92, 40),
        elevation: 0,
      ),
      child: const Text('Tambah'),
    );
  }
}

class KasirQtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final double size;

  const KasirQtyStepper({
    super.key,
    this.size = 40,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(icon: Icons.remove, size: size, onTap: onRemove),
        SizedBox(
          width: 36,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: KasirColors.textDark,
            ),
          ),
        ),
        _StepButton(icon: Icons.add, size: size, onTap: onAdd),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _StepButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KasirColors.chipBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 20, color: KasirColors.textDark),
        ),
      ),
    );
  }
}
