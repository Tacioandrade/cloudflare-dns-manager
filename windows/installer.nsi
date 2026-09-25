Unicode true
XPStyle on

!ifndef VERSION
  !define VERSION "0.0.0"
!endif
!ifndef SOURCE_DIR
  !define SOURCE_DIR "..\package\cloudflare-update-dns"
!endif
!ifndef OUTPUT_DIR
  !define OUTPUT_DIR "..\dist"
!endif
!ifndef OUTPUT_FILE
  !define OUTPUT_FILE "cloudflare-dns-manager-windows-${VERSION}.exe"
!endif

!define APP_NAME "Cloudflare DNS Manager"
!define APP_PUBLISHER "MultiTI Consultoria e Solucoes em Tecnologia"
!define APP_EXE "cloudflare_dns.exe"
!define APP_URL "https://github.com/Tacioandrade/cloudflare-dns-manager"
!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\CloudflareDNSManager"

Name "${APP_NAME}"
OutFile "${OUTPUT_DIR}\${OUTPUT_FILE}"
InstallDir "$LOCALAPPDATA\Programs\${APP_NAME}"
RequestExecutionLevel user

; No wizard pages: double-clicking runs straight to a small progress
; window (no file listing, no descriptive text) and closes itself.
ShowInstDetails hide
ShowUninstDetails hide
AutoCloseWindow true

Icon "${SOURCE_DIR}\app_icon.ico"
UninstallIcon "${SOURCE_DIR}\app_icon.ico"

VIProductVersion "${VERSION}.0"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "CompanyName" "${APP_PUBLISHER}"
VIAddVersionKey "ProductVersion" "${VERSION}"
VIAddVersionKey "FileVersion" "${VERSION}"

Section "Install"
  SetOutPath "$InstDir"
  File /r "${SOURCE_DIR}\*.*"

  CreateShortcut "$SMPROGRAMS\${APP_NAME}.lnk" "$InstDir\${APP_EXE}"
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$InstDir\${APP_EXE}"

  WriteUninstaller "$InstDir\uninstall.exe"

  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "Publisher" "${APP_PUBLISHER}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "URLInfoAbout" "${APP_URL}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayIcon" "$InstDir\${APP_EXE}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "InstallLocation" "$InstDir"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "UninstallString" '"$InstDir\uninstall.exe"'
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoRepair" 1

  Exec '"$InstDir\${APP_EXE}"'
SectionEnd

Section "Uninstall"
  Delete "$SMPROGRAMS\${APP_NAME}.lnk"
  Delete "$DESKTOP\${APP_NAME}.lnk"

  RMDir /r "$InstDir"

  DeleteRegKey HKCU "${UNINSTALL_KEY}"
SectionEnd
