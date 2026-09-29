import 'package:flutter/material.dart';
import 'models.dart';

/// Domanda con immagine (se presente) e tre opzioni.
/// [order] = indici originali delle opzioni nell'ordine di visualizzazione.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.q,
    required this.order,
    required this.selected,
    required this.reveal,
    required this.onSelect,
    this.caption,
  });

  final Question q;
  final List<int> order;
  final int? selected;
  final bool reveal;
  final ValueChanged<int> onSelect;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(caption!,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: scheme.primary)),
          ),
        Text(q.text, style: Theme.of(context).textTheme.titleMedium),
        if (q.image != null)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Image.asset(q.image!, fit: BoxFit.contain),
          )
        else
          const SizedBox(height: 12),
        for (var pos = 0; pos < order.length; pos++) _option(context, pos),
      ],
    );
  }

  Widget _option(BuildContext context, int pos) {
    final scheme = Theme.of(context).colorScheme;
    final orig = order[pos];
    final isSel = selected == orig;
    final isCorrect = orig == q.correct;
    Color? bg;
    if (reveal) {
      if (isCorrect) {
        bg = Colors.green.shade100;
      } else if (isSel) {
        bg = Colors.red.shade100;
      }
    } else if (isSel) {
      bg = scheme.primaryContainer;
    }
    return Card(
      color: bg,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: reveal ? null : () => onSelect(orig),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 14, child: Text('ABC'[pos])),
              const SizedBox(width: 12),
              Expanded(child: Text(q.options[orig])),
            ],
          ),
        ),
      ),
    );
  }
}
