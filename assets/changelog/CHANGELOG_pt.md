# Changelog

Projeto no GitHub: [https://github.com/Tacioandrade/cloudflare-update-dns/](https://github.com/Tacioandrade/cloudflare-update-dns/)

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

## [2.0.10] - 2026-09-16
### Corrigido
- Liberados sublinhados e os demais caracteres válidos em nomes DNS nos destinos de registros CNAME, MX, NS e SRV, mantendo os limites de tamanho definidos para nomes e rótulos DNS.

## [2.0.9] - 2026-09-05
### Adicionado / Alterado
- Padronizados o builder Windows e os requisitos do projeto em Flutter 3.38.10 para todas as plataformas.
- Adicionado um tutorial de configuração do Cloudflare API Token na tela inicial quando nenhum token estiver definido, com link para criação e as permissões necessárias.

## [2.0.8] - 2026-08-28
### Adicionado / Alterado
- Adicionados totais de domínios e de registros DNS nos rodapés das respectivas listagens, incluindo a contagem de registros A, CNAME e TXT.
- Adicionados rodapés responsivos com a mesma altura dos botões flutuantes e suas margens, impedindo que cubram o último item em telas de computador, tablet ou celular.
- Atualizado o builder Linux para Flutter 3.38.10, alinhando-o ao `pubspec.lock` e ao pipeline de release.
- Adicionados textos de ajuda ao passar o mouse sobre as ações de proxy, edição e exclusão de registros DNS.

## [2.0.6] - 2026-08-11
### Adicionado / Alterado
- Adicionada a opção de copiar um registro DNS a partir da listagem, com formulário preenchido e validação para impedir entradas duplicadas.
- Padronizado o pipeline de release para usar Flutter 3.38.10 nos builds Linux, Windows e macOS.

## [2.0.5] - 2026-07-29
### Segurança
- Passou a exigir nova autenticação por biometria, credencial do dispositivo ou senha do aplicativo antes de exibir e permitir copiar o Token da API Cloudflare nas Configurações.

## [2.0.4] - 2026-07-27
### Adicionado / Alterado
- Adicionada ao macOS a verificação diária de novas versões ao abrir o aplicativo, mantendo iOS sem essa funcionalidade.
- Corrigido o nome exibido do aplicativo no Android e nos metadados Web para Cloudflare DNS Manager.
- Adicionada uma opção Docker para gerar o Android App Bundle (AAB) destinado à publicação na Google Play Store.
- Atualizada a ferramenta de build Android para Flutter 3.38.10, com Android Gradle Plugin 8.11.1 e Gradle 8.14.
- Atualizados os níveis de API Android para mínimo 24 e desejado 36, conforme exigido pela Google Play Store.

## [2.0.3] - 2026-07-24
### Adicionado / Alterado
- Adicionado suporte nativo e documentação de build para iOS e macOS.
- Adicionado build automático do bundle macOS no GitHub Actions para commits de release.
- Ajustadas as permissões de rede e Keychain, os metadados públicos e as referências do produto no projeto Xcode.

## [2.0.2] - 2026-07-20
### Adicionado
- Adicionada verificação diária de novas versões via GitHub Releases ao abrir o aplicativo no Linux e Windows, com opção para desativá-la nas Configurações.

## [2.0.1] - 2026-07-19
### Adicionado
- Adicionados filtros combináveis por tipo de registro DNS e status do proxy na tela de registros, usando os tipos habilitados nas Configurações.

## [2.0.0] - 2026-07-14
### Adicionado / Alterado
- A lista de domínios agora é exibida progressivamente, assim que cada domínio é recebido da API da Cloudflare, sem esperar o término de todas as páginas.
- Adicionado suporte a português, inglês, francês, espanhol, chinês simplificado e japonês, com seleção de idioma persistente e detecção do idioma do sistema.
- O histórico de versões agora é exibido no idioma escolhido no aplicativo.

## [1.1.4] - 2026-06-27
### Adicionado / Alterado
- Renomeado o projeto de Cloudflare Update DNS para Cloudflare DNS Manager.
- Adicionado atalho de teclado `Ctrl + N` para abrir a criação de um novo registro DNS.

## [1.1.3] - 2026-06-26
### Corrigido
- Corrigido bug de execução na versão para Windows relacionado à ausência do Microsoft Visual C++ Runtime.
- Corrigidos ajustes de CI/CD do projeto para publicar apenas o changelog da versão atual e empacotar os bundles Windows e Linux dentro da pasta `cloudflare-update-dns`.

## [1.1.2] - 2026-06-26
### Adicionado / Corrigido
- Adicionada validação do conteúdo informado na criação e edição de registros DNS.
- Validado IPv4 para registros `A` e IPv6 para registros `AAAA`.
- Validado formato de domínio para registros `CNAME`, `MX` e `NS`, sem depender de lista fixa de TLDs.
- Validado formato básico de registros `SRV` e conteúdo não vazio para registros `TXT`.
- Corrigida a validação de domínio para rejeitar IPs informados em registros `CNAME`, `MX`, `NS` e destino de `SRV`.
- Corrigida a criação de registros `TXT` como DMARC e DKIM, removendo o envio indevido do campo `proxied` para tipos não proxiáveis.
- O controle `Proxied` agora aparece apenas para registros `A`, `AAAA` e `CNAME`.
- Ajustada a mensagem de erro exibida quando a API da Cloudflare rejeita a criação ou atualização de um registro.
- Ativa o CI/CD do projeto para gerar aplicação para Windows e Linux automaticamente.

## [1.1.1] - 2026-06-25
### Adicionado / Corrigido
- Ao abrir a aplicação o foco do teclado ficará no campo de senha ou biometria (dependendo do tipo de autenticação configurado).
- Adicionado atalho de teclado `Ctrl + F` para abrir rapidamente a pesquisa nas listas de domínios e de registros DNS.
- Adicionado atalho de teclado `ESC` para fechar rapidamente a funcionalidade de pesquisa.
- Adicionado atalho de teclado `ESC` para fechar rapidamente a tela de criação/edição de registro DNS.
- Adicionado atalho de teclado `ESC` para voltar a tela de listagem de domínios, caso esteja na tela de criação/edição de registro DNS ou configurações.
- Implementado login automático ao pressionar a tecla `Enter` no campo de senha na tela de login.
- Implementado salvamento automático do registro DNS ao pressionar a tecla `Enter` nos campos de subdomínio e conteúdo durante a criação/edição.

## [1.1.0] - 2026-06-25
### Adicionado
- Adicionada documentação e fluxo de build/testes para a versão Windows.
- Adicionada documentação e fluxo de build/testes para a versão Linux.
### Segurança
- Alterado o armazenamento do Cloudflare API Token para `flutter_secure_storage`, usando o armazenamento seguro nativo de cada plataforma.
- Alterado o armazenamento da senha do app para hash PBKDF2-HMAC-SHA256 com salt aleatório no armazenamento seguro, removendo a persistência da senha em texto claro.
- Mantida a sessão autenticada apenas em memória, exigindo novo login ao reabrir o aplicativo.
- Mantidas em `shared_preferences` apenas configurações não sensíveis, como tema e tipos de registros DNS.

## [1.0.8] - 2026-06-24
### Corrigido
- Forçado o logout da aplicação ao fechar e reabrir o app, exigindo novo login em todos os sistemas operacionais.

## [1.0.7] - 2026-06-24
### Adicionado / Corrigido
- Adicionado suporte a tema claro e escuro com detecção automática do tema configurado no sistema operacional.
- Adicionada opção em Configurações para escolher entre tema do sistema, claro ou escuro.
- Adicionada localização nativa do Flutter para exibir textos internos, como copiar, colar e selecionar tudo, no idioma do dispositivo.

## [1.0.6] - 2026-06-24
### Adicionado / Corrigido
- Adicionada funcionalidade de limpeza do cache da CDN para a zona selecionada na tela de registros DNS.
- Documentadas as permissões necessárias para usar a limpeza de Cache CDN com Token customizado da Cloudflare.

## [1.0.5] - 2026-06-24
### Adicionado / Corrigido
- Alterado o primeiro acesso para abrir diretamente a tela de criação de senha, sem exigir senha padrão ou biometria.
- Removido o campo de usuário da tela de login; o acesso agora é feito apenas por senha cadastrada ou biometria.

## [1.0.4] - 2026-06-19
### Adicionado / Corrigido
- Adicionado seletor de tipos de entradas DNS nas configurações para permitir filtrar quais registros o sistema carrega.
- Adicionada tela de visualização do Changelog diretamente no aplicativo.

## [1.0.3] - 2026-06-19
### Adicionado / Corrigido
- Implementado suporte nativo para login via Biometria (Impressão digital / Reconhecimento facial) com fallback transparente e automático.
- Ajuste na edição de domínios DNS para permitir a edição de apenas o subdomínio da entrada.

## [1.0.2] - 2026-06-18
### Adicionado / Corrigido
- Correção na lógica de integração com a API para realizar paginação automática. Agora o aplicativo puxa todos os domínios e registros DNS que o token tem acesso, contornando o limite padrão de 20 registros por página do Cloudflare.
- Ajustes finos de interface e identidade visual.
- Implementação de novo logotipo e geração de ícones padronizados (Android, iOS e Web).

## [1.0.1] - 2026-06-18
### Corrigido
- Resolução de problemas de compatibilidade e correção de código para o build nativo do Android.
- Ajuste das versões do Kotlin e configuração do NDK para compilação segura.
- Alteração do identificador do pacote (Application ID) de padrão de exemplo para a assinatura corporativa oficial.

## [1.0.0] - Lançamento Inicial
### Adicionado
- Versão básica do sistema.
- Gerenciamento completo de registros DNS via Cloudflare API.
- Capacidade de rodar localmente no navegador ou ser empacotado para Android via Flutter.
- Modo noturno dinâmico e interface moderna.
