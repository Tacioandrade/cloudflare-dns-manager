# Cloudflare DNS Manager - iPhone e iPad

Guia especifico para preparar, testar, assinar e gerar os artefatos iOS e iPadOS. Para funcionalidades comuns, configuracao do token e arquitetura geral, consulte o [README principal](README.md).

No iPhone e no iPad, o app suporta login por senha, Face ID ou Touch ID quando o dispositivo e o sistema operacional oferecem suporte.

## Requisitos

A compilacao para iPhone e iPad exige um Mac. Docker, Linux e Windows nao conseguem gerar um aplicativo iOS.

Instale no Mac:

- macOS com uma versao do Xcode aceita pela Apple para envios atuais;
- Xcode e os componentes da plataforma iOS;
- Flutter 3.38.10;
- CocoaPods;
- Git;
- uma conta Apple Developer para instalar em aparelhos fisicos ou distribuir o aplicativo.

Configure o Xcode e valide o ambiente:

```bash
sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
sudo xcodebuild -license
xcodebuild -downloadPlatform iOS
flutter --version
flutter doctor -v
pod --version
```

O comando `flutter --version` deve informar Flutter 3.38.10. Resolva todos os problemas da secao Xcode exibidos pelo `flutter doctor -v` antes de continuar.

## Preparacao do codigo

Na raiz do projeto, execute:

```bash
flutter pub get
flutter analyze
flutter test
```

O projeto usa CocoaPods para integrar os plugins nativos. O Flutter normalmente executa o `pod install` durante o build. Caso seja necessario atualizar o workspace manualmente:

```bash
cd ios
pod install
cd ..
```

Sempre abra `ios/Runner.xcworkspace`, nunca apenas `ios/Runner.xcodeproj`.

## Identificacao e assinatura

O Bundle ID atual e:

```text
br.com.multiti.cloudflare_dns
```

Para manter atualizacoes, assinatura e dados de uma instalacao existente, nao altere esse identificador depois que o aplicativo for registrado ou publicado.

Antes do primeiro build assinado:

1. Registre um App ID explicito com o Bundle ID `br.com.multiti.cloudflare_dns` no Apple Developer.
2. Crie o aplicativo iOS correspondente no App Store Connect antes do primeiro upload.
3. Abra o workspace:

   ```bash
   open ios/Runner.xcworkspace
   ```

4. No Xcode, selecione o projeto `Runner` e depois o target `Runner`.
5. Em **Signing & Capabilities**, habilite **Automatically manage signing**.
6. Selecione a equipe Apple responsavel pelo aplicativo.
7. Em **General**, confirme:
   - Display Name: `Cloudflare DNS Manager`;
   - Bundle Identifier: `br.com.multiti.cloudflare_dns`;
   - Deployment Target: iOS 13.0 ou posterior;
   - destinos para iPhone e iPad.

O time Apple e os certificados sao dados do desenvolvedor e nao devem ser gravados no repositorio.

## Versao e numero do build

A versao vem do campo `version` em `pubspec.yaml`:

```yaml
version: 2.0.11+27
```

Nesse exemplo:

- `2.0.11` e a versao exibida ao usuario;
- `27` e o numero interno do build.

Cada novo upload da mesma versao para o App Store Connect precisa usar um numero de build maior. E possivel alterar `pubspec.yaml` antes do build ou sobrescrever os valores no comando:

```bash
flutter build ipa \
  --release \
  --build-name 2.0.11 \
  --build-number 28
```

Nao reutilize um numero de build que ja tenha sido enviado para o App Store Connect.

## Icones do aplicativo

O Android, Linux, Windows e a interface do app continuam usando `assets/icon.png` com transparencia. Para iOS, o gerador remove o canal alfa durante a criacao do catalogo, conforme `remove_alpha_ios: true` em `pubspec.yaml`.

Depois de trocar `assets/icon.png`, regenere os icones e confirme que os PNGs iOS sao opacos:

```bash
dart run flutter_launcher_icons
```

Os icones gerados ficam em:

```text
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

O icone de 1024 x 1024 e todos os tamanhos de iPhone e iPad nao podem conter canal alfa no catalogo usado para distribuicao.

## Teste no simulador

Inicie o simulador e liste os dispositivos:

```bash
open -a Simulator
flutter devices
```

Execute o aplicativo informando o identificador exibido por `flutter devices`:

```bash
flutter run -d <ID_DO_SIMULADOR>
```

Tambem e possivel apenas gerar um build para o simulador:

```bash
flutter build ios --simulator --debug
```

Teste pelo menos um modelo de iPhone e um de iPad, em orientacao vertical e horizontal.

## Teste em aparelho fisico

1. Conecte o iPhone ou iPad ao Mac.
2. Confie no computador quando solicitado.
3. Ative o modo de desenvolvedor do aparelho, caso o iOS solicite.
4. Confirme a equipe de assinatura no Xcode.
5. Liste os aparelhos e execute:

   ```bash
   flutter devices
   flutter run -d <ID_DO_APARELHO> --release
   ```

Valide em aparelho real:

- criacao e verificacao da senha;
- Face ID ou Touch ID;
- persistencia segura do token no Keychain;
- acesso a API Cloudflare;
- abertura de links externos;
- retomada depois de colocar o app em segundo plano;
- layouts de iPhone e iPad nas orientacoes suportadas.

## Build local sem assinatura

Para verificar a compilacao nativa em um Mac sem gerar um pacote distribuivel:

```bash
flutter build ios --release --no-codesign
```

O pipeline de release executa essa compilacao automaticamente em macOS para detectar regressos do projeto iOS. Ela nao substitui a assinatura, a validacao do archive nem os testes em aparelhos reais.

## Geracao do IPA para TestFlight ou App Store

Depois de configurar a assinatura:

```bash
flutter build ipa --release
```

Os principais resultados ficam em:

```text
build/ios/archive/Runner.xcarchive
build/ios/ipa/
```

Para validar e enviar pelo Xcode:

```bash
open build/ios/archive/Runner.xcarchive
```

No Organizer:

1. Selecione o archive do Cloudflare DNS Manager.
2. Execute **Validate App**.
3. Corrija qualquer erro antes de continuar.
4. Selecione **Distribute App**.
5. Escolha **TestFlight & App Store** e conclua o upload.
6. Aguarde o processamento no App Store Connect e distribua primeiro pelo TestFlight.

Para uma distribuicao que nao usa a App Store, informe um metodo suportado e uma assinatura compativel, por exemplo:

```bash
flutter build ipa --release --export-method ad-hoc
```

## Dados para publicacao

O build nao inclui os dados editoriais da pagina da loja. No App Store Connect ainda sera necessario fornecer, conforme o tipo de distribuicao:

- nome, subtitulo, descricao e categoria;
- URL da politica de privacidade e informacoes de privacidade do app;
- classificacao etaria;
- screenshots de iPhone e iPad;
- informacoes de contato para revisao;
- respostas de conformidade de exportacao;
- disponibilidade, preco e territorios.

O aplicativo declara `ITSAppUsesNonExemptEncryption` como `false` porque usa apenas criptografia fornecida pelo sistema para HTTPS e Keychain e hashing local de senha, sem implementar criptografia proprietaria para transporte de dados. Revise essa declaracao se a criptografia do aplicativo mudar.

## Detalhes da plataforma

- Plataformas alvo: iOS e iPadOS.
- Versao minima: iOS 13.0.
- Flutter usado no build: 3.38.10.
- Artefato de distribuicao: IPA.
- Workspace Xcode: `ios/Runner.xcworkspace`.
- Bundle ID: `br.com.multiti.cloudflare_dns`.
- Dispositivos: iPhone e iPad.
- Biometria: `local_auth`, com descricao de Face ID no `Info.plist`.
- Segredos locais: `flutter_secure_storage`, usando o Keychain.
- Icones: catalogo `AppIcon` sem canal alfa.

## Sessao

Ao fechar e reabrir o aplicativo, o login e exigido novamente. A sessao autenticada nao fica persistida em disco.

## Referencias

- [README principal](README.md)
- [README Android](README-Android.md)
- [README macOS](README-macOS.md)
- [Documentacao oficial do Flutter para iOS](https://docs.flutter.dev/deployment/ios)
- [Documentacao oficial do Apple Developer](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
