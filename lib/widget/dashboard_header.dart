import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../model/user_model.dart';

class DashboardHeader extends StatelessWidget {
  final UserModel user;
  final String? avatarUrl;

  const DashboardHeader({
    super.key,
    required this.user,
    this.avatarUrl,
  });

  String _getInitials() {
    final first = user.firstName.trim();
    final last = user.lastName.trim();

    return '${first.isNotEmpty ? first[0] : ''}'
            '${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF41638F),
            child: ClipOval(
              child: avatarUrl != null
                  ? Image.network(
                      avatarUrl!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          _getInitials(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    )
                  : Text(
                      _getInitials(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buenos días,',
                  style: TextStyle(color: Color(0xFFD5E2F2), fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  user.firstName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
