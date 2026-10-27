# Desenvolvimento e exportação

Voltar ao [README](../README.md).

## Abrir o projeto

Clone o repositório e importe `game/project.godot` no Godot **4.7.2**. Áudios, fontes, cenas e banco de questões estão incluídos. O diretório `.godot/` é gerado pelo editor e não deve ser versionado. Os arquivos `.import` preservam os parâmetros dos recursos; `.uid` preservam os identificadores dos scripts.

## Validar

Com Python 3 e Godot instalados:

```sh
python game/validate_bank.py
godot --headless --path game --editor --quit
godot --headless --path game -- --smoke
godot --headless --path game --script ../tests/gameover.gd
```

O primeiro comando recalcula as respostas das 1.050 questões. O último executa a verificação interna. Testes automáticos não substituem o ensaio visual e a avaliação em aparelhos físicos.

## Exportar para Windows

Instale os templates de exportação da mesma versão do Godot. Na raiz do repositório:

```sh
mkdir -p build/windows
godot --headless --path game --export-release Windows ../build/windows/PARADOXO.exe
python tools/package_release.py
```

No Windows, também é possível criar a pasta pelo Explorador e usar Projeto → Exportar no editor. O comando de Godot usa `../build/...` porque o projeto fica em `game/`. O empacotamento gera `dist/PARADOXO-Windows.zip`, `dist/PARADOXO-Projeto.zip` e `dist/SHA256SUMS.txt` e confere a integridade dos ZIPs.

## Release automatizada

O workflow `.github/workflows/windows-release.yml` valida o banco, importa e verifica o projeto, exporta o Windows e cria uma Release com os ZIPs. Não exige senha ou token pessoal no código; usa o token temporário do próprio GitHub Actions com permissão de conteúdo.

Para uma nova distribuição, atualize `config/version` em `game/project.godot` e envie a mudança. A tag é `v` seguida dessa versão. Uma Release existente não é sobrescrita: incremente a versão quando mudar o jogo. Mudanças apenas no README não disparam uma nova distribuição.

## Web

A distribuição Web pública está na raiz, separada do projeto editável. Os arquivos `index.*`, `mobile.*`, `.nojekyll`, `_headers` e `licenses/` necessários à hospedagem devem ser preservados juntos. A URL e o QR code atuais permanecem válidos.

Para uma nova exportação Web, use o preset Web em uma pasta nova e execute `python game/tools/build_mobile_web.py CAMINHO_DA_EXPORTACAO`. O script prepara a entrada móvel e deve receber um HTML recém-exportado. A publicação atual usa WASM comprimido e um carregador correspondente: não substitua apenas parte dos arquivos. A automação Windows não altera a Web publicada.

## Recriar música

Os WAVs estão incluídos; não é necessário recriá-los para editar ou exportar. Para regenerá-los, preserve esta ordem:

```sh
python game/tools/build_assets.py
python game/tools/build_finale.py
python game/tools/build_menu.py
python game/tools/build_credits.py
```

Esses scripts geram as músicas. Os efeitos curtos existentes continuam em `game/audio/`. O código de geração usa somente a biblioteca padrão do Python.
