import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = "V ${info.version}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.only(left: 20, right: 20),
        backgroundColor: MyColors.white,
        automaticallyImplyLeading: false,
        title: Text(
          _version,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, size: 30),
          ),
        ],
      ),
      backgroundColor: MyColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// HEADER
              Container(
                color: MyColors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: MyColors.white, // dasar putih
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            /// Gambar full
                            Positioned.fill(
                              child: Image.asset(
                                "assets/images/about_image.jpeg",
                                fit: BoxFit.cover,
                              ),
                            ),

                            /// Gradient putih → transparan
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      MyColors.white,
                                      MyColors.white.withValues(alpha: 0.8),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// Text
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Manajemen Aset\nCerdas Untuk PT KITA",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "KITA SMART ASSETS dikembangkan untuk PT KITA, "
                                    "membantu dalam mengelola dan memonitor aset "
                                    "perusahaan dengan lebih cerdas dan efisien.",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// FITUR UTAMA
              Container(
                color: const Color(0xffF2F2F2),
                child: Column(
                  children: [
                    InnerShadow(
                      blur: 15,
                      color: MyColors.black.withValues(alpha: 0.15),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        color: const Color(0xffF2F2F2),
                        child: const Column(
                          children: [
                            Text(
                              "Fitur Utama",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(height: 8),
                            Text("Fitur Aplikasi KITA"),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _FeatureCard(
                                  title: "Pencatatan\nDigital",
                                  imageUrl: "assets/images/digital_image.jpeg",
                                ),
                                _FeatureCard(
                                  title: "Deteksi\nBarang",
                                  imageUrl: "assets/images/detector_image.jpeg",
                                ),
                                _FeatureCard(
                                  title: "Monitoring\nBarang",
                                  imageUrl:
                                      "assets/images/monitoring_image.jpeg",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// TIM
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: MyColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: MyColors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Text(
                            "Tim Pengembang",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text("Dikembangkan Oleh"),

                          SizedBox(height: 20),

                          Wrap(
                            alignment: WrapAlignment.spaceEvenly,
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              _DevItem(
                                name: "A Wahab S",
                                imageUrl: "assets/images/wahab_image.jpeg",
                              ),
                              _DevItem(
                                name: "M. Fahlevy MS",
                                imageUrl: "assets/images/fahlevy_image.jpeg",
                              ),
                              _DevItem(
                                name: "Abdul Mughni",
                                imageUrl: "assets/images/mughni_image.jpeg",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// FOOTER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(color: Color(0xffD4A15A)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// LOGO KIRI
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/polnes_icon.svg",
                              height: 40,
                            ),
                            const SizedBox(width: 8),
                            SvgPicture.asset(
                              "assets/icons/ti_icon.svg",
                              height: 40,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    /// TEXT KANAN
                    const Text(
                      "Jurusan Teknologi Informasi\n"
                      "Politeknik Negeri Samarinda\n"
                      "2026",
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 10, color: MyColors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const _FeatureCard({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _DevItem extends StatelessWidget {
  final String name;
  final String imageUrl;

  const _DevItem({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            imageUrl,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(name, textAlign: TextAlign.center),
        const Text(
          "Developer",
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
        ),
      ],
    );
  }
}

class InnerShadow extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color color;

  const InnerShadow({
    super.key,
    required this.child,
    this.blur = 10,
    this.color = MyColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _InnerShadowPainter(blur: blur, color: color),
      child: child,
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  final double blur;
  final Color color;

  _InnerShadowPainter({required this.blur, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final outerRect = Rect.fromLTWH(
      -blur,
      -blur,
      size.width + blur * 2,
      size.height + blur * 2,
    );

    final path = Path()
      ..addRect(outerRect)
      ..addRect(rect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
