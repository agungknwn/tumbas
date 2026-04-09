import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class HeaderDropdown extends StatefulWidget {
  final List<String> items;
  final String? value;
  final String hint;
  final Function(String?) onChanged;

  const HeaderDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint = 'Select Item',
  });

  @override
  State<HeaderDropdown> createState() => _HeaderDropdownState();
}

class _HeaderDropdownState extends State<HeaderDropdown> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(widget.hint, style: const TextStyle(color: Colors.white70)),
        items: widget.items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            )
            .toList(),
        value: widget.value,
        onChanged: widget.onChanged,
        // ✨ This is how you style the selected item (White text)
        selectedItemBuilder: (context) {
          return widget.items.map((item) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList();
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.only(right: 8),
          height: 40,
          width: 100,
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(height: 40),
        // 🔍 SEARCH LOGIC START
        dropdownSearchData: DropdownSearchData(
          searchController: searchController,
          searchInnerWidgetHeight: 50,
          searchInnerWidget: Container(
            height: 50,
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 4,
              right: 8,
              left: 8,
            ),
            child: TextFormField(
              expands: true,
              maxLines: null,
              controller: searchController,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                hintText: 'Search...',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          searchMatchFn: (item, searchValue) {
            return item.value.toString().toLowerCase().contains(
              searchValue.toLowerCase(),
            );
          },
        ),
        // This clears the search when the menu closes
        onMenuStateChange: (isOpen) {
          if (!isOpen) searchController.clear();
        },
      ),
    );
  }
}
