[Português](README.md) | [English](README.en.md) | [Français](README.fr.md) | [Español](README.es.md) | [简体中文](README.zh.md) | [日本語](README.ja.md)

# Cloudflare DNS Manager

Aplicativo em Flutter para gerenciamento de registros DNS via Cloudflare API.

Este README contem as informacoes compartilhadas entre as plataformas. Para comandos de build, testes e detalhes especificos, use os guias por sistema operacional:

- [Android](README-Android.md) — [Baixar na Play Store](https://play.google.com/store/apps/details?id=br.com.multiti.cloudflare_update_dns)
- [Linux](README-Linux.md)
- [Windows](README-Windows.md)
- [iOS](README-iOS.md)
- [macOS](README-macOS.md)

## Funcionalidades

- Autenticacao local por senha.
- Login por biometria nas plataformas que suportam essa integracao.
- Logout automatico ao fechar e reabrir o aplicativo, exigindo novo login.
- Listagem de dominios com status ativo, pendente ou inativo.
- Editor de registros DNS com tipos configuraveis na tela de Configuracoes.
- Toggle de proxy Cloudflare com atualizacao em tempo real.
- Limpeza de cache CDN da zona selecionada.
- Configuracao e validacao do Cloudflare API Token.
- Tema claro, escuro ou automatico pelo sistema.
- Interface em português, inglês, francês, espanhol, chinês simplificado e japonês.
- Visualizacao do changelog dentro do aplicativo.

## Acesso

No primeiro acesso, o aplicativo abre a tela de criacao de senha. Depois disso, cada nova execucao do app exige login novamente.

A sessao autenticada fica apenas em memoria. A senha do app nao e salva em texto claro; o app armazena apenas um hash PBKDF2-HMAC-SHA256 com salt aleatorio no armazenamento seguro da plataforma. O token da Cloudflare tambem fica no armazenamento seguro. Tema e configuracoes de DNS continuam salvos localmente em preferencias comuns.

## Cloudflare API Token

1. Faca login no aplicativo.
2. Abra Configuracoes.
3. Cole seu [Cloudflare API Token](https://dash.cloudflare.com/profile/api-tokens)
4. Clique em Testar para validar.
5. Clique em Salvar.

### Token de API apenas para administrar dominios cadastrados

Para listar dominios existentes, verificar a ativacao e limpar o cache CDN, crie um token customizado com estas permissoes:

- Zona / Zone => Zona / Zone => Editar / Edit: lista as zonas e permite solicitar uma nova verificacao de ativacao para zonas pendentes.
- Zona / Zone => Limpeza do cache / Cache Purge => Purgar / Purge: permite limpar o cache CDN.

Este perfil nao permite criar, alterar ou excluir registros DNS.

### Token de API para adicionar novos dominios e administrar existentes

Use as permissoes anteriores e acrescente:

- Zona / Zone => DNS => Editar / Edit, para listar, criar, alterar e excluir registros DNS.
- Recursos de zona / Zone resources => Incluir / Include => Todas as zonas / All zones.
- Usuario / User => Associacoes / Memberships => Leitura / Read, recomendada para listar todas as contas acessiveis, inclusive as que ainda nao possuem dominios.

## Arquitetura

- Framework: Flutter / Dart
- Estado local nao sensivel: `shared_preferences`
- Segredos locais: `flutter_secure_storage`
- Autenticacao biometrica: `local_auth`, quando suportado pela plataforma
- Comunicacao de rede: `http`
- Abertura de links externos: `url_launcher`

## Estrutura dos Guias

- `README-Android.md`: Documentação do build e detalhes da versão para Android.
- `README-Linux.md`: Documentação do build e detalhes da versão para Linux.
- `README-Windows.md`: Documentação do build e detalhes da versão para Windows.

## Problemas Conhecidos

- A versao para Windows exige o Microsoft Visual C++ Redistributable 2015-2022 instalado para executar. Sem esse runtime, o Windows pode exibir erro informando a falta das DLLs `MSVCP140.dll`, `VCRUNTIME140.dll` ou `VCRUNTIME140_1.dll`. Instale pelo site oficial da Microsoft: [Latest supported Visual C++ Redistributable downloads](https://learn.microsoft.com/pt-br/cpp/windows/latest-supported-vc-redist).

## Licenca

MIT
