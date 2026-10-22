# Publicação concluída — 22/10/2026

A página pública e o QR code foram validados. Jogue: https://mariomont30.github.io/paradoxo-museu-fora-do-tempo/. Veja PUBLICACAO-2.12.md para os resultados e limites dos testes. Os relatos de bloqueio abaixo são históricos, anteriores à publicação no GitHub Pages.

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


Verificação final da entrega: executável Windows exportado aprovado na campanha de 48 restaurações. Créditos no Chrome com emulação móvel e texto ampliado: pausa, retomada por toque e saída ao menu em 667 × 375 aprovadas, sem erros de console. Os 13 arquivos de áudio têm SHA-256 idêntico aos da versão 2.11. Pacotes ZIP verificados por CRC e identidade dos arquivos internos no pacote completo. A revisão visual detectou e corrigiu também a largura do botão Meu aprendizado com texto ampliado.
