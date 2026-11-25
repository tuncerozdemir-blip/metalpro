# MetalPro — Appetize için iOS hazırlığı

Appetize iOS tarafında **`.ipa` kabul etmez**; yalnızca Xcode ile üretilmiş
**iOS Simulator `.app`** paketini (`.zip` / `.tar.gz` içinde) yükler. Bu nedenle
Windows'ta `.ipa` üretmeye çalışmak yerine imzasız simülatör derlemesi
hazırlandı. Apple Developer hesabı **gerekmez**.

## Projede hazır olanlar

- `ios/` Flutter iOS iskeleti (Swift Paket Yöneticisi; `Podfile` yok)
- Paket adı: `com.metalpro.app`, görünen ad: `MetalPro`
- Dikey yönelim, koyu açılış ekranı, MetalPro ikon seti (20–1024 px)
- `codemagic.yaml`: macOS runner'da `flutter build ios --simulator` + zip
- `tools/ios_simulator_build.sh`: yerel Mac için aynı derleme
- `tools/gen_icons.py`: PWA ve iOS ikonlarını üreten script

## Yöntem A — Codemagic (Mac gerekmez)

1. **GitHub repo oluştur.** Repo kökü `metalpro_app` klasörü olsun:

   ```powershell
   cd C:\Users\Tuncer\OPENCODE\Metal\Deneme-1\metalpro_app
   git init
   git add .
   git commit -m "MetalPro iOS simulator hazirligi"
   git branch -M main
   git remote add origin https://github.com/<kullanici>/<repo>.git
   git push -u origin main
   ```

2. https://codemagic.io/signup → giriş → **Add application** → GitHub → repo’yu seç.
3. Yapılandırma olarak **`codemagic.yaml`** dosyasını seç (**Check for configuration**),
   workflow: `ios-simulator-appetize` → **Start new build**.
4. Build bitince **Artifacts** bölümünden `MetalPro-ios-simulator.zip` dosyasını indir.
5. https://appetize.io/upload → **iOS** → zip dosyasını yükle → **Launch**.
   Yüklendikten sonra `https://appetize.io/apps` sayfasında hesabınız altında görünür.

## Yöntem B — Yerel Mac varsa

```bash
chmod +x tools/ios_simulator_build.sh
./tools/ios_simulator_build.sh
```

Çıktı: `MetalPro-ios-simulator.zip` (proje kökünde). Sonrasında Appetize’a yükleyin.

## İsteğe bağlı — Codemagic’ten otomatik Appetize yüklemesi

1. Appetize hesap sayfasından **API token** oluştur.
2. Uygulamayı bir kez elle yükle (5. adım); ardından uygulamanın **publicKey**
   değerini al.
3. Codemagic → Environment variables → `appetize_credentials` grubu:
   - `APPETIZE_API_TOKEN`
   - `APPETIZE_APP_PUBLIC_KEY` (secret olarak işaretle)
4. `codemagic.yaml` içinde `environment` bölümüne ekle:

   ```yaml
   environment:
     groups:
       - appetize_credentials
   ```

   ve dosyanın sonundaki `publishing` bloğunun yorum satırlarını kaldır.

## Alternatif — Codemagic App Preview

Codemagic'in kendi tarayıcı simülatörü de var: build artifacts ekranında
`Runner.app` yanındaki **Quick Launch** düğmesiyle uygulama tarayıcıda açılır.
Takım (team) hesabı ve ücretsiz 100 dakika deneme süresi gerekir; Appetize
hesabı gerekmez.

## Kontroller

- `flutter analyze` → 0 sorun
- `flutter test` → 9/9 geçti
- iOS ikonları: 15 dosya, 20×20 → 1024×1024
- `Info.plist` görünen ad `MetalPro`, yönelim yalnızca portrait
- `.app` derlemesi yalnızca macOS + Xcode ortamında yapılabilir; bu Windows
  makinede doğrulanamaz.
