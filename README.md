# 🚀 Binance Radar iOS (Swift / SwiftUI Native)

Natywna aplikacja na system iOS napisana w 100% w **Swift / SwiftUI** w autentycznym stylu **Binance Pro Mobile (1:1)**, zintegrowana z natywnym sprzętowym skanerem **Apple Face ID (`LocalAuthentication`)** oraz animacjami 120 FPS ProMotion.

---

## 📱 Funkcje i Przepływ w Aplikacji

1. **Rejestracja (`RegisterView`):**
   - Pola: **E-mail**, **Numer telefonu (+48)**, **Hasło**, **Powtórz hasło**.
   - Przełącznik: **"Logowanie biometryczne (Face ID)"**.
   - Po kliknięciu **„Zarejestruj & Skanuj Face ID”**:
     - System iOS uruchamia **prawdziwe okno sprzętowe Apple Face ID**.
     - Po zeskanowaniu twarzy i akceptacji, aplikacja zapisuje konto i płynnie przełącza użytkownika do zakładki **Logowanie** z automatycznie wpisanym numerem telefonu.
2. **Logowanie (`LoginView`):**
   - **Przycisk 1:** Dedykowany, duży przycisk **„Loguj za pomocą Face ID”** (jedno dotknięcie skanuje twarz i loguje do aplikacji).
   - **Przycisk 2:** Logowanie tradycyjne (Numer telefonu / E-mail + Hasło).
3. **Lądowanie w Dashboardzie (120 FPS Spring):**
   - Spektakularna animacja sprężynowa (skala 0.92 -> 1.0, rozbłysk złota `#F0B90B` i kaskadowe pojawienie się elementów).
4. **Dashboard Główny (`DashboardView`):**
   - Nagłówek Binance z logo, statusem VIP 1, UID i odznaką `🟢 FACE ID`.
   - Portfel Futures (saldo w PLN, zysk 24h w `#0ECB81`, wskaźnik skuteczności AI).
   - Ticki rynkowe na żywo (BTC, ETH, SOL, BNB, XAU) z bufora RAM.
   - Karty sygnałów AI z przyciskami szybkiego kopiowania TP/SL jednym dotknięciem.
   - Przycisk **„Zablokuj”** w prawym górnym rogu, pozwalający natychmiast zablokować aplikację i sprawdzić ponowne logowanie twarzą.

---

## 🛠️ Jak skompilować do pliku `.ipa` za darmo przez GitHub Actions?

1. Wypchnij folder projektu na swoje repozytorium GitHub (publiczne lub prywatne):
   ```bash
   git add .
   git commit -m "Add Binance Radar native iOS Swift app"
   git push origin main
   ```
2. Wejdź na swoje repozytorium na **GitHub.com** i przejdź do zakładki **Actions**.
3. Uruchomi się automatyczny workflow **„Kompilacja iOS IPA (Binance Radar Swift)”**.
4. Po około 2-3 minutach w sekcji **Artifacts** pojawi się gotowy do pobrania plik: **`BinanceRadar-iOS-IPA.zip`**.
5. Rozpakuj go – w środku znajduje się gotowy plik **`BinanceRadar.ipa`**.

---

## 📲 Jak wgrać plik `.ipa` na iPhone z Windowsa (Bez płatnego konta dewelopera)?

1. Pobierz darmowy program na Windows: **[Sideloadly](https://sideloadly.io/)**.
2. Podłącz iPhone’a kablem USB do komputera z Windowsem (i zatwierdź „Ufaj temu komputerowi”).
3. Otwórz Sideloadly i przeciągnij plik `BinanceRadar.ipa`.
4. W polu *Apple ID* wpisz swój zwykły adres e-mail Apple ID (ten z iPhone'a).
5. Kliknij **Start** – program podpisze aplikację bezpłatnym certyfikatem i zainstaluje ją wprost na Twoim iPhonie!
6. Na iPhonie przejdź do: **Ustawienia -> Ogólne -> VPN i zarządzanie urządzeniami**, kliknij swój Apple ID i wybierz **Zaufaj**.
7. Otwórz aplikację **Binance Radar** z ekranu początkowego – gotowe!
