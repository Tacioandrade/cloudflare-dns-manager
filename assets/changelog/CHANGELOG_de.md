# Versionsverlauf

Projekt auf GitHub: [https://github.com/Tacioandrade/cloudflare-update-dns/](https://github.com/Tacioandrade/cloudflare-update-dns/)

Alle wichtigen Änderungen an diesem Projekt werden hier dokumentiert.

## [2.1.1] - 2026-11-13
### Hinzugefügt
- Unterstützung für Deutsch, Arabisch, Hindi und Koreanisch in der Benutzeroberfläche, bei der automatischen und manuellen Sprachauswahl, in den READMEs und im In-App-Versionsverlauf hinzugefügt.
### Behoben
- Die DNS-Eintragstypen MX und SRV im Editor korrigiert und die zusätzlichen Felder ergänzt, die zum Erstellen und Bearbeiten dieser Einträge erforderlich sind.
- Den TXT-Eintrag korrigiert: Inhalte ohne Anführungszeichen werden beim Erstellen oder Bearbeiten jetzt automatisch in doppelte Anführungszeichen gesetzt, wie im Cloudflare-Webdashboard.

## [2.1.0] - 2026-10-19
### Hinzugefügt
- Ein Aktionsmenü für DNS-Einträge ermöglicht das Kopieren von Adresse oder Wert sowie das Duplizieren, Bearbeiten und Löschen. Ein Rechtsklick zeigt dieselben Aktionen in der Systemsprache.
- Neue Domains können einem zugänglichen Cloudflare-Konto hinzugefügt werden.
- Ausstehende Domains zeigen ihre zugewiesenen Nameserver, erlauben deren Kopieren und bieten eine erneute Aktivierungsprüfung.
- Wenn dem Token die Berechtigung `Memberships → Read` fehlt, erklärt ein Hinweis, dass nur Konten mit mindestens einer registrierten Domain angezeigt werden.
- Bei der Kontoauswahl kann nach Name oder ID gesucht werden, auch mit `Ctrl+F` und `Esc`.
- Die Option zum Hinzufügen einer Domain erscheint nur mit der erforderlichen Berechtigung zum Erstellen von Zonen.
- Die Dokumentation der benötigten Berechtigungen wurde verbessert.
### Behoben
- Die Tokenanleitung wurde überarbeitet: Das Basisprofil für vorhandene Zonen nutzt Zone Edit und Cache Purge. DNS Edit gehört zum Profil zum Hinzufügen von Domains und Verwalten ihrer DNS-Einträge.
- Die iOS- und App-Store-Konfiguration einschließlich Symbolen und Metadaten wurde korrigiert.
- Die Linux-Buildwarnung `deprecated-literal-operator` einer C++-Abhängigkeit wurde herabgestuft; `-Werror` bleibt für andere Warnungen aktiv.
- Berechnung und Prüfung des lokalen Passworts erfolgen auf nativen Plattformen in einem Isolate; vorhandene Hashes bleiben gültig.
- Gleichzeitige Eingaben bei Passworteinrichtung, Anmeldung, Passwortwechsel und erneuter Authentifizierung werden verhindert. Bei Fehlern erscheint eine Meldung und ein erneuter Versuch ist möglich.

## [2.0.11] - 2026-09-24
### Hinzugefügt
- Mehrere DNS-Einträge lassen sich nach Auswahl über die Symbolleiste oder langes Drücken gemeinsam löschen, mit Bestätigung und automatischem Neuladen.

## [2.0.10] - 2026-09-16
### Behoben
- Unterstriche und andere gültige DNS-Zeichen sind in Zielen von CNAME-, MX-, NS- und SRV-Einträgen zulässig; die Längenbeschränkungen bleiben bestehen.

## [2.0.9] - 2026-09-05
### Hinzugefügt / Geändert
- Windows-Builder und Projektanforderungen wurden auf allen Plattformen auf Flutter 3.38.10 vereinheitlicht.
- Wenn kein Token eingerichtet ist, zeigt die Startseite eine Anleitung zur Einrichtung des Cloudflare API-Tokens mit Link und Berechtigungen.

## [2.0.8] - 2026-08-28
### Hinzugefügt / Geändert
- Die Fußbereiche der Domain- und DNS-Listen zeigen Gesamtzahlen, einschließlich A-, CNAME- und TXT-Einträgen.
- Responsive Fußbereiche berücksichtigen Höhe und Ränder der schwebenden Schaltflächen, damit auf Desktop, Tablet und Mobilgeräten kein letzter Eintrag verdeckt wird.
- Der Linux-Builder wurde passend zu `pubspec.lock` und dem Release-Prozess auf Flutter 3.38.10 aktualisiert.
- Aktionen für Proxy, Bearbeiten und Löschen zeigen Hilfetexte beim Überfahren mit der Maus.

## [2.0.6] - 2026-08-11
### Hinzugefügt / Geändert
- DNS-Einträge können aus der Liste mit vorausgefülltem Formular kopiert werden; eine Prüfung verhindert Duplikate.
- Der Release-Prozess verwendet Flutter 3.38.10 für Linux-, Windows- und macOS-Builds.

## [2.0.5] - 2026-07-29
### Sicherheit
- Vor dem Anzeigen oder Kopieren des Cloudflare API-Tokens ist eine erneute Authentifizierung per Biometrie, Geräteanmeldung oder App-Passwort erforderlich.

## [2.0.4] - 2026-07-27
### Hinzugefügt / Geändert
- macOS prüft beim Start täglich auf Aktualisierungen; unter iOS bleibt diese Funktion deaktiviert.
- Der angezeigte App-Name unter Android und in Web-Metadaten wurde auf Cloudflare DNS Manager korrigiert.
- Eine Docker-Option erstellt das Android App Bundle (AAB) für Google Play.
- Die Android-Buildwerkzeuge wurden auf Flutter 3.38.10, Android Gradle Plugin 8.11.1 und Gradle 8.14 aktualisiert.
- Die Android-API-Stufen wurden gemäß Google Play auf mindestens 24 und Ziel 36 gesetzt.

## [2.0.3] - 2026-07-24
### Hinzugefügt / Geändert
- Native Unterstützung und Buildanleitungen für iOS und macOS wurden hinzugefügt.
- GitHub Actions erstellt bei Release-Commits automatisch macOS-Bundles.
- Netzwerk- und Keychain-Berechtigungen, öffentliche Metadaten und Xcode-Produktverweise wurden angepasst.

## [2.0.2] - 2026-07-20
### Hinzugefügt
- Linux und Windows prüfen beim Start täglich über GitHub Releases auf neue Versionen; dies kann in den Einstellungen deaktiviert werden.

## [2.0.1] - 2026-07-19
### Hinzugefügt
- Kombinierbare Filter nach DNS-Eintragstyp und Proxy-Status verwenden die in den Einstellungen aktivierten Typen.

## [2.0.0] - 2026-07-14
### Hinzugefügt / Geändert
- Domains erscheinen schrittweise, sobald die Cloudflare-API sie liefert, ohne auf alle Seiten zu warten.
- Portugiesisch, Englisch, Französisch, Spanisch, vereinfachtes Chinesisch und Japanisch wurden mit gespeicherter Sprachwahl und Erkennung der Systemsprache hinzugefügt.
- Der Versionsverlauf erscheint in der in der App gewählten Sprache.

## [1.1.4] - 2026-06-27
### Hinzugefügt / Geändert
- Das Projekt wurde von Cloudflare Update DNS in Cloudflare DNS Manager umbenannt.
- `Ctrl + N` öffnet die Erstellung eines DNS-Eintrags.

## [1.1.3] - 2026-06-26
### Behoben
- Ein Windows-Laufzeitfehler durch fehlende Microsoft Visual C++ Runtime wurde behoben.
- CI/CD veröffentlicht nur den Versionsverlauf der aktuellen Version und verpackt Windows- und Linux-Bundles im Ordner `cloudflare-update-dns`.

## [1.1.2] - 2026-06-26
### Hinzugefügt / Behoben
- Eingaben beim Erstellen und Bearbeiten von DNS-Einträgen werden geprüft.
- IPv4 für `A` und IPv6 für `AAAA` werden geprüft.
- Domainnamen für `CNAME`, `MX` und `NS` werden ohne feste TLD-Liste geprüft.
- Das Grundformat von `SRV` und nicht leere Inhalte von `TXT` werden geprüft.
- IP-Adressen als Ziel von `CNAME`, `MX`, `NS` und `SRV` werden abgewiesen.
- Bei `TXT`-Einträgen wie DMARC und DKIM wird das unzulässige Feld `proxied` nicht mehr gesendet.
- Der Schalter `Proxied` erscheint nur bei `A`, `AAAA` und `CNAME`.
- Fehlermeldungen bei abgelehntem Erstellen oder Ändern eines Eintrags wurden verbessert.
- CI/CD erstellt automatisch Windows- und Linux-Anwendungen.

## [1.1.1] - 2026-06-25
### Hinzugefügt / Behoben
- Beim Start liegt der Tastaturfokus je nach Anmeldung auf Passwort oder Biometrie.
- `Ctrl + F` öffnet die Suche in Domain- und DNS-Listen.
- `ESC` schließt die Suche.
- `ESC` schließt das Formular zum Erstellen oder Bearbeiten eines DNS-Eintrags.
- `ESC` führt aus Editor oder Einstellungen zur Domainliste zurück.
- `Enter` im Passwortfeld meldet automatisch an.
- `Enter` in Subdomain- oder Inhaltsfeldern speichert den DNS-Eintrag automatisch.

## [1.1.0] - 2026-06-25
### Hinzugefügt
- Dokumentation und Build-/Testabläufe für Windows wurden hinzugefügt.
- Dokumentation und Build-/Testabläufe für Linux wurden hinzugefügt.
### Sicherheit
- Cloudflare API-Tokens werden mit `flutter_secure_storage` im nativen sicheren Speicher abgelegt.
- Das App-Passwort wird als PBKDF2-HMAC-SHA256-Hash mit zufälligem Salt sicher gespeichert, nicht als Klartext.
- Sitzungen bleiben nur im Arbeitsspeicher; nach erneutem Öffnen ist eine Anmeldung nötig.
- Nur nicht vertrauliche Einstellungen wie Design und DNS-Typen bleiben in `shared_preferences`.

## [1.0.8] - 2026-06-24
### Behoben
- Nach Schließen und erneutem Öffnen ist auf allen Betriebssystemen eine neue Anmeldung erforderlich.

## [1.0.7] - 2026-06-24
### Hinzugefügt / Behoben
- Helles und dunkles Design erkennen die Systemeinstellung automatisch.
- In den Einstellungen kann das Systemdesign, ein helles oder dunkles Design gewählt werden.
- Flutter zeigt interne Texte wie Kopieren, Einfügen und Alles auswählen in der Gerätesprache.

## [1.0.6] - 2026-06-24
### Hinzugefügt / Behoben
- Der CDN-Cache der ausgewählten Zone kann auf dem DNS-Bildschirm geleert werden.
- Die für das Leeren des CDN-Caches mit einem eigenen Cloudflare-Token nötigen Berechtigungen wurden dokumentiert.

## [1.0.5] - 2026-06-24
### Hinzugefügt / Behoben
- Beim ersten Start öffnet sich direkt die Passworterstellung, ohne Standardpasswort oder Biometrie.
- Das Benutzernamefeld wurde entfernt; Anmeldung erfolgt mit Passwort oder Biometrie.

## [1.0.4] - 2026-06-19
### Hinzugefügt / Behoben
- In den Einstellungen können DNS-Typen zum Laden ausgewählt werden.
- Der Versionsverlauf kann in der App angezeigt werden.

## [1.0.3] - 2026-06-19
### Hinzugefügt / Behoben
- Native biometrische Anmeldung mit Fingerabdruck oder Gesichtserkennung und automatischem Rückfall wurde hinzugefügt.
- Beim Bearbeiten von DNS-Einträgen kann nur die Subdomain geändert werden.

## [1.0.2] - 2026-06-18
### Hinzugefügt / Behoben
- Automatische Seitennummerierung lädt alle mit dem Token zugänglichen Domains und DNS-Einträge statt nur der ersten 20.
- Oberfläche und visuelle Identität wurden verfeinert.
- Ein neues Logo und einheitliche Symbole für Android, iOS und Web wurden erstellt.

## [1.0.1] - 2026-06-18
### Behoben
- Kompatibilität und Code des nativen Android-Builds wurden korrigiert.
- Kotlin-Versionen und NDK-Einstellungen wurden angepasst.
- Die Paketkennung wurde von der Beispielkennung auf die offizielle Unternehmenskennung geändert.

## [1.0.0] - Erste Veröffentlichung
### Hinzugefügt
- Grundversion der Anwendung.
- Vollständige DNS-Verwaltung über die Cloudflare-API.
- Lokale Ausführung im Browser oder Paketierung für Android mit Flutter.
- Dynamischer Dunkelmodus und moderne Oberfläche.
