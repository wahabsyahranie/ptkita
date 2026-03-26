import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';

class InventoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddPressed;
  final VoidCallback onFilterPressed;
  final VoidCallback onToggleView;
  final bool isGrid;

  const InventoryAppBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onAddPressed,
    required this.onFilterPressed,
    required this.onToggleView,
    required this.isGrid,
  });

  @override
  Size get preferredSize => const Size.fromHeight(110);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MyColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      title: const Text("Data Barang"),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: SearchBarWidget(
                  controller: searchController,
                  hintText: 'Cari barang...',
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 10),
              _circleButton(Icons.add, onAddPressed),
              const SizedBox(width: 10),
              _circleButton(Icons.filter_alt, onFilterPressed),
              const SizedBox(width: 10),
              //NEW BUTTON (TOGGLE VIEW)
              _circleButton(
                isGrid ? Icons.view_list : Icons.grid_view,
                onToggleView,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: MyColors.secondary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: MyColors.white),
      ),
    );
  }
}
