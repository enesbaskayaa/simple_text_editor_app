import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class TextEditorController extends GetxController {
  final Rx<File?> currentFile = Rx<File?>(null);
  final RxString fileContent = ''.obs;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    /// İlk açılışta TextField içeriğini ayarla
    textEditingController.text = fileContent.value;

    /// Kullanıcı değişiklik yaptıkça RxString'i güncelle
    textEditingController.addListener(() {
      if (fileContent.value != textEditingController.text) {
        fileContent.value = textEditingController.text;
      }
    });
  }

  void updateContent(String content) {
    if (fileContent.value != content) {
      fileContent.value = content;
      if (textEditingController.text != content) {
        textEditingController.text = content;
        textEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: content.length),
        ); // 🔥 İmleci sona getir
      }
    }
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
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
      File? file = currentFile.value;
      if (file != null) {
        debugPrint("💾 Kaydedilen dosya yolu: ${file.path}");

        var raf = file.openSync(mode: FileMode.write);
        raf.writeStringSync(fileContent.value);
        raf.flushSync(); // 🔥 Disk senkronizasyonu sağlar
        raf.closeSync();

        // Dosyanın içeriğini tekrar okuyarak güncelle
        String savedContent = await file.readAsString();
        updateContent(savedContent); // 🔥 İçeriği güncelle
        debugPrint("💾 Kaydedilen içerik (Tekrar Okuma): $savedContent");

        Get.snackbar('Başarılı', 'Dosya kaydedildi');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final newFile = File('${directory.path}/new_file_${DateTime.now().millisecondsSinceEpoch}.txt');
        await newFile.writeAsString(fileContent.value);
        currentFile.value = newFile;

        // Yeni dosyanın içeriğini güncelle
        String newContent = await newFile.readAsString();
        updateContent(newContent); // 🔥 İçeriği güncelle
        debugPrint("📂 Yeni dosya oluşturuldu: ${newFile.path}");
        Get.snackbar('Başarılı', 'Yeni dosya kaydedildi');
      }
    } catch (e) {
      debugPrint("Hata: $e");
      Get.snackbar('Hata', 'Dosya kaydetme hatası: $e');
    }
  }

  Future<void> saveToiCloud() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final iCloudPath = '${directory.path}/iCloud';

      final iCloudDirectory = Directory(iCloudPath);
      if (!await iCloudDirectory.exists()) {
        await iCloudDirectory.create(recursive: true);
      }

      final fileName = currentFile.value?.path.split('/').last ?? 'new_file_${DateTime.now().millisecondsSinceEpoch}.txt';
      final iCloudFile = File('$iCloudPath/$fileName');
      await iCloudFile.writeAsString(fileContent.value);

      Get.snackbar('Başarılı', 'Dosya iCloud\'a kaydedildi');
    } catch (e) {
      Get.snackbar('Hata', 'iCloud kaydetme hatası: $e');
    }
  }

  Future<void> loadFromiCloud() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final iCloudPath = '${directory.path}/iCloud';

      final iCloudDirectory = Directory(iCloudPath);
      if (!await iCloudDirectory.exists()) {
        await iCloudDirectory.create(recursive: true);
      }

      List<FileSystemEntity> files = await iCloudDirectory.list().toList();
      List<File> txtFiles = files.whereType<File>().where((file) => file.path.endsWith('.txt')).toList();

      if (txtFiles.isEmpty) {
        Get.snackbar('Bilgi', 'iCloud dizininde txt dosyası bulunamadı');
        return;
      }

      File? selectedFile = await Get.dialog<File?>(
        AlertDialog(
          title: Text('iCloud Dosyaları'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: txtFiles.map((file) {
              return ListTile(
                title: Text(file.path.split('/').last),
                onTap: () => Get.back(result: file),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('İptal'),
            ),
          ],
        ),
      );

      if (selectedFile != null) {
        currentFile.value = selectedFile;
        fileContent.value = await selectedFile.readAsString();
      }
    } catch (e) {
      Get.snackbar('Hata', 'iCloud dosyaları alınamadı: $e');
    }
  }
}
