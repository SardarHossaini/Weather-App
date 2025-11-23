import 'package:flutter/material.dart';

class SearchDialog extends StatelessWidget {
  final Function(String) onCitySearched;
  final TextEditingController controller;

  const SearchDialog({
    super.key,
    required this.onCitySearched,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F3A5F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Search City",
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Enter city name...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[600]!),
          ),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.pop(context);
            onCitySearched(value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ),
      ],
    );
  }
}
