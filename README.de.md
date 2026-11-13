[Português](README.md) | [English](README.en.md) | [Français](README.fr.md) | [Español](README.es.md) | [简体中文](README.zh.md) | [日本語](README.ja.md) | [Deutsch](README.de.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md) | [한국어](README.ko.md)

# Cloudflare DNS Manager

Eine Flutter-Anwendung zur Verwaltung von DNS-Einträgen über die Cloudflare-API.

Diese README enthält allgemeine Informationen für alle Plattformen. Anleitungen für Build, Tests und plattformspezifische Details finden Sie unter [Android](README-Android.md), [Linux](README-Linux.md), [Windows](README-Windows.md), [iOS](README-iOS.md) und [macOS](README-macOS.md).

## Funktionen

- Lokale Anmeldung mit Passwort und biometrische Anmeldung auf unterstützten Plattformen.
- Automatische Abmeldung nach dem Schließen und erneuten Öffnen der Anwendung.
- Domainliste mit den Status aktiv, ausstehend und inaktiv.
- Konfigurierbarer DNS-Editor, Umschalten des Cloudflare-Proxys und Leeren des CDN-Caches.
- Konfiguration und Prüfung des Cloudflare API-Tokens.
- Helles, dunkles oder Systemdesign; Benutzeroberfläche auf Portugiesisch, Englisch, Französisch, Spanisch, vereinfachtem Chinesisch, Japanisch, Deutsch, Arabisch, Hindi und Koreanisch.
- Lokalisierter Versionsverlauf in der App.

## Zugriff und Sicherheit

Erstellen Sie beim ersten Start ein App-Passwort. Bei jedem neuen Start ist eine Anmeldung erforderlich. Die Sitzung wird nur im Arbeitsspeicher gehalten. Das Passwort wird als PBKDF2-HMAC-SHA256-Hash mit zufälligem Salt im sicheren Speicher der Plattform gespeichert. Dort wird auch das Cloudflare-Token gespeichert. Design und DNS-Einstellungen werden in lokalen Einstellungen gespeichert.

## Cloudflare API-Token

1. Melden Sie sich in der Anwendung an.
2. Öffnen Sie **Einstellungen**.
3. Fügen Sie Ihr [Cloudflare API-Token](https://dash.cloudflare.com/profile/api-tokens) ein.
4. Wählen Sie **Testen** und danach **Speichern**.

### API-Token nur für registrierte Domains

Zum Auflisten vorhandener Domains, Prüfen der Aktivierung und Leeren des CDN-Caches verwenden Sie:

- **Zone / Zone / Edit** zum Auflisten der Zonen und erneuten Prüfen ausstehender Zonen.
- **Zone / Cache Purge / Purge** zum Leeren des CDN-Caches.

Dieses Profil erlaubt weder das Erstellen noch das Ändern oder Löschen von DNS-Einträgen.

### API-Token zum Hinzufügen und Verwalten von Domains

Verwenden Sie die obigen Berechtigungen und ergänzen Sie:

- **Zone / DNS / Edit** zum Auflisten, Erstellen, Ändern und Löschen von DNS-Einträgen.
- **Zone resources / Include / All zones**.
- **User / Memberships / Read**, empfohlen zum Auflisten aller zugänglichen Konten, auch ohne Domains.

## Architektur

- Flutter / Dart; `shared_preferences` für nicht vertrauliche lokale Daten.
- `flutter_secure_storage` für Geheimnisse; `local_auth` für biometrische Authentifizierung.
- `http` für Netzwerkzugriff und `url_launcher` für externe Links.

## Bekanntes Problem

Unter Windows wird Microsoft Visual C++ Redistributable 2015–2022 benötigt. Falls `MSVCP140.dll`, `VCRUNTIME140.dll` oder `VCRUNTIME140_1.dll` fehlt, installieren Sie es über die [offizielle Microsoft-Seite](https://learn.microsoft.com/de-de/cpp/windows/latest-supported-vc-redist).

## Lizenz

MIT
