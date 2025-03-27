import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_editor/views/text_editor_screen.dart';

void main() {
  runApp(const SimpleTextEditorApp());
}

class SimpleTextEditorApp extends StatelessWidget {
  const SimpleTextEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Metin Düzenleyici',
      theme: ThemeData.dark(),
      home: TextEditorScreen(),
    );
  }
}
