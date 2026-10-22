# P.A.RADOXO 2.13 — galerias maiores no celular

O cenário da exploração passa a usar a altura disponível entre o cabeçalho e a base da tela. A escala passa de 0,36 para 0,565 na base de 960 × 540: aumento de aproximadamente 57% em largura e altura. O museu inteiro permanece visível, sem cortar piso, paredes ou obras.

Cards da galeria e da missão ocupam os cantos superiores; os direcionais ficam no canto inferior esquerdo e as ações à direita. O rodapé não atravessa mais o cenário. As posições reconhecidas pelo toque acompanham a ampliação. A alteração usa o layout móvel compartilhado pelas três galerias, ambos os personagens e modos Normal/Difícil, com texto normal e ampliado. A interface do computador mantém seu enquadramento anterior.

A página Web identifica a revisão e pede o arquivo do jogo com uma chave de versão para reduzir a reutilização do pacote anterior pelo cache. O endereço público e o QR code continuam os mesmos; não há mudança na origem das jornadas.

Validação local: 15.192 verificações móveis aprovadas, incluindo todas as obras, escala, piso dentro da tela, toque livre de botões e texto ampliado; 439 verificações desktop e 47 de regressão aprovadas. Capturas das três galerias preparadas. Músicas, matemática e regras de pausa preservadas. Atualização pública concluída e validada; resultados em PUBLICACAO-2.13.md.

---

# Publicação concluída — 22/10/2026

A página pública e o QR code foram validados. Jogue: https://mariomont30.github.io/Game_P.A.RADOXO_Museu-Fora-do-Tempo/. Veja PUBLICACAO-2.12.md para os resultados e limites dos testes. Os relatos de bloqueio abaixo são históricos, anteriores à publicação no GitHub Pages.

---

# P.A.RADOXO 2.12 — adaptação para celular

## Interface e controles

- Interface Web com disposição própria para dispositivos de toque, em orientação horizontal. Cards, perguntas, alternativas, mapa, caderno, configurações, jornadas, desfecho e créditos cabem na área de apresentação móvel.
- Botões principais com altura mínima de 64 unidades na base de 960 × 540; direcionais maiores. Textos longos e dicas têm rolagem, com espaço antes da barra. O enquadramento do museu e a posição reconhecida pelo toque usam a mesma transformação.
- A página abre com Entrar no museu, permitindo iniciar áudio após interação. No celular, o nome é digitado em um campo HTML que permite usar o teclado do navegador. Nome, personagem e dificuldade continuam obrigatórios.
- O celular na vertical recebe orientação para girar. Durante uma partida ativa, a mudança para vertical solicita a pausa pela regra existente do banco; retomar exige ação do jogador. O cronômetro do Difícil continua durante a caminhada até sentar.
- Créditos móveis oferecem Retomar letras por toque ao lado da saída para o menu enquanto pausados. A pausa continua afetando somente as letras. No computador, Esc/Enter e o desenho anterior são preservados.
- Fórmulas com índices i/j usam a[i] e a[j], com legenda, evitando caracteres ausentes na fonte.

## Regras preservadas

Dois personagens, modos Normal e Difícil, três galerias, doze restaurações e banco de 1.050 questões. Duas vidas; pausa após sentar; retomada após levantar; salvamento da questão, alternativas, seleção, tempo e progresso. Músicas e efeitos anteriores preservados. Os arquivos ZIP 2.11 continuam disponíveis.

As jornadas Web pertencem ao navegador e endereço utilizados. Não há sincronização automática entre Windows, computadores, celulares ou endereços diferentes. Limpar os dados do navegador pode remover as jornadas.

## Validação

- 11.160 verificações de interface móvel aprovadas: ambos os personagens, modos, tamanhos de texto e todas as restaurações; toque e coordenadas do piso, modais, controles, retomada, créditos e movimento reduzido.
- 439 verificações da interface de computador e 47 de regressão aprovadas; campanha interna de 48 restaurações aprovada.
- Navegador Chrome com emulação de toque: entrada, nome acentuado, seleção explícita, mapa, questão, dica, caderno com gesto de arrastar, pausa, recarga e retomada. Tamanhos conferidos: 844 × 390, 667 × 375 e orientação vertical 390 × 844.

Estes testes não substituem o ensaio em aparelhos Android e iPhone reais. Não há garantia de ausência absoluta de defeitos ou de desempenho igual em todos os aparelhos.

## Publicação e entrega acadêmica

A exportação Web está preparada para hospedagem HTTP(S). A sincronização com a hospedagem foi bloqueada pela revisão automática de aprovação de execução nesta sessão; a autenticação local do GitHub também estava inválida. Não foi validada uma URL pública, portanto não foi gerado um QR code definitivo. O pacote Publicar contém os arquivos estáticos com index.html na raiz, sem credenciais.

O QR code deve ser criado somente depois de publicar e abrir o endereço real, sem login, em outro dispositivo. Slides permanecem adiados a pedido do usuário; publicação, envio ao AVA e apresentação continuam pendências da entrega acadêmica.


---

# Alterações — P.A.RADOXO 2.11

- Pausa exclusiva dos letreiros finais: Pausar, Esc, Enter e Enter numérico interrompem apenas as letras. Música, animação e alternância das galerias continuam, respeitando a opção Movimento reduzido. Nenhuma caminhada ao banco ou abertura do menu de pausa.
- Um único botão centralizado: Pausar durante a subida; Sair para o menu principal quando as letras estão pausadas. Para retomar a subida, use Esc ou Enter. Teclas mantidas não alternam repetidamente; Enter com foco na saída retoma os letreiros em vez de sair.
- Botões Explorar museu e Menu retirados dos créditos. FIM continua retornando ao menu quando sai da tela, depois de retomar se estiver pausado.
- Em Movimento reduzido, a leitura manual continua disponível; ao pausar as letras, setas e roda do mouse ficam bloqueadas até a retomada. Sair ao menu e abrir novamente os créditos limpa a pausa anterior.
- Regra de pausa durante a exploração permanece a mesma. Músicas e efeitos preservados. Guia de controles atualizado.

Validação nativa: 1.056 verificações específicas, nos dois modos, dois personagens, texto normal/ampliado e com/sem movimento reduzido. Cobertura de clique, Esc, Enter/Enter numérico, música avançando, galerias sem congelar, ausência de rota ao banco/modal, rolagem, retorno ao menu e limpeza de estado. Mais 439 verificações de interação, 47 de regressão e campanha com 48 restaurações, aprovadas.
Verificação das exportações: campanha de 48 restaurações aprovada no executável Windows. No Chrome, clique em Pausar, Enter para retomar, Esc para pausar e clique na saída para o menu aprovados, inclusive em 960×600, sem erros de console. Relatório work/v2/browser211-report.json. Total: 1.542 verificações automatizadas, além da campanha.


---

# Alterações — P.A.RADOXO 2.10

- Margem interna mínima de 24 pixels entre o conteúdo e a barra de rolagem. Solução compartilhada para história, caderno, controles, perguntas, desfecho, aprendizagem, lista de jornadas e créditos com movimento reduzido. Textos continuam justificados, com mouse/teclado e sem rolagem horizontal acidental.
- Início exige nome válido e seleção explícita de personagem e dificuldade. Nova tela começa sem opções marcadas, inclusive quando aberta novamente. A prévia aguarda a escolha do personagem. Ao tentar iniciar com pendências, um aviso informa o que falta, destaca os campos e move o foco para a primeira pendência. Dados preenchidos são preservados e nenhuma jornada incompleta é criada.
- Nomes com apenas espaços, inclusive espaços Unicode, ou caracteres invisíveis já filtrados não são aceitos na criação pela interface. Acentos, símbolos e emojis continuam permitidos. Jornadas antigas mantêm o carregamento e normalização anteriores.
- Tapete ocupa um retângulo alinhado à grade (colunas 3 a 6, linhas 1 a 6), inteiramente dentro do piso interno, com costura recuada nas quatro bordas. Banco permanece no eixo central. Mesmo desenho na abertura, nas três galerias, no desfecho e nos créditos, nos dois modos.
- Músicas e efeitos preservados.

Testes de validação cobrem todas as combinações incompletas de nome/personagem/modo, seleções válidas, foco, preservação do formulário, ambos os personagens/modos, texto normal/ampliado e as três galerias. Verificações geométricas confirmam margem de rolagem e limites do tapete; capturas nativas inspecionadas.

---

# Alterações — P.A.RADOXO 2.9

- Textos de conteúdo justificados, com a última linha natural; títulos e botões preservam hierarquia e alinhamento adequados. Medição da altura real dos parágrafos evita cortes em cards curtos, inclusive com texto ampliado. Rolagem por mouse e teclado preservada.
- Desfecho reorganizado em duas áreas sem sobreposição: card à esquerda e galeria completa à direita, com todas as obras restauradas e personagem escolhido no banco.
- Créditos com as três galerias restauradas ao fundo. Cada galeria permanece cerca de 12 segundos, com dissolução suave nos últimos três. Camada escura, painel de leitura discreto e sombra nas letras mantêm o contraste. A pausa congela letras, cenários e transições. Movimento reduzido oferece fundo estático e rolagem manual pelo teclado/mouse.
- Música original exclusiva para os créditos, com clima de conquista, melodia diferente, baixo e percussão a 132 BPM. Menu, três galerias, tema do desfecho e todos os efeitos foram preservados byte a byte.
- FIM continua retornando ao menu quando sai da tela; explorar o museu e Meu aprendizado permanecem disponíveis. Jornadas anteriores preservadas.

Validação: 233 verificações específicas do desfecho/créditos e de leitura, com ambos os personagens, ambos os modos e texto normal/ampliado; alternância das três galerias, pausa, movimento reduzido, teclado e retorno ao menu. Mais 439 verificações de interação, 47 de regressão e campanha de 48 restaurações. Áudio sem saturação digital e teste de pausa/retomada aprovado. Mais 222 verificações de diagramação em personagens/modos/galerias, com e sem texto ampliado: 941 verificações no total. Executável Windows exportado passou a campanha de 48 restaurações. Chrome validou desfecho com texto ampliado, créditos, pausa/retomada e viewport 960×600, sem erros de console. Jornada completa criada apenas no contexto isolado de teste do navegador. Capturas nativas inspecionadas em outputs/29-*.png; capturas Web em work/v2/browser29-*.png.

---

# Alterações — P.A.RADOXO 2.8

- Música original de abertura mais animada, com melodia de aventura, baixo e percussão a 122 BPM. Apenas menu.wav mudou: músicas das três alas, encerramento e todos os efeitos preservados byte a byte.
- Contorno verde retirado das áreas de texto e rolagem. Campo de nome usa borda neutra. Setas, Page Up/Down, Home/End, Tab e roda do mouse continuam disponíveis; botões mantêm indicação de seleção para navegação pelo teclado.
- Cards de mensagens curtas ajustam sua altura ao conteúdo; confirmações deixam de ocupar uma janela quase vazia. Textos longos preservam espaço de leitura e rolagem, com título e ações fora da área rolável.
- Voltar e Iniciar centralizados lado a lado no card de escolha. Descrições e margens ajustadas também para texto ampliado, sem ultrapassar o card do personagem.
- Borda superior completada no desenho compartilhado de todas as janelas arquitetônicas: abertura e três galerias.

Verificações: 222 verificações de layout (dois personagens × dois modos × três galerias × dois tamanhos de texto), 439 de interação/pausa/teclado, 47 de regressão e campanha de 48 restaurações. Áudio: inicialização, pausa/retomada e ausência de saturação digital. Capturas nativas inspecionadas.
Validação concluída: 816 verificações novas de formulário/margens/tapete, 439 de interação, 233 de desfecho/créditos e 47 de regressão (1.535 no total), todas aprovadas.
Chrome: tentativa vazia e nome sem escolhas bloqueados; escolha explícita e início válidos; pausa, recarga/continuação e exclusão de jornada aprovadas. Nenhum erro de console, com capturas em 1280×800 e 960×600 (work/v2/browser210-report.json).
 Campanha com 48 restaurações aprovada também no executável Windows exportado. Todas as músicas e efeitos comparados com o pacote 2.9: idênticos.
 Exportações Windows e Web atualizadas. Executável Windows validado com campanha de 48 restaurações. Chrome: criação, rolagem, pausa no banco, retomada, recarga e continuação da mesma questão, confirmação compacta e exclusão de jornada; nenhum erro de console, com capturas em 1280×800 e 960×600.

---

# Validação — entrega 2.7

Executada em 22/10/2026 com Godot 4.7.2 no Windows e exportação Web no Chrome.

## Resultados

- 439 verificações específicas aprovadas. Incluem 36 ciclos de pausa na exploração (três formas de solicitar × três galerias × dois modos × dois personagens), além de pausas durante questões nos mesmos modos, personagens e galerias.
- Ida ao banco sem teletransporte, pausa somente depois de sentar, música pausada, retomada após levantar e controles bloqueados durante as transições.
- Início sentado na primeira fase e em visitas às outras salas. Banco manual sem pausa. Levantar por setas com atualização da mensagem de estado. Tooltip retirado.
- Questão e alternativas preservadas; cronômetro do Difícil continua no caminho e congela após sentar. Esgotamento de tempo durante a caminhada aplica a perda de vida e mantém a rota, sem teletransporte ou descarte do colapso.
- Retorno dos controles e das configurações ao menu de pausa sem liberar o jogo indevidamente.
- Teclado: navegação e ativação de opções com setas/Espaço, alternativas, jornadas, exclusão e controles de volume. Rolagem em história, caderno, aprendizado e créditos acessíveis; Home/End, Page Down e Tab.
- Guia atualizado e créditos sem a seção Inspirações visuais. Abertura e pausa de cada sala capturadas; personagens separados da obra dianteira.
- 47 verificações de regressão aprovadas: migração de jornadas, progresso, vidas, exclusão e backup, posição, pergunta, ordem, seleção, tempo e restaurações interrompidas.
- Campanha automática de 48 restaurações: 12 obras × dois modos × dois personagens, incluindo campos vazios, erros repetidos, dicas, acertos, tempo esgotado e colapso. Navegação e esgotamento do banco também verificados.
- Auditoria matemática independente dos 1.050 gabaritos aprovada, com IDs, assinaturas matemáticas e alternativas únicos.
- Chrome: guia rolado pelo teclado, início sentado, deslocamento por setas, pausa por Enter após ida ao banco, retomada, questão, pausa por Esc, recarregamento, continuação da mesma pergunta/alternativas/seleção pelo teclado e exclusão. Telas em 1280×800 e 960×600. Sem erros de console no fluxo executado.
- Exportações Windows e Web concluídas; integridade dos três ZIPs conferida.

## Continuidade e limites

As jornadas anteriores são reconhecidas no mesmo usuário do Windows; os testes usam pastas isoladas. O início sentado se aplica a entradas nas galerias. Continuar uma jornada preserva o estado salvo.

Os resultados se referem aos fluxos executados e não são garantia de ausência de qualquer defeito em todo dispositivo. Não houve teste em celulares físicos nem estudo com alunos. No modo Difícil, a caminhada para pausar ainda consome tempo, conforme explicado no guia. A leitura dos créditos com Movimento reduzido é manual. A exportação Web precisa de hospedagem; não foi criado um endereço público nesta entrega.


Verificação final da entrega: executável Windows exportado aprovado na campanha de 48 restaurações. Créditos no Chrome com emulação móvel e texto ampliado: pausa, retomada por toque e saída ao menu em 667 × 375 aprovadas, sem erros de console. Os 13 arquivos de áudio têm SHA-256 idêntico aos da versão 2.11. Pacotes ZIP verificados por CRC e identidade dos arquivos internos no pacote completo. A revisão visual detectou e corrigiu também a largura do botão Meu aprendizado com texto ampliado.
