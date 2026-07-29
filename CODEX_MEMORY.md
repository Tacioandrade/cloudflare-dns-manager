# Memória operacional do Codex

Este arquivo deve ser lido no início de cada execução do Codex, antes de qualquer
comando Docker. A obrigatoriedade está registrada no `AGENTS.md`.

## Objetivo

Reutilizar as imagens já presentes na máquina, manter builds reproduzíveis e
evitar baixar ou construir contêineres que não sejam necessários para a tarefa.

## Imagens e contêineres autorizados

### Flutter 3.38.10

- Imagem-base externa autorizada:
  `ghcr.io/cirruslabs/flutter:3.38.10`.
- Não usar `ghcr.io/cirruslabs/flutter:latest`.
- O builder Android local é `android-build:latest`, gerado exclusivamente a
  partir de `Docker/Android/Dockerfile`.
- A tag `latest` de `android-build:latest` é apenas o nome local gerado pelo
  Docker Compose. Ela não autoriza o uso de uma imagem-base externa sem versão.
- Para formatação, análise estática e testes Flutter, reutilizar primeiro o
  builder Android local, pois ele contém o Flutter 3.38.10 compatível com o
  `pubspec.lock`.

Exemplo para reutilizar o builder sem reconstruí-lo:

```bash
docker compose -f Docker/Android/docker-compose.yml run --rm --no-deps --no-build build flutter test
```

Ao substituir o comando do serviço `build`, usar `--no-build` sempre que a
imagem local já existir.

### Proxy de desenvolvimento Web

- Imagem autorizada: `nginx:alpine`.
- Usar somente quando a tarefa exigir executar o servidor Web com acesso à API
  por meio do serviço `proxy` de `Docker/Android/docker-compose.yml`.
- Não iniciar nem baixar o proxy para análise estática, formatação, testes
  unitários ou builds Android.

### Linux

- Nome do builder local: `cloudflare-dns-linux-builder:latest`.
- A configuração atual usa `ghcr.io/cirruslabs/flutter:3.22.0`.
- Flutter 3.22.0 é incompatível com o `pubspec.lock`, que exige Flutter 3.35.0
  ou superior.
- Não usar nem reconstruir esse builder para validações rotineiras enquanto o
  Dockerfile Linux não for atualizado para uma versão compatível.
- Usar o builder Linux somente para build nativo Linux e apenas depois de
  corrigir sua versão do Flutter. Não baixar a imagem 3.22.0 novamente.

### Windows

- Imagem-base autorizada para o sistema:
  `mcr.microsoft.com/windows/servercore:ltsc2022`.
- Nome do builder local: `cloudflare-dns-windows-builder:latest`.
- O Dockerfile atual instala Flutter 3.22.0, incompatível com o
  `pubspec.lock`.
- Não construir esse builder até que sua versão do Flutter seja atualizada.
- Depois da atualização, usá-lo somente para build ou validação específica do
  Windows, em uma máquina configurada para Windows containers.

## Regras obrigatórias antes de usar Docker

1. Verificar se `flutter` e `dart` compatíveis já estão disponíveis no host.
   Se estiverem, preferi-los para formatação, análise e testes.
2. Se Docker for necessário, verificar primeiro se a imagem exata já existe
   localmente.
3. Reutilizar a imagem local com `--no-build`; não executar `docker compose
   build`, `docker compose up --build` ou um `run` que provoque build implícito
   sem necessidade.
4. Não executar `docker pull` preventivamente.
5. Não usar tags externas flutuantes, especialmente `latest`.
6. Baixar ou construir uma imagem somente quando ela for indispensável para a
   plataforma solicitada e não houver uma imagem local compatível.
7. Antes de um download ou build grande, informar ao usuário qual imagem será
   obtida, por que ela é necessária e o tamanho/tempo esperado quando essa
   informação estiver disponível.
8. Não usar um contêiner de outra plataforma apenas para repetir uma validação
   que já passou em Flutter 3.38.10.
9. Não alterar o `pubspec.lock` para acomodar uma versão antiga do Flutter.
   Se um `flutter pub get` modificar o lockfile por incompatibilidade de SDK,
   interromper o fluxo e restaurar somente essa alteração acidental.

## Escolha rápida

- Formatar Dart: host compatível; caso indisponível, builder Android local com
  Flutter 3.38.10 e `--no-build`.
- `flutter analyze`: mesma regra de formatação.
- `flutter test`: mesma regra de formatação.
- APK ou AAB: builder Android local, com `--no-build` quando já existir.
- Servidor Web com proxy: serviços `test` e `proxy` do Compose Android.
- Bundle Linux: aguardar atualização do Dockerfile Linux.
- Bundle Windows: aguardar atualização do Flutter no Dockerfile Windows e usar
  Windows containers.
