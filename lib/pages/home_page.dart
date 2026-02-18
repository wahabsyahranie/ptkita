import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/capture/capture_page.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/navigation_bottom_widget.dart';
import 'package:flutter_kita/widget/navigation_drawer_widget.dart';
import 'package:flutter_kita/pages/inventory/inventory_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //menambah controller search bar di sini
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  // for line chart filter
  String _chartMode = 'weekly'; // weekly / monthly
  
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

  // kelipatan chart
  double _calculateMaxY(List<List<int>> allData) {
    int maxValue = 0;

    for (var list in allData) {
      for (var value in list) {
        if (value > maxValue) {
          maxValue = value;
        }
      }
    }

    if (maxValue == 0) return 5;

    // Bikin pembulatan enak dibaca
    final magnitude = (maxValue / 5).ceil();
    return (magnitude * 5).toDouble();
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
          final dueToday = doc.data()?['totalDueToday'] ?? 0;
          final overdue = doc.data()?['totalOverdue'] ?? 0;

          return dueToday + overdue;
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

  //HELPER LIMIT TEXT
  String limitText(String text, int max) {
    return text.length <= max ? text : "${text.substring(0, max)}...";
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
              const SizedBox(height: 20),
              _repairLineChartCard(),
            ],
          ),
        ),
      ),

      // index 1
      // const CapturePage(),

      // index 2
      const InventoryPage(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
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
                  child: const Icon(Icons.qr_code, color: MyColors.white),
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
                  limitText(name, 25),
                  overflow: TextOverflow.ellipsis,
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
                          valueColor: const AlwaysStoppedAnimation(
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
                title: 'Total Item',
                value: '...',
                subtitle: 'Memuat data',
                icon: Icons.inventory_2_outlined,
              );
            }

            if (snapshot.hasError) {
              return _statCard(
                title: 'Total Item',
                value: '-',
                subtitle: 'Gagal memuat data',
                icon: Icons.inventory_2_outlined,
              );
            }

            final totalItems = snapshot.data ?? 0;

            return _statCard(
              title: 'Total Item',
              value: '$totalItems',
              subtitle: 'Jenis barang terdaftar',
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
              value: '$totalOutOfStock',
              subtitle: 'Stok yang kosong saat ini',
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
                    color: MyColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: MyColors.secondary),
                ),
              ),
            ),
            // const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
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

  Future<Map<String, List<int>>> getWeeklyRepairData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final snapshot = await FirebaseFirestore.instance
        .collection('repair')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .get();

    List<int> warranty = [0, 0, 0, 0];
    List<int> nonWarranty = [0, 0, 0, 0];
    List<int> completed = [0, 0, 0, 0];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      final category = data['repairCategory'];
      final status = data['status'].toString().toLowerCase();

      int weekIndex = ((createdAt.day - 1) ~/ 7);
      if (weekIndex > 3) weekIndex = 3;

      // Line 1 - Warranty (SEMUA STATUS)
      if (category == 'warranty') {
        warranty[weekIndex]++;
      }

      // Line 2 - Non Warranty (SEMUA STATUS)
      if (category == 'non_warranty') {
        nonWarranty[weekIndex]++;
      }

      // Line 3 - Completed Only
      if (status.contains('selesai')) {
        completed[weekIndex]++;
      }
    }

    return {
      'warranty': warranty,
      'nonWarranty': nonWarranty,
      'completed': completed,
    };
  }

  Widget _repairProgressCard() {
    return FutureBuilder<Map<String, int>>(
      future: getRepairSummary(30),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ringkasan Perbaikan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '30 hari terakhir',
                    style: TextStyle(
                      fontSize: 12,
                      color: MyColors.background,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
                valueColor: const AlwaysStoppedAnimation(MyColors.secondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _repairLineChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MyColors.greySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grafik Perbaikan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _chartMode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                  DropdownMenuItem(value: 'monthly', child: Text('Bulanan')),
                ],
                onChanged: (value) {
                  setState(() {
                    _chartMode = value!;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _LegendDot(color: Colors.orange, text: "Garansi"),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.blue, text: "Non Garansi"),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.green, text: "Total"),
            ],
          ),

          const SizedBox(height: 16),

          FutureBuilder<Map<String, List<int>>>(
            future: getWeeklyRepairData(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final warranty = snap.data!['warranty']!;
              final nonWarranty = snap.data!['nonWarranty']!;
              final total = List.generate(
                warranty.length,
                (i) => warranty[i] + nonWarranty[i],
              );

              return _buildLineChart(warranty, nonWarranty, total);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(
    List<int> warranty,
    List<int> nonWarranty,
    List<int> total,
  ) {
    final maxY =
        [
          ...warranty,
          ...nonWarranty,
          ...total,
        ].reduce((a, b) => a > b ? a : b).toDouble() +
        2;

    final interval = (maxY / 5).ceilToDouble();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 3,
          minY: 0,
          maxY: maxY,

          gridData: FlGridData(
            show: true,
            horizontalInterval: 2,
            drawVerticalLine: true,
          ),

          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            // Label bawah (M1–M4)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const titles = ['M1', 'M2', 'M3', 'M4'];
                  if (value.toInt() >= 0 && value.toInt() < titles.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        titles[value.toInt()],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),

            // Label kiri (Jumlah)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),

          lineBarsData: [
            // Line 1 - Garansi
            LineChartBarData(
              spots: List.generate(
                4,
                (i) => FlSpot(i.toDouble(), warranty[i].toDouble()),
              ),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),

            // Line 2 - Non Garansi
            LineChartBarData(
              spots: List.generate(
                4,
                (i) => FlSpot(i.toDouble(), nonWarranty[i].toDouble()),
              ),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),

            // Line 3 - Selesai
            LineChartBarData(
              spots: List.generate(
                4,
                (i) => FlSpot(i.toDouble(), total[i].toDouble()),
              ),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _LegendDot({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
