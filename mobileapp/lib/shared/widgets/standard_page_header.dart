import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

class StandardPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Widget? actionButton;
  final bool showSearch;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHint;
  final VoidCallback? onSearchFilterPressed;

  const StandardPageHeader({
    super.key,
    required this.title,
    this.onBackPressed,
    this.showBackButton = true,
    this.actionButton,
    this.showSearch = false,
    this.searchController,
    this.onSearchChanged,
    this.searchHint,
    this.onSearchFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      child: showSearch
          ? Row(
              children: [
                // Back button (only show if showBackButton is true)
                if (showBackButton) _buildBackButton(context),
                if (showBackButton) const SizedBox(width: 12),
                // Search bar
                Expanded(
                  child: _buildSearchBar(context),
                ),
              ],
            )
          : Row(
              children: [
                // Back button (only show if showBackButton is true)
                if (showBackButton) _buildBackButton(context),
                if (showBackButton) const SizedBox(width: 12),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Action button (optional)
                if (actionButton != null) ...[
                  const SizedBox(width: 8),
                  actionButton!,
                ],
              ],
            ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onBackPressed ??
            () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/home');
              }
            },
        icon: const Icon(Icons.arrow_back_ios_new),
        iconSize: 20,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: const TextStyle(color: Colors.grey),
        cursorColor: Colors.grey,
        decoration: InputDecoration(
          hintText: searchHint ?? 'Search...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
          suffixIcon: searchController?.text.isNotEmpty == true
              ? Container(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () {
                      searchController?.clear();
                      onSearchChanged?.call('');
                    },
                    child: Icon(
                      Icons.clear_rounded,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                )
              : onSearchFilterPressed != null
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      child: GestureDetector(
                        onTap: onSearchFilterPressed,
                        child: Icon(
                          Icons.tune_rounded,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    )
                  : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: AppConstants.primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

