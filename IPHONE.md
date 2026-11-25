# MetalPro — iPhone (PWA / Ana Ekrana Ekle)

iPhone'a gerçek `.ipa` kurmak için macOS + Xcode gerekir. Bu klasör, aynı uygulamayı
iOS Safari içinde "Ana Ekrana Ekle" ile uygulama gibi açan PWA sürümünü içerir.

## Kurulum

1. Bilgisayarda `MetalPro-iPhone-PWA.bat` dosyasına çift tıkla. Açılan pencerede
   `iPhone Safari adresi: http://192.168.0.174:8080` gibi bir adres görünecek.
   Pencereyi açık bırak.
2. iPhone bu bilgisayarla **aynı Wi-Fi** ağına bağlı olmalı.
3. iPhone'da **Safari** ile görüntülenen adresi aç.
4. Safari altındaki **Paylaş** düğmesine → **Ana Ekrana Ekle** → **Ekle**.
5. Ana ekranda **MetalPro** ikonu oluşur; dokunarak tam ekran açılır.

## Notlar

- Kısayol yalnızca bilgisayar açıkken ve aynı Wi-Fi'de çalışır.
- İlk çalıştırmada Windows Güvenlik Duvarı izin isteyebilir; **Özel ağ** için izin ver.
- Web'de `path_provider` desteklenmediği için **KAYDET** düğmesi gizlidir;
  sonucu **PAYLAŞ** ile iOS paylaşım menüsünden gönderebilirsin.
- Uygulama verileri cihazda tutulmaz; her açılışta hesaplama ekranından başlar.
- Başka bir ağdan/İnternet'ten erişim için HTTPS hosting (Netlify, Cloudflare Pages)
  gerekir; bu hazırlanırsa PWA çevrimdışı da çalışır.

## Geliştirme

```powershell
flutter test
flutter build web --release
python tools\gen_icons.py
```
