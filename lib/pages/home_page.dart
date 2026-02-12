import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/capture/capture_page.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/navigation_bottom_widget.dart';
import 'package:flutter_kita/widget/navigation_drawer_widget.dart';
import 'package:flutter_kita/pages/inventory/inventory_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //menambah controller search bar di sini
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  //Subscribe ke topic maintenance
  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.subscribeToTopic('maintenance');
  }

  void _onTapNav(int index) {
    setState(() => _currentIndex = index);
  }

  // QUERY CARD JENIS BARANG
  Stream<int> _totalItemsStream() {
    return FirebaseFirestore.instance
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  //QUERY CARD STOK HABIS
  Stream<int> _outOfStockStream() {
    return FirebaseFirestore.instance
        .collection('items')
        .where('stock', isEqualTo: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  //HELPER CARD PERAWATAN HARI INI
  DateTime _todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _todayEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  String _todayDocId() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  //QUERY CARD PERAWATAN HARI INI
  Stream<int> totalMaintenanceTodayStream() {
    return FirebaseFirestore.instance
        .collection('daily_maintenance_snapshot')
        .doc(_todayDocId())
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0;
          return doc['totalScheduled'] ?? 0;
        });
  }

  //QUERY CARD PERAWATAN HARI INI (SELESAI)
  Stream<int> completedMaintenanceTodayStream() {
    final start = Timestamp.fromDate(_todayStart());
    final end = Timestamp.fromDate(_todayEnd());

    return FirebaseFirestore.instance
        .collection('maintenance_logs')
        .where('completedAt', isGreaterThanOrEqualTo: start)
        .where('completedAt', isLessThanOrEqualTo: end)
        .snapshots()
        .map((s) => s.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    // Buat pages tanpa endDrawer di inner scaffold
    final List<Widget> pages = [
      // index 0 - halaman utama (tanpa endDrawer di sini)
      SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 25),
              _todayMaintenanceCard(),
              const SizedBox(height: 20),
              _statisticCards(),
              const SizedBox(height: 20),
              _repairProgressCard(),
            ],
          ),
        ),
      ),

      // index 1
      // const CapturePage(),

      // index 2
      const InventoryPage(),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey, // <--- root scaffold key
        extendBody: true,
        // Pindahkan endDrawer ke sini agar drawer muncul di atas bottomNavigationBar
        endDrawer: const NavigationDrawerWidget(),
        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: NavigationBottomWidget(
          activeIndex: _currentIndex,
          onTap: _onTapNav,
        ),
        // resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: MediaQuery.of(context).viewInsets.bottom > 0
            ? null
            : SizedBox(
                width: 60,
                height: 60,
                child: FloatingActionButton(
                  heroTag: null,
                  shape: const CircleBorder(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CapturePage()),
                    );
                  },

                  backgroundColor: MyColors.secondary,
                  elevation: 4,
                  child: Icon(Icons.qr_code, color: MyColors.white),
                ),
              ),
      ),
    );
  }

  Widget _header() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Teknisi';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selamat datang,', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Container(
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     color: MyColors.secondary,
                //     borderRadius: BorderRadius.circular(25),
                //   ),
                //   child: Icon(Icons.notifications, color: MyColors.white),
                // ),
                // const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                  child: CachedNetworkImage(
                    imageUrl: data['photoUrl'] ?? '',
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 26,
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) =>
                        const CircleAvatar(radius: 26),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      radius: 26,
                      backgroundImage: AssetImage(
                        'assets/images/person_image.jpg',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  //WIDGET PERAWATAN HARI INI
  Widget _todayMaintenanceCard() {
    return StreamBuilder<int>(
      stream: totalMaintenanceTodayStream(),
      builder: (context, totalSnap) {
        if (!totalSnap.hasData) return _maintenanceLoadingCard();

        return StreamBuilder<int>(
          stream: completedMaintenanceTodayStream(),
          builder: (context, doneSnap) {
            if (!doneSnap.hasData) return _maintenanceLoadingCard();

            final total = totalSnap.data!;
            final done = doneSnap.data!;
            final progress = total == 0 ? 1.0 : done / total;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MyColors.greySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Perawatan Hari Ini',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('$done / $total perawatan selesai'),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation(
                            MyColors.secondary,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //HELPER LOADING (PERAWATAN HARI INI)
  Widget _maintenanceLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MyColors.greySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _statisticCards() {
    return Row(
      children: [
        //CARD JENIS BARANG
        StreamBuilder<int>(
          stream: _totalItemsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _statCard(
                title: 'Jenis Barang',
                value: '...',
                subtitle: 'Memuat data',
                icon: Icons.inventory_2_outlined,
              );
            }

            if (snapshot.hasError) {
              return _statCard(
                title: 'Jenis Barang',
                value: '-',
                subtitle: 'Gagal memuat data',
                icon: Icons.inventory_2_outlined,
              );
            }

            final totalItems = snapshot.data ?? 0;

            return _statCard(
              title: 'Jenis Barang',
              value: '$totalItems pcs.',
              subtitle: 'Jumlah jenis barang tersedia',
              icon: Icons.inventory_2_outlined,
            );
          },
        ),
        const SizedBox(width: 15),
        //CARD STOK HABIS
        StreamBuilder<int>(
          stream: _outOfStockStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _statCard(
                title: 'Stok Habis',
                value: '...',
                subtitle: 'Memuat data',
                icon: Icons.production_quantity_limits_outlined,
              );
            }

            if (snapshot.hasError) {
              return _statCard(
                title: 'Stok Habis',
                value: '-',
                subtitle: 'Gagal memuat data',
                icon: Icons.production_quantity_limits_outlined,
              );
            }

            final totalOutOfStock = snapshot.data ?? 0;

            return _statCard(
              title: 'Stok Habis',
              value: '$totalOutOfStock pcs.',
              subtitle: 'Cek barang dengan stok kosong',
              icon: Icons.production_quantity_limits_outlined,
            );
          },
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: MyColors.greySoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: MyColors.secondary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: MyColors.secondary),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<Map<String, int>> getRepairSummary(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final snapshot = await FirebaseFirestore.instance
        .collection('repair')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .get();

    int dalamPerbaikan = 0;
    int selesai = 0;

    for (var doc in snapshot.docs) {
      final status = doc['status'].toString().toLowerCase();

      if (status.contains('belum')) {
        dalamPerbaikan++;
      } else if (status.contains('selesai')) {
        selesai++;
      }
    }

    return {
      'dalam': dalamPerbaikan,
      'selesai': selesai,
      'total': snapshot.docs.length,
    };
  }

  Widget _repairProgressCard() {
    return FutureBuilder<Map<String, int>>(
      future: getRepairSummary(30), // ganti 60 jika perlu
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final dalam = data['dalam']!;
        final selesai = data['selesai']!;
        final total = data['total']!;

        final dalamProgress = total == 0 ? 0.0 : dalam / total;
        final selesaiProgress = total == 0 ? 0.0 : selesai / total;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MyColors.greySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Grafik Perbaikan (30 Hari)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _progressRow(
                'Dalam perbaikan',
                dalamProgress,
                '$dalam/$total',
                Icons.build_outlined,
              ),
              const SizedBox(height: 16),
              _progressRow(
                'Selesai',
                selesaiProgress,
                '$selesai/$total',
                Icons.check_circle_outline,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _progressRow(String title, double value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: MyColors.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(title), Text(label)],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation(MyColors.secondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
