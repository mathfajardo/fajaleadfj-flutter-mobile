import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/lead.dart';

const _coresStatus = {
  'Novo': Color(0xFF2563EB),
  'Em atendimento': Color(0xFFD97706),
  'Perdido': AppColors.danger,
  'Convertido': AppColors.primary,
};

class LeadTile extends StatelessWidget {
  final Lead lead;
  final VoidCallback onTap;

  const LeadTile({super.key, required this.lead, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nome = lead.nome.trim();
    final cor = _coresStatus[lead.status] ?? AppColors.muted;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: cor.withValues(alpha: 0.12),
        foregroundColor: cor,
        child: Text(
          nome.isEmpty ? '?' : nome[0].toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      title: Text(
        nome,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        formatarNumero(lead.numero),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.muted),
      ),
      trailing: Text(
        lead.status,
        style: TextStyle(color: cor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
