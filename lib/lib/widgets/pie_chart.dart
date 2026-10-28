import 'dart:math';

import 'package:flutter/material.dart';

class PieSlice {
  const PieSlice(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

/// Gráfico de pizza simples, desenhado com CustomPainter (sem dependências extras).
class SimplePieChart extends StatelessWidget {
  const SimplePieChart({super.key, required this.slices, this.size = 130});

  final List<PieSlice> slices;
  final double size;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    return SizedBox(
      width: size,
      height: size,
      child: total <= 0
          ? const SizedBox.shrink()
          : CustomPaint(painter: _PiePainter(slices, total)),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.slices, this.total);
  final List<PieSlice> slices;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    var start = -pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * pi;
      final paint = Paint()..color = slice.color;
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) =>
      oldDelegate.slices != slices || oldDelegate.total != total;
}

class PieLegendRow extends StatelessWidget {
  const PieLegendRow({super.key, required this.slice, required this.percent});
  final PieSlice slice;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(slice.label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Text('$percent%',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
