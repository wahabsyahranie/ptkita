import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/maintenance_page.dart';
import 'package:flutter_kita/pages/repair_history_page.dart';
import 'package:flutter_kita/pages/transaction_history_page.dart';
import 'package:flutter_kita/pages/user_page.dart';
import 'package:flutter_kita/pages/warranty_history_page.dart';
import 'package:flutter_kita/styles/colors.dart';

class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final name = 'Wahab Syahranie';
    final email = 'wahabschools@gmail.com';
    final position = 'CEO';
    final urlImage =
        'https://plus.unsplash.com/premium_photo-1760876475958-680bc9c45d2b?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1470';

    return Drawer(
      child: Material(
        color: MyColors.secondary,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
          children: <Widget>[
            buildHeader(
              urlImage: urlImage,
              name: name,
              email: email,
              position: position,
              // onClicked: () {},
              onClicked: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      UserPage(name: name, urlImage: urlImage),
                ),
              ),
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
            Divider(color: MyColors.white),
            const SizedBox(height: 24),
            buildMenuItem(text: 'Log Out', icon: Icons.logout),
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
    final color = Colors.white;
    final hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => MaintenancePage()));
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => TransactionHistoryPage()),
        );
        break;
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => RepairHistoryPage()));
        break;
      case 3:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => WarrantyHistoryPage()));
        break;
    }
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required String email,
    required String position,
    required VoidCallback onClicked,
  }) => InkWell(
    onTap: onClicked,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ).add(EdgeInsets.symmetric(vertical: 40)),
      child: Row(
        children: [
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 20, color: MyColors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: MyColors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: MyColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    position,
                    style: TextStyle(fontSize: 10, color: MyColors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 24,
            backgroundColor: MyColors.white,
            child: Icon(Icons.add_comment_outlined, color: MyColors.secondary),
          ),
        ],
      ),
    ),
  );
}
