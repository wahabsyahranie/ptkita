import 'package:flutter/material.dart';
import 'package:flutter_kita/models/repair/repair_summary_model.dart';
import 'package:flutter_kita/models/repair/weekly_repair_chart_model.dart';
import 'package:flutter_kita/models/user/user_model.dart';
import 'package:flutter_kita/pages/capture/capture_page.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/navigation_bottom_widget.dart';
import 'package:flutter_kita/widget/navigation_drawer_widget.dart';
import 'package:flutter_kita/pages/inventory/inventory_page.dart';
import 'package:flutter_kita/services/user/user_service.dart';
import 'package:flutter_kita/repositories/user/firestore_user_repository.dart';
import 'package:flutter_kita/services/home/home_service.dart';
import 'package:flutter_kita/repositories/home/firestore_home_repository.dart';
import 'widgets/home_header.dart';
import 'widgets/maintenance_card.dart';
import 'widgets/statistic_cards.dart';
import 'widgets/repair_progress_card.dart';
import 'widgets/repair_chart_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeService _homeService;
  late final UserService _userService;
  late final Future<RepairSummaryModel> _repairSummaryFuture;
  late final Future<WeeklyRepairChartModel> _weeklyChartFuture;

  //menambah controller search bar di sini
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  // for line chart filter
  String _chartMode = 'weekly'; // weekly / monthly

  void _onTapNav(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _homeService = HomeService(FirestoreHomeRepository());
    _userService = UserService(FirestoreUserRepository());
    _repairSummaryFuture = _homeService.repairSummary(30);
    _weeklyChartFuture = _homeService.weeklyRepairData();
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
              MaintenanceCard(
                totalStream: _homeService.totalMaintenanceToday(),
                completedStream: _homeService.completedMaintenanceToday(),
              ),
              const SizedBox(height: 20),
              StatisticCards(
                totalItemsStream: _homeService.totalItems(),
                outOfStockStream: _homeService.outOfStock(),
                onOutOfStockTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InventoryPage(
                        initialAvailability: 'habis',
                        fromPush: true,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              RepairProgressCard(future: _repairSummaryFuture),

              const SizedBox(height: 20),
              RepairChartCard(
                future: _weeklyChartFuture,
                chartMode: _chartMode,
                onModeChanged: (mode) {
                  setState(() {
                    _chartMode = mode;
                  });
                },
              ),
            ],
          ),
        ),
      ),

      // index 1
      // const CapturePage(),

      // index 2
      InventoryPage(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: MyColors.white,
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
    return StreamBuilder<UserModel>(
      stream: _userService.currentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        return HomeHeader(
          user: snapshot.data!,
          onAvatarTap: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
        );
      },
    );
  }
}
