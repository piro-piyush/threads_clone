import 'package:flutter/material.dart';

ButtonStyle authButtonStyle(Color background, Color foreground) {
  return ButtonStyle(minimumSize: WidgetStateProperty.all<Size>(const Size.fromHeight(40.0)), backgroundColor: WidgetStateProperty.all<Color>(background), foregroundColor: WidgetStateProperty.all<Color>(foreground));
}

// * Custom Outline button style
ButtonStyle customOutlineStyle() {
  return ButtonStyle(
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: Color(0xff242424), width: 0.1, style: BorderStyle.solid),
      ),
    ),
    backgroundColor: WidgetStateProperty.all<Color>(const Color(0xff242424)),
    minimumSize: WidgetStateProperty.all(Size.zero),
    padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
  );
}
