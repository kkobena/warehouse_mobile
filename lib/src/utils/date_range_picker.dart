import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';

class DateRangePicker extends StatefulWidget {
  final DateTime initialFromDate;
  final DateTime initialToDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime fromDate, DateTime toDate) onDateRangeSelected;

  const DateRangePicker({
    super.key,
    required this.initialFromDate,
    required this.initialToDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateRangeSelected,
  });

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  late DateTime _selectedFromDate;
  late DateTime _selectedToDate;

  @override
  void initState() {
    super.initState();
    _selectedFromDate = widget.initialFromDate;
    _selectedToDate = widget.initialToDate;
  }

  Future<void> _pickDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _selectedFromDate : _selectedToDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      // You can customize locale, builder, etc. here if needed
      locale: const Locale('fr', 'FR'),
      helpText: isFromDate
          ? 'SÉLECTIONNER DATE DE DÉBUT'
          : 'SÉLECTIONNER DATE DE FIN',
      cancelText: Constant.annuler,
      confirmText: Constant.select,
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _selectedFromDate = picked;
          // Ensure _toDate is not before _fromDate
          if (_selectedToDate.isBefore(_selectedFromDate)) {
            _selectedToDate = _selectedFromDate;
          }
        } else {
          _selectedToDate = picked;
          // Ensure _fromDate is not after _toDate
          if (_selectedFromDate.isAfter(_selectedToDate)) {
            _selectedFromDate = _selectedToDate;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            20, // Adjust for keyboard
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for bottom sheet height
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Constant.selectPeriodeText,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          _buildDateSelector(
            context,
            label: Constant.du,
            selectedDate: _selectedFromDate,
            dateFormat: dateFormat,
            onTap: () => _pickDate(context, true),
          ),
          const SizedBox(height: 16),
          _buildDateSelector(
            context,
            label: Constant.au,
            selectedDate: _selectedToDate,
            dateFormat: dateFormat,
            onTap: () => _pickDate(context, false),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(Constant.valider, style: TextStyle(fontSize: 16)),
            onPressed: () {
              widget.onDateRangeSelected(_selectedFromDate, _selectedToDate);
              Navigator.pop(context); // ClRose the bottom sheet
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            child: Text(
              Constant.annuler,
              style: TextStyle(color: colorScheme.primary),
            ),
            onPressed: () {
              Navigator.pop(
                context,
              ); // Close the bottom sheet without applying changes
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context, {
    required String label,
    required DateTime selectedDate,
    required DateFormat dateFormat,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.titleMedium),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(selectedDate),
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
