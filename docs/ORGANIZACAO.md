# Organização e manutenção

Voltar ao [README](../README.md).

| Local | Responsabilidade |
| --- | --- |
| `game/` | Projeto Godot editável, cenas, scripts e recursos originais. |
| `game/web/` | Fontes dos auxiliares usados na exportação Web. |
| `web/` | Recursos exportados do navegador: motor, PCK, imagens, estilos e scripts. |
| `index.html` | Entrada online estável, com os recursos relativos a `web/`. |
| `_headers` | Regras de cabeçalhos HTTP para hospedagens compatíveis com esse formato. |
| `docs/` | Guia do jogador, desenvolvimento e manutenção. |
| `docs/LEIA-ME.txt` | Guia rápido para abrir o jogo e consultar as informações essenciais. |
| `docs/academico/` | Identificação do projeto e roteiro da apresentação. |
| `docs/referencias/` | Gabaritos para consulta. |
| `media/` | QR code e capturas usadas na apresentação do repositório. |
| `tests/` | Testes de interface, exploração, perguntas, transições e carregamento. |
| `tests/visual/` | Roteiros que geram capturas de tela. |
| `tools/` | Preparação Web e empacotamento. |
| `licenses/` | Licenças e avisos de terceiros. |
| `docs/CHANGELOG.md` | Resumo das novidades por versão. |
| Releases | Downloads Windows, projeto editável e checksums. |

A branch principal permanece `gh-pages`. A publicação continua usando a raiz, com `index.html` como entrada. O diretório `web/` concentra os recursos sem mudar a URL ou a origem dos dados salvos. O QR code aponta para esse endereço estável.

`build/` e `dist/` são saídas locais ignoradas pelo Git. Caches, credenciais, salvamentos pessoais e relatórios de trabalho não pertencem ao repositório. Os testes usam dados isolados. Código, imagens e composições próprias pertencem aos autores; consulte [licenças](../licenses/README.md).

O nome estável `PARADOXO-Windows.zip` nas Releases mantém o download do README funcionando. Pacotes publicados de versões anteriores são registros das distribuições daquela data.

O arquivo `_headers` permanece na raiz, que é a pasta publicada do site. Ele declara `X-Content-Type-Options: nosniff` e o tipo `application/octet-stream` para `/web/index.wasm.gz`. Essas regras são destinadas a provedores que interpretam esse formato, como a [Netlify](https://docs.netlify.com/manage/routing/headers/). Sua aplicação depende da hospedagem; o arquivo, por si só, não configura os cabeçalhos do GitHub Pages.

`docs/LEIA-ME.txt` oferece uma consulta rápida de acesso e regras essenciais. O README principal apresenta o projeto, o QR code e os downloads; o Guia do jogador detalha os controles e a jornada.
