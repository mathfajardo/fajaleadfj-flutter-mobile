import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/cliente.dart';

class ClienteTile extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onTap;

  const ClienteTile({super.key, required this.cliente, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nome = cliente.nome.trim();

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: cliente.ativo
            ? AppColors.primaryLight
            : AppColors.border,
        foregroundColor: cliente.ativo
            ? AppColors.primaryDark
            : AppColors.muted,
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
        '${formatarNumero(cliente.numero)} · ${cliente.plano}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.muted),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatarValor(cliente.mensalidade),
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!cliente.ativo)
            const Text(
              'Inativo',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
