[Português](README.md) | [English](README.en.md) | [Français](README.fr.md) | [Español](README.es.md) | [简体中文](README.zh.md) | [日本語](README.ja.md) | [Deutsch](README.de.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md) | [한국어](README.ko.md)

# Cloudflare DNS Manager

Cloudflare API를 통해 DNS 레코드를 관리하는 Flutter 앱입니다.

이 README는 모든 플랫폼에 공통으로 적용되는 내용을 담고 있습니다. 빌드 명령, 테스트 및 플랫폼별 자세한 내용은 [Android](README-Android.md), [iOS](README-iOS.md), [Linux](README-Linux.md), [macOS](README-macOS.md), [Windows](README-Windows.md) 가이드를 참조하세요.

## 기능

- 앱 비밀번호로 로그인하며, 지원되는 플랫폼에서는 생체 인증을 사용할 수 있습니다.
- 앱을 닫았다가 다시 열면 자동으로 로그아웃됩니다.
- 활성, 대기 중, 비활성 상태를 표시하는 도메인 목록을 제공합니다.
- DNS 레코드 편집, Cloudflare 프록시 상태 변경, CDN 캐시 삭제를 지원합니다.
- Cloudflare API 토큰을 설정하고 유효성을 확인할 수 있습니다.
- 라이트, 다크, 시스템 테마를 선택할 수 있습니다. 인터페이스는 포르투갈어, 영어, 프랑스어, 스페인어, 중국어(간체), 일본어, 독일어, 아랍어, 힌디어, 한국어를 지원합니다.
- 앱에서 한국어 버전 기록을 볼 수 있습니다.

## 접근 및 보안

처음 사용할 때 앱 비밀번호를 만듭니다. 새 세션마다 인증이 필요하며, 세션은 메모리에만 유지됩니다. 비밀번호는 임의의 솔트가 포함된 PBKDF2-HMAC-SHA256 해시로 플랫폼의 보안 저장소에 저장됩니다. Cloudflare 토큰도 보안 저장소에 저장됩니다. 테마와 DNS 설정 등 민감하지 않은 항목은 일반 로컬 설정에 저장됩니다.

## Cloudflare API 토큰

1. 앱에 로그인합니다.
2. **설정**을 엽니다.
3. [Cloudflare API 토큰](https://dash.cloudflare.com/profile/api-tokens)을 붙여넣습니다.
4. **테스트**를 선택한 다음 **저장**을 선택합니다.

### 등록된 도메인만 관리하는 API 토큰

기존 도메인 목록 조회, 활성화 확인, CDN 캐시 삭제에는 다음 권한을 사용합니다.

- **Zone / Zone / Edit**: 영역 목록 조회 및 대기 중인 영역의 활성화 재확인.
- **Zone / Cache Purge / Purge**: CDN 캐시 삭제.

이 권한 구성으로는 DNS 레코드를 생성, 수정 또는 삭제할 수 없습니다.

### 새 도메인을 추가하고 기존 도메인을 관리하는 API 토큰

위 권한에 다음을 추가합니다.

- **Zone / DNS / Edit**: DNS 레코드 조회, 생성, 수정, 삭제.
- **Zone resources / Include / All zones**.
- **User / Memberships / Read**: 도메인이 없는 계정을 포함한 모든 접근 가능한 계정을 표시하기 위해 권장합니다.

## 구성

- Flutter / Dart를 사용하며, 민감하지 않은 로컬 상태는 `shared_preferences`에 저장합니다.
- 비밀 정보에는 `flutter_secure_storage`, 생체 인증에는 `local_auth`를 사용합니다.
- 네트워크 통신에는 `http`, 외부 링크에는 `url_launcher`를 사용합니다.

## 알려진 문제

Windows에는 Microsoft Visual C++ Redistributable 2015–2022가 필요합니다. `MSVCP140.dll`, `VCRUNTIME140.dll`, `VCRUNTIME140_1.dll` 중 하나가 없다면 [Microsoft 공식 다운로드 페이지](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)에서 설치하세요.

## 라이선스

MIT
