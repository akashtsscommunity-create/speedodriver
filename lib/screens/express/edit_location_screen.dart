import 'package:flutter/material.dart';
import 'edit_location_from.dart';

class EditLocationScreen extends StatelessWidget {
  final String initialValue;
  final int mode;

  const EditLocationScreen({
    super.key,
    required this.initialValue,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Location"),
        backgroundColor: const Color(0xFFF05C14),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: EditLocationFrom(initialValue: initialValue, mode: mode),
      ),
    );
  }
}
