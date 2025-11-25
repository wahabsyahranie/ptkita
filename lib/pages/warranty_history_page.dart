import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';

/// Data Garansi page
/// - Search bar
/// - Filter (All / Aktif / Non-Aktif)
/// - Kartu garansi versi baru (badge sejajar nama, tanggal kanan)
/// - Pull-to-refresh & random data (sementara)
class DataGaransiPage extends StatefulWidget {
  const DataGaransiPage({super.key});

  @override
  State<DataGaransiPage> createState() => _DataGaransiPageState();
}

class _DataGaransiPageState extends State<DataGaransiPage> {
  final TextEditingController _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  String _statusFilter = 'all'; // 'all' | 'active' | 'non'

  @override
  void initState() {
    super.initState();
    _items = _generateRandomData(8);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _items = _generateRandomData(8));
  }

  void _setFilter(String f) => setState(() => _statusFilter = f);

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFF7F6F3);
    final query = _search.text.trim().toLowerCase();
    final filtered = _items.where((e) {
      if (query.isNotEmpty) {
        final qmatch =
            (e['buyer'] as String).toLowerCase().contains(query) ||
            (e['product'] as String).toLowerCase().contains(query) ||
            (e['serial'] as String).toLowerCase().contains(query);
        if (!qmatch) return false;
      }
      if (_statusFilter == 'active') return (e['active'] as bool) == true;
      if (_statusFilter == 'non') return (e['active'] as bool) == false;
      return true; // all
    }).toList();

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: const Text('Data Garansi'),
        backgroundColor: pageBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SearchBarWidget(
                controller: _search,
                hintText: 'Nama Pembeli / Nomor Seri',
                onChanged: (_) => setState(() {}),
              ),
            ),

            // Filter chips (All / Aktif / Non-Aktif)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  _FilterChipButton(
                    label: 'Semua',
                    active: _statusFilter == 'all',
                    onTap: () => _setFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipButton(
                    label: 'Aktif',
                    active: _statusFilter == 'active',
                    onTap: () => _setFilter('active'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipButton(
                    label: 'Non-Aktif',
                    active: _statusFilter == 'non',
                    onTap: () => _setFilter('non'),
                  ),
                ],
              ),
            ),

            // list
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: filtered.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 60),
                          Center(
                            child: Text(
                              'Tidak ada data. Tarik ke bawah untuk refresh.',
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _DataGaransiCard(data: filtered[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search bar widget (keadaan stateless; parent memaksa rebuild)
// class _SearchBar extends StatelessWidget {
//   const _SearchBar({required this.controller, required this.onChanged});
//   final TextEditingController controller;
//   final VoidCallback onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: MyColors.white,
//         borderRadius: BorderRadius.circular(28),
//         border: Border.all(color: MyColors.secondary.withOpacity(0.22)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.search_rounded, color: MyColors.secondary),
//           const SizedBox(width: 10),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               onChanged: (_) => onChanged(),
//               decoration: InputDecoration(
//                 hintText: 'Nama Pembeli / No Seri Pembelian',
//                 hintStyle: TextStyle(
//                   color: MyColors.secondary.withOpacity(0.6),
//                 ),
//                 border: InputBorder.none,
//                 isDense: true,
//               ),
//             ),
//           ),
//           if (controller.text.isNotEmpty)
//             GestureDetector(
//               onTap: () {
//                 controller.clear();
//                 onChanged();
//               },
//               child: Icon(
//                 Icons.close_rounded,
//                 color: MyColors.secondary.withOpacity(0.7),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

/// small toggle-like chip button
class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? MyColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? MyColors.white : MyColors.secondary,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: active ? MyColors.white : MyColors.background,
          ),
        ),
      ),
    );
  }
}

/* =========================
   Card widget (badge aligned with buyer name)
   - top row: badge | buyer (left) --- date (right)
   - below: product (bold) and subtitle
   ========================= */
class _DataGaransiCard extends StatelessWidget {
  const _DataGaransiCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final bool active = data['active'] as bool;
    final dateText = data['dateText'] as String;
    final buyer = data['buyer'] as String;
    final product = data['product'] as String;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigator.push to detail page (pass data)
        },
        child: Container(
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top row: badge + buyer + date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _MiniBadge(active: active),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        buyer,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 12,
                        color: MyColors.secondary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // product title
                Text(
                  product,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                // subtitle
                Text(
                  data['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// mini badge (same as before)
class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final bg = active ? const Color(0xFFDFF7E5) : const Color(0xFFFFF1E0);
    final fg = active ? const Color(0xFF1E8A3D) : const Color(0xFFB87112);
    final txt = active ? 'Aktif' : 'Non-Aktif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        txt,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

/* =========================
   Dummy generator (only allowed subtitle values)
   ========================= */
List<Map<String, dynamic>> _generateRandomData(int count) {
  final rnd = Random();
  final buyers = [
    'Abdul Muhgni',
    'Fahlevy',
    'Rafli',
    'Aulia',
    'Nadia',
    'Bintang',
  ];
  final products = [
    'Alkon Hyundai',
    'Bor Listrik',
    'Mesin Las',
    'Sirkular Saw',
  ];
  final subtitles = [
    'Garansi Servis Jasa',
    'Garansi Sparepart',
    'Garansi Servis Jasa & Sparepart',
  ];

  String fmtShort(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  return List.generate(count, (_) {
    final d = DateTime.now().subtract(Duration(days: rnd.nextInt(1000)));
    final active = rnd.nextBool();
    return {
      'buyer': buyers[rnd.nextInt(buyers.length)],
      'product': products[rnd.nextInt(products.length)],
      'serial': 'SN-${10000 + rnd.nextInt(89999)}',
      'date': d,
      'dateText': fmtShort(d),
      'subtitle': subtitles[rnd.nextInt(subtitles.length)],
      'active': active,
    };
  });
}
