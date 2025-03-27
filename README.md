# Simple Text Editor

Bu proje, Flutter kullanılarak geliştirilmiş basit bir metin düzenleyici uygulamasıdır. Kullanıcılar, metin dosyalarını açabilir, düzenleyebilir ve kaydedebilir. Ayrıca, dosyaları iCloud'a kaydedip tekrar yükleyebilirler.

## Özellikler
- **Dosya Açma**: Kullanıcılar cihazlarından `.txt` dosyaları seçebilir ve düzenleyebilir.
- **Dosya Kaydetme**: Mevcut dosya üzerine kaydedilebilir veya yeni bir dosya oluşturulabilir.
- **iCloud Senkronizasyonu**:
  - Dosyalar iCloud'a kaydedilebilir.
  - iCloud'daki dosyalar tekrar yüklenebilir.
- **GetX Kullanımı**: Durum yönetimi ve bağlantılı bileşenler için GetX kullanılmaktadır.

## Kurulum
1. **Projeyi klonlayın:**
   ```sh
   git clone https://github.com/username/simple_text_editor.git
   cd simple_text_editor
   ```
2. **Gerekli paketleri yükleyin:**
   ```sh
   flutter pub get
   ```
3. **Uygulamayı çalıştırın:**
   ```sh
   flutter run
   ```

## Kullanılan Paketler
- [GetX](https://pub.dev/packages/get): Durum yönetimi ve navigasyon için.
- [File Picker](https://pub.dev/packages/file_picker): Dosya seçme işlemi için.
- [Path Provider](https://pub.dev/packages/path_provider): Uygulama dizinlerine erişim için.

## Dosya Yapısı
```
/simple_text_editor
├── lib/
│   ├── main.dart        # Uygulamanın giris noktasi
│   ├── controller.dart  # GetX controller dosyası
│   ├── views/
│       ├── text_editor_screen.dart # Metin düzenleme ekranı
└── pubspec.yaml         # Bağımlı paketler
```

## Kullanım
- **Dosya Açma**: "Dosya Aç" butonuna tıklayarak bir `.txt` dosyası seçin.
- **Metni Düzenleme**: Dosyanın içeriğini düzenleyin.
- **Dosya Kaydetme**: "Kaydet" ikonuna tıklayarak dosyanızı saklayın.
- **iCloud Kaydetme**: "iCloud'a Kaydet" menüsünden dosyanızı iCloud'a yükleyin.
- **iCloud'dan Yükleme**: "iCloud'dan Aç" menüsü ile iCloud'daki dosyalarınıza erişin.

## Lisans
Bu proje MIT lisansı altında sunulmuştur.

