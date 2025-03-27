import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_editor/controller/controller.dart';

class TextEditorScreen extends StatelessWidget {
  final TextEditorController _controller = Get.put(TextEditorController());

  TextEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metin Düzenleyici'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_open),
            onPressed: () => _controller.openFile(),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _controller.saveFile(),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('iCloud\'a Kaydet'),
                onTap: () => _controller.saveToiCloud(),
              ),
              PopupMenuItem(
                child: const Text('iCloud\'dan Aç'),
                onTap: () => _controller.loadFromiCloud(),
              ),
            ],
          ),
        ],
      ),
      body: TextField(
        controller: _controller.textEditingController, // Doğrudan kullan
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: 'Metninizi buraya yazın...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}
