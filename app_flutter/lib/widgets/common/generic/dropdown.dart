import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AppDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData? icon;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
  });

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField2<String>(
      value: widget.value,
      isExpanded: true,

      // icon: const Icon(Icons.keyboard_arrow_down_rounded),
      // borderRadius: BorderRadius.circular(12),
      items: widget.items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(item, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),

      onChanged: widget.onChanged,

      // dropdown menu style
      dropdownStyleData: DropdownStyleData(
        maxHeight: 250,
        offset: const Offset(0, 0),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // 👈 rounded menu
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
      // 👇 SEARCH FEATURE
      dropdownSearchData: DropdownSearchData(
        searchController: searchController,

        searchInnerWidgetHeight: 60,

        searchInnerWidget: Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search currency...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),

        searchMatchFn: (item, searchValue) {
          return item.value!.toLowerCase().contains(searchValue.toLowerCase());
        },
      ),

      decoration: InputDecoration(
        labelText: widget.label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
