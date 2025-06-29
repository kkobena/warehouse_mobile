import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback? onDateRangeTap;
  final VoidCallback? onRefreshTap;
  final List<Widget>? additionalActions;
  final Widget? titleWidget;
  final PreferredSizeWidget? bottomWidget;

  const CustomAppBar({
    Key? key,
    this.fromDate,
    this.toDate,
    this.onDateRangeTap,
    this.onRefreshTap,
    this.additionalActions,
    this.titleWidget,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final DateFormat displayDateFormat = DateFormat('dd MMM', 'fr_FR');
    final HSLColor hslPrimary = HSLColor.fromColor(primaryColor);
    double lightnessIncrease = 0.25;
    final HSLColor hslLighterPrimary = hslPrimary.withLightness(
      (hslPrimary.lightness + lightnessIncrease).clamp(0.0, 1.0),
    );
    final Color lighterPrimaryColor = hslLighterPrimary.toColor();
    final Color appBarForegroundColor = Theme.of(context).colorScheme.onPrimary;

    final Color gradientStart = primaryColor;
    final Color gradientEnd = lighterPrimaryColor;
    Color gradientForegroundColor = Theme.of(context).colorScheme.onPrimary;
    final List<Color> effectiveGradientColors = [gradientStart, gradientEnd];

    Widget? currentTitle;

    if (fromDate != null && toDate != null && onDateRangeTap != null) {
      currentTitle = InkWell(
        onTap: onDateRangeTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Text(
                  // Use null-aware operators, though assertion helps ensure they are not null here
                  '${displayDateFormat.format(fromDate!)} - ${displayDateFormat.format(toDate!)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: appBarForegroundColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 24,
                color: appBarForegroundColor,
              ),
            ],
          ),
        ),
      );
    } else if (titleWidget != null) {
      currentTitle = titleWidget;
    }

    return AppBar(
      title: currentTitle,
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: appBarForegroundColor,
      centerTitle: true, // Keep this true if you want the custom title or date range centered
      titleSpacing: NavigationToolbar.kMiddleSpacing,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: effectiveGradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: <Widget>[
        if (onRefreshTap != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            style: TextButton.styleFrom(
              foregroundColor: gradientForegroundColor,
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            ),
            onPressed: onRefreshTap,
          ),
        if (additionalActions != null) ...additionalActions!,
        // Use null-check operator
      ],
      bottom: bottomWidget,
    );
  }


  @override
  Size get preferredSize {
    // kMinInteractiveDimension is often used for touch targets, like an IconButton.
    // kToolbarHeight is the standard height of an AppBar's main section.
    // If you always want a minimum height (like kMinInteractiveDimension),
    // ensure it's at least kToolbarHeight if no bottom is present,
    // or kToolbarHeight + bottomWidget.preferredSize.height if a bottom is present.

    final double mainAppBarHeight = kToolbarHeight-10; // Or kToolbarHeight

    if (bottomWidget != null) {
      return Size.fromHeight(mainAppBarHeight + bottomWidget!.preferredSize.height);
    }
    return Size.fromHeight(mainAppBarHeight);
  }
  // Add extra space for padding
}
