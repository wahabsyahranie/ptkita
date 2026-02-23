import 'package:flutter/material.dart';
import 'package:flutter_kita/models/user/user_model.dart';
import 'package:flutter_kita/pages/maintenance/maintenance_page.dart';
import 'package:flutter_kita/pages/repair/repair_history_page.dart';
import 'package:flutter_kita/pages/transaction/transaction_history_page.dart';
import 'package:flutter_kita/pages/warranty/warranty_history_page.dart';
import 'package:flutter_kita/services/user/user_service.dart';
import 'package:flutter_kita/styles/colors.dart';
import '../core/widgets/confirmation_sheet.dart';

class NavigationDrawerWidget extends StatelessWidget {
  final UserService userService;

  const NavigationDrawerWidget({super.key, required this.userService});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: MyColors.secondary,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
          children: <Widget>[
            StreamBuilder<UserModel?>(
              stream: userService.currentUserProfile,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox(height: 120);
                }

                final user = snapshot.data!;

                return buildHeader(
                  photoUrl: user.photoUrl,
                  name: user.name,
                  phone: user.phone ?? '-', // kalau belum ada di model
                );
              },
            ),

            const SizedBox(height: 20),
            buildMenuItem(
              text: 'Perawatan',
              icon: Icons.home_repair_service_outlined,
              onClicked: () => selectedItem(context, 0),
            ),
            const SizedBox(height: 16),
            buildMenuItem(
              text: 'Riwayat Transaksi',
              icon: Icons.attach_money,
              onClicked: () => selectedItem(context, 1),
            ),
            const SizedBox(height: 16),
            buildMenuItem(
              text: 'Riwayat Perbaikan',
              icon: Icons.tire_repair_outlined,
              onClicked: () => selectedItem(context, 2),
            ),
            const SizedBox(height: 16),
            buildMenuItem(
              text: 'Riwayat Garansi',
              icon: Icons.newspaper_sharp,
              onClicked: () => selectedItem(context, 3),
            ),
            const SizedBox(height: 24),
            const Divider(color: MyColors.white),
            const SizedBox(height: 24),
            buildMenuItem(
              text: 'Log Out',
              icon: Icons.logout,
              onClicked: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: MyColors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) => ConfirmationSheet(
                    title: "Konfirmasi Logout",
                    description: "Yakin ingin keluar dari akun ini?",
                    confirmText: "Keluar",
                    isDestructive: true,
                    onConfirm: () async {
                      await userService.logout();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const MaintenancePage()),
        );
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TransactionHistoryPage(),
          ),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const RepairHistoryPage()),
        );
        break;
      case 3:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const WarrantyHistoryPage()),
        );
        break;
    }
  }

  Widget buildHeader({
    required String? photoUrl,
    required String name,
    required String phone,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : const AssetImage('assets/images/person_image.jpg')
                      as ImageProvider,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  phone,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
