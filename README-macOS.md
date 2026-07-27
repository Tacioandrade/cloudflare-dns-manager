# Cloudflare DNS Manager - macOS

Guia para compilar e testar a versão macOS em um Mac. A compilação exige macOS, Xcode e CocoaPods.

## Preparação

1. Instale o Flutter, Xcode e CocoaPods.
2. Execute `flutter pub get` para instalar os pods.
3. Abra `macos/Runner.xcworkspace` no Xcode para configurar assinatura e distribuição.

## Testes e build

```bash
flutter pub get
flutter test
flutter build macos --release
```

O bundle é gerado em `build/macos/Build/Products/Release/`.

O workflow `.github/workflows/release-builds.yml` também gera
`cloudflare-dns-manager-macos-<versão>.zip` em commits de release na `main`
cuja mensagem começa com `Versão X.Y.Z`.

## Detalhes

- Alvo mínimo: macOS 10.15.
- Bundle ID: `br.com.multiti.cloudflare_dns`.
- O sandbox inclui acesso de rede de saída para a API Cloudflare.
- O acesso ao Keychain está habilitado para armazenar o token e a senha com segurança.
- Ao abrir o aplicativo, a verificação diária de novas versões é executada e pode ser desativada nas Configurações.
- O artefato automático usa assinatura ad-hoc; distribuição pública exige assinatura Developer ID e notarização.
- Para publicar fora do ambiente local, configure a equipe Apple, certificado e notarização no Xcode.
