import 'package:flutter/material.dart';

class TimePickerDialogResult {
  final DateTime untilUtc;
  TimePickerDialogResult(this.untilUtc);
}

class CustomTimePickerDialog extends StatefulWidget {
  const CustomTimePickerDialog({super.key});

  @override
  State<CustomTimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<CustomTimePickerDialog> {
  DateTime _dtLocal = DateTime.now().add(const Duration(days: 1));

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      initialDate: _dtLocal,
    );
    if (d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dtLocal),
    );
    if (t == null) return;
    setState(
      () => _dtLocal = DateTime(d.year, d.month, d.day, t.hour, t.minute),
    );
  }

  TimePickerDialogResult _result() => TimePickerDialogResult(_dtLocal.toUtc());

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1, hours: 9));
    final nextWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 7, hours: 9));

    return AlertDialog(
      title: const Text('Time Picker'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Tomorrow morning'),
            subtitle: Text(tomorrow.toString()),
            onTap: () => Navigator.pop(
              context,
              TimePickerDialogResult(tomorrow.toUtc()),
            ),
          ),
          ListTile(
            title: const Text('Next week'),
            subtitle: Text(nextWeek.toString()),
            onTap: () => Navigator.pop(
              context,
              TimePickerDialogResult(nextWeek.toUtc()),
            ),
          ),
          ListTile(
            title: const Text('Pick date & time'),
            subtitle: Text(_dtLocal.toString()),
            onTap: _pickDateTime,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _result()),
          child: const Text('Select'),
        ),
      ],
    );
  }
}
