# Organização e manutenção

O repositório reúne o código editável, a documentação e a distribuição Web. A branch `gh-pages` continua sendo a branch principal e a origem do site; renomeá-la ou mudar a pasta da publicação exigiria reconfigurar o GitHub Pages.

| Local | Responsabilidade |
| --- | --- |
| `game/` | Projeto Godot, cenas, scripts, perguntas e recursos originais. |
| `docs/` | Guia, instruções de desenvolvimento e avaliação acadêmica. |
| `docs/historico/` | Notas anteriores, mantidas como registro. |
| `media/` | QR code e capturas usados no README. |
| `licenses/` | Licenças e avisos de terceiros. |
| `tools/` | Geração dos pacotes de distribuição. |
| `.github/workflows/` | Verificação e publicação do download Windows. |
| Raiz, `index.*` e `mobile.*` | Exportação Web publicada; preservar os caminhos existentes. |
| Releases | ZIP Windows, projeto editável e checksums. |

Não versionar cache `.godot`, saves de usuários, credenciais de exportação, executáveis gerados ou arquivos ZIP. Os recursos e configurações necessários para reproduzir o projeto são versionados. Não foi atribuída uma nova licença ao código ou à arte da equipe: essa escolha cabe aos autores; consulte [licenças](../licenses/README.md).

As capturas documentam a versão 2.14. O QR code aponta para o endereço público estável e não precisa ser trocado a cada atualização. A versão mais recente para Windows deve ser disponibilizada como Release com o nome de arquivo estável `PARADOXO-Windows.zip`, usado pelo botão de download do README.
