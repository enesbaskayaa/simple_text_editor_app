import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class TextEditorController extends GetxController {
  final Rx<File?> currentFile = Rx<File?>(null);
  final RxString fileContent = ''.obs;
  final RxString savedContent = ''.obs;
  final RxString fileName = 'Untitled.txt'.obs;
  final RxBool hasChanges = false.obs;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    textEditingController.text = fileContent.value;
    setupContentListener();
  }

  void updateContent(String content) {
    if (fileContent.value != content) {
      fileContent.value = content;
      if (textEditingController.text != content) {
        textEditingController.value = TextEditingValue(
          text: content,
          selection: TextSelection.collapsed(offset: content.length),
        );
      }
      // Değişiklikleri kontrol et
      hasChanges.value = fileContent.value != savedContent.value;
    }
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }

  void setupContentListener() {
    textEditingController.addListener(() {
      final currentText = textEditingController.text;
      fileContent.value = currentText;
      hasChanges.value = currentText != savedContent.value;
    });
  }

  String get windowTitle {
    return hasChanges.value ? '${fileName.value}*' : fileName.value;
  }

  Future<String> get platformSpecificDirectory async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      return '${dir?.path}/Documents';
    } else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
    return (await getApplicationDocumentsDirectory()).path;
  }

  Future<void> openFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null && result.files.single.path != null) {
        final originalFile = File(result.files.single.path!);

        // 1. DOSYANIN ZATEN DOCUMENTS'DA OLUP OLMADIĞINI KONTROL ET
        final directory = await getApplicationDocumentsDirectory();
        final fileName = originalFile.path.split('/').last;
        final persistentFile = File('${directory.path}/$fileName');

        // 2. EĞER DOSYA DOCUMENTS'DA YOKSA KOPYALA
        if (!await persistentFile.exists()) {
          await originalFile.copy(persistentFile.path);
          debugPrint("📂 Yeni kopya oluşturuldu: ${persistentFile.path}");
        } else {
          debugPrint("📂 Mevcut dosya açılıyor: ${persistentFile.path}");
        }

        // 3. HER DURUMDA PERSISTENT FILE'İ KULLAN
        currentFile.value = persistentFile;
        String content = await persistentFile.readAsString();
        updateContent(content);
      }
    } catch (e) {
      Get.snackbar('Hata', 'Dosya açma hatası: $e');
    }
  }

  Future<void> saveFile() async {
    try {
      // Boş içerik kontrolü (sadece yeni dosyalar için)
      if (currentFile.value == null && fileContent.value.isEmpty) {
        Get.snackbar(
          'Uyarı',
          'Boş dosya kaydedilemez!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
        );
        return;
      }

      if (currentFile.value == null) {
        final bytes = utf8.encode(fileContent.value);

        String? selectedPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Dosyayı Kaydet',
          fileName: fileName.value.replaceAll('*', ''),
          type: FileType.custom,
          allowedExtensions: ['txt'],
          bytes: bytes,
        );

        if (selectedPath != null) {
          if (!selectedPath.endsWith('.txt')) selectedPath += '.txt';
          final newFile = File(selectedPath);

          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
            await newFile.writeAsString(fileContent.value);
          }

          currentFile.value = newFile;
          fileName.value = newFile.path.split('/').last;
          savedContent.value = fileContent.value;
          hasChanges.value = false;

          Get.snackbar('Başarılı', 'Dosya kaydedildi: ${newFile.path}');
        }
      } else {
        await currentFile.value!.writeAsString(fileContent.value);
        savedContent.value = fileContent.value;
        hasChanges.value = false;
        Get.snackbar('Başarılı', 'Değişiklikler kaydedildi');
      }
    } catch (e) {
      log('Dosya kaydetme hatası: $e');
      Get.snackbar('Hata', 'Kaydetme başarısız: $e');
    }
  }

  Future<void> newFile() async {
    if (hasChanges.value) {
      final result = await Get.dialog(
        AlertDialog(
          title: const Text('Kaydedilmemiş Değişiklikler'),
          content: const Text('Kaydedilmemiş değişiklikleriniz var. Yine de devam etmek istiyor musunuz?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Yeni Dosya'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                saveFile();
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      );

      if (result != true) return;
    }

    currentFile.value = null;
    fileName.value = 'Untitled.txt';
    savedContent.value = '';
    fileContent.value = '';
    textEditingController.clear();
    hasChanges.value = false;
  }
}
