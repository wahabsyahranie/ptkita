import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/navigation_bottom_widget.dart';
import 'package:flutter_kita/widget/navigation_drawer_widget.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: NavigationDrawerWidget(),
      backgroundColor: MyColors.white,
      body: SafeArea(
        //Leading
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang,',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Wahab Syahranie',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      return Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: MyColors.secondary,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.notifications,
                              color: MyColors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: Container(
                              width: 53,
                              height: 53,
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                'assets/images/person_image.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),

              //SEARCH BAR
              SearchBarWidget(),
            ],
          ),
        ),
      ),

      //NAVIGASI BAWAH MENGGUNAKAN PUB.dev
      bottomNavigationBar: NavigationBottomWidget(),
    );
  }
}
