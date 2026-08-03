import 'package:flutter/material.dart';

const Color primaryGreen = Color.fromARGB(224, 52, 77, 53);
const Color buttonGreen = Color.fromARGB(255, 62, 86, 64);
const Color textGreen = Color.fromARGB(255, 1, 32, 2);

InputDecoration inputDecoration(String hint, IconData icon) => InputDecoration(
  hintText: hint,
  prefixIcon: Icon(icon, color: const Color.fromARGB(255, 50, 90, 51)),
  filled: true,
  fillColor: const Color.fromARGB(255, 234, 228, 228),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
);
