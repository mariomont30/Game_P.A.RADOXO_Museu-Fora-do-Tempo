# Atualização 2.17 | A entrada de cada descoberta

## Apresentações

A Ala 1 recebe uma abertura automática. Ao concluir a quarta e a oitava obras, Continuar explorando apresenta a próxima galeria. A entrada destaca o título, a engrenagem, as partículas e uma aproximação suave do cenário. A décima segunda obra conduz a uma apresentação de encerramento.

Cada apresentação completa dura 3,8 segundos. Não há botão ou atalho para pular. Os controles e o cronômetro aguardam a conclusão. A exploração começa com o personagem sentado no banco. Visitas pelo mapa a uma galeria já apresentada têm passagem de 0,65 segundo, ou 0,5 segundo com Movimento reduzido.

Histórico de entradas concluídas é salvo em `introduced_galleries`. Uma abertura interrompida pode reaparecer ao continuar. Salvamentos anteriores à atualização são aceitos sem repetir entradas antigas. Vidas, derrota anterior, questões vistas, alternativas e obras concluídas são preservadas.

## Identidade dos ambientes

- Arte: verde azulado e dourado.
- História Natural: piso em areia, paredes em argila e detalhes em âmbar.
- Invenções: violeta, com azul luminoso na apresentação.

O desenho compartilhado do museu aplica a paleta da História Natural à exploração, à pausa, às apresentações e ao fundo dos créditos. O README usa uma captura atualizada dessa galeria.

## Som e acessibilidade

Foram compostos quatro efeitos musicais curtos de entrada e um som de passagem pelo mapa. São gerados pelo próprio projeto, em estéreo a 44.100 Hz. Há um player dedicado para que o som de interface não interrompa a apresentação. O efeito respeita Efeitos sonoros e Volume geral. A trilha baixa durante a entrada e recupera o volume depois.

Os 15 arquivos de áudio anteriores permanecem idênticos. As músicas existentes, o banco de 4.200 perguntas e o QR code não foram alterados. Movimento reduzido usa apenas dissolução e leitura, sem partículas, rotação da engrenagem ou aproximação de câmera. Perda de foco e orientação vertical suspendem a apresentação e o som.

## Testes desta alteração

- 2.296 verificações de transição em 128 combinações de modo, personagem, layout, tamanho de texto, preferência de movimento e destino.
- Abertura da Ala 1, passagem às alas 2 e 3, retorno breve pelo mapa e encerramento.
- Cliques e teclas não pulam a apresentação. Galerias bloqueadas permanecem bloqueadas.
- Salvamento interrompido, retorno ao jogo, compatibilidade com perfis antigos e histórico de entradas inválido.
- Suspensão por foco e orientação, player dedicado e retomada do som.
- 2.028 verificações de GAME OVER em 96 combinações.
- 250.932 verificações do banco e sorteio, incluindo 45.000 sorteios e 100.000 posições de alternativas.
- As 4.200 perguntas e 8.160 igualdades das soluções passaram novamente pelo validador matemático.
- 48 missões na fonte e no executável Windows exportado.
- Chrome com Web exportada: abertura automática em toque/Normal e mouse/Difícil, teclas sem pular, primeira derrota, recarregamento, tentativa extra e segunda derrota com exclusão persistida da jornada. Sem erros JavaScript ou Godot.
- Capturas das quatro apresentações e das três galerias em computador e layout móvel. Sem rótulos cortados na matriz verificada.

Os ensaios móveis usam layout e toque emulados. Eles não equivalem a uma certificação em aparelhos Android ou iOS físicos. A auditoria geral solicitada anteriormente continua pausada. Estes testes cobrem a alteração e suas regressões.
