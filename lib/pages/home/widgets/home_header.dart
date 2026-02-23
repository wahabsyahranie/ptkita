import 'package:flutter/material.dart';
import '../../../models/user/user_model.dart';

class HomeHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback onAvatarTap;

  const HomeHeader({super.key, required this.user, required this.onAvatarTap});

  String _limitText(String text, int max) {
    return text.length <= max ? text : "${text.substring(0, max)}...";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selamat datang,', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              _limitText(user.name, 25),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        InkWell(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: 26,
            backgroundImage: user.photoUrl != null
                ? NetworkImage(user.photoUrl!)
                : const AssetImage('assets/images/person_image.jpg')
                      as ImageProvider,
          ),
        ),
      ],
    );
  }
}
