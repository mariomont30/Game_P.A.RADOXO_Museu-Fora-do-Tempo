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
godot --headless --path game --script ../tests/lives.gd
godot --headless --path game --script ../tests/questions.gd
godot --headless --path game --script ../tests/transitions.gd
godot --headless --path game --script ../tests/interface.gd
godot --headless --path game --script ../tests/functional_regression.gd
```

O primeiro comando reconstrói as respostas a partir dos dados exibidos nas 4.200 questões e confere também as contas das soluções. Os testes Godot verificam o GAME OVER, 45.000 sorteios e 100.000 posições de alternativas, além de salvamento e migração de jornadas antigas. Testes automáticos não substituem o ensaio visual e a avaliação em aparelhos físicos.

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

Para uma nova distribuição, atualize `config/version` em `game/project.godot` e envie a mudança. A tag é `v` seguida dessa versão. Os arquivos de uma Release existente são preservados: incremente a versão quando mudar o jogo. A descrição da Release usa as informações atuais do projeto. Mudanças apenas no README não disparam uma nova distribuição.

## Web

A entrada pública é o `index.html` da raiz, com `<base href="./web/">`. O motor, PCK, estilos, scripts e imagens ficam em `web/`. As licenças ficam em `licenses/`. Preserve essa estrutura ao hospedar. A URL e o QR code atuais permanecem válidos.

Para uma nova exportação Web, use o preset Web em uma pasta nova e execute `python game/tools/build_mobile_web.py CAMINHO_DA_EXPORTACAO`. O script prepara a entrada móvel e deve receber um HTML recém-exportado. A publicação atual usa WASM comprimido e um carregador correspondente: não substitua apenas parte dos arquivos. A automação Windows não altera a Web publicada. Para atualizar o site, prepare uma pasta completa com `tools/build_web_site.py` e copie a entrada e os recursos juntos.

## Recriar música

Os WAVs estão incluídos; não é necessário recriá-los para editar ou exportar. Para regenerá-los, preserve esta ordem:

```sh
python game/tools/build_assets.py
python game/tools/build_finale.py
python game/tools/build_menu.py
python game/tools/build_credits.py
```

Esses scripts geram as músicas. Os efeitos curtos existentes continuam em `game/audio/`. O código de geração usa somente a biblioteca padrão do Python.

## Gerar e verificar o banco

Execute `python game/tools/build_questions.py` para gerar o banco de forma reproduzível. Depois execute `python game/validate_bank.py`, que usa cálculos independentes com frações exatas. O arquivo `questions_legacy_215.json` é somente uma referência canônica para salvamentos antigos e não participa do sorteio. A semente dos testes é fixa para reproduzir falhas. No jogo, o sorteio é aleatório.

## Apresentações das galerias

`gallery_transition.gd` controla uma apresentação independente do cenário jogável. `game.gd` bloqueia a entrada e o cronômetro durante a sequência, preserva o estado e registra as primeiras entradas concluídas em `introduced_galleries`. Salvamentos antigos aceitam o campo ausente e não repetem apresentações antigas. Uma apresentação inicial interrompida pode ser retomada sem perder progresso.

`python game/tools/build_arrivals.py` recria os cinco efeitos originais de passagem. Cada efeito tem um player dedicado, respeita o volume de efeitos e acompanha a suspensão da apresentação. As músicas existentes não são regeneradas por esse comando.

## Recuperação do carregamento Web

A exportação usa `game/web/mobile.js` para a entrada por gesto e `game/web/loader_recovery.js`, inserido antes dos scripts externos, para apresentar falhas de rede em português. **Tentar novamente** recarrega a página com uma nova instância do motor. Não limpa IndexedDB nem altera o formato do salvamento. Os auxiliares CSS e JS e o PCK recebem a versão na URL.

Para reproduzir a distribuição comprimida, exporte e prepare uma pasta nova:

```sh
mkdir -p build/web
godot --headless --path game --export-release Web ../build/web/index.html
python game/tools/build_mobile_web.py build/web
python tools/build_web_site.py build/web build/site
```

O teste opcional de navegador usa Node.js, `playwright-core` e um Chrome/Chromium instalado. Ele serve a pasta localmente, usa contextos isolados, simula falhas no PCK, WASM e nos scripts, verifica o botão de recuperação e confirma a preservação do IndexedDB. Não acessa perfis pessoais. Instale a dependência com `npm install --no-save --package-lock=false playwright-core`. Configure `BROWSER_EXECUTABLE` com o caminho do navegador e execute:

```sh
node tests/web_recovery.mjs build/site test-results/web-recovery
node tests/web_welcome.mjs build/site test-results/web-welcome
```

A suíte Godot `interface.gd` verifica layout, nomes e navegação. `functional_regression.gd` verifica exploração, cronômetro, salvamento, sobreposições e restauração. A execução com `-- --visual` em `interface.gd`, sem `--headless`, também grava capturas em um diretório de usuário isolado. Use um diretório de dados de teste ao rodar as suítes para não interferir nas suas jornadas.

## Atualizar a pasta publicada

A pasta criada pelo preparador contém `index.html`, `.nojekyll`, `web/` e `licenses/`. Copie esses arquivos para as posições correspondentes do repositório. Não copie somente o PCK. Os auxiliares usam `document.baseURI` para resolver os recursos, mantendo a página no endereço principal.

Para testar os arquivos já organizados, também é possível executar `node tests/web_recovery.mjs . test-results/web-recovery`. A base dessa página é a pasta `web/`, enquanto o endereço e o armazenamento do navegador continuam pertencendo ao mesmo site.

## Corações e tentativas

`lives_display.gd` desenha os corações em vetor, sem depender de emojis do sistema. O limite é três no Normal e dois no Difícil. `start_restore` renova as chances imediatamente após um acerto, antes de salvar a animação. A retomada de uma restauração concluída também preserva essa renovação. `skip_question` mantém as vidas, a derrota usada e o tempo restante.

O campo `rules_version` vale 5. A migração mantém a perda relativa de vidas das versões anteriores, sem reviver uma tentativa esgotada ou apagar uma jornada que ainda estava ativa. Estados concluídos não carregam a antiga derrota para o próximo desafio. Os testes usam dados isolados e incluem recarga, troca repetida e limite de corações.

`web_welcome.mjs` confere a abertura em alturas reduzidas e com texto ampliado, sem rolagem. O CSS compacta a composição e o auxiliar observa mudanças da área visível do navegador para manter o texto completo e o botão dentro da tela.

### Entrada e preparação

`tests/native_entry.gd` verifica a entrada nativa, as etapas reais de carregamento, a preferência de movimento e a preservação do salvamento ao fechar antes da preparação. Execute `godot --headless --path game --script ../tests/native_entry.gd`; acrescente `-- --visual` para capturas. O Windows exportado inicia na entrada. O editor e os testes carregam diretamente para facilitar o desenvolvimento.

O fundo da entrada Web está em `media/abertura/museu.png`, renderizado pelo próprio cenário. O construtor Web copia a imagem para `web/welcome-museum.png`. A preferência de movimento reduzido da Web é espelhada como um booleano em localStorage para a abertura, sem dados da jornada. A barra usa o topo apenas em dispositivos de toque.

`tests/menu_return.gd` verifica os retornos pela pausa da exploração, pela pausa da pergunta e pelas duas derrotas. Cobre os dois layouts, modos e personagens, as três alas e texto ampliado. Execute `godot --headless --path game --script ../tests/menu_return.gd`. Para capturas, remova `--headless` e acrescente `-- --visual`.

`tests/countdown.gd` verifica os avisos do cronômetro, sem repetições por quadro, com pausa/retomada, troca de pergunta, volume e quadros atrasados. Executar `godot --headless --path game --script ../tests/countdown.gd`. Os pulsos usam o efeito original `tick.wav`, em canal próprio, sem substituir os demais sons.

O limite efetivo do Difícil é definido por `question_time_limit`: 60 s nos conteúdos 0–2, 75 s em 3–4 e 90 s em 5–6. A questão salva e a metadata original do banco permanecem intactas para continuar validando os salvamentos anteriores. O tempo restante é limitado ao novo máximo ao retomar, preservando alternativas, vidas e tentativas.
