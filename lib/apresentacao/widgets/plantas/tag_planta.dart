import 'package:flutter/material.dart';

class TagPlanta extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Color cor;

  const TagPlanta({
    super.key,
    required this.icone,
    required this.texto,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 12, color: cor),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
                fontSize: 11,
                color: cor,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}