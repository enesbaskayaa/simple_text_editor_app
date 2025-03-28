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
        title: Obx(() => Text(_controller.windowTitle)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_open),
            onPressed: () => _controller.openFile(),
            tooltip: 'Dosya Aç',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _controller.saveFile(),
            tooltip: 'Kaydet',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _controller.newFile(),
            tooltip: 'Yeni Dosya',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black87,
              child: TextField(
                controller: _controller.textEditingController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Metninizi buraya yazın...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                cursorColor: Colors.white,
              ),
            ),
          ),
          Container(
            color: Colors.black12,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(
                  () => Text(
                    'Karakter: ${_controller.fileContent.value.length}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
