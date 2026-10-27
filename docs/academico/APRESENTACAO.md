# P.A.RADOXO — Conteúdo de 10 slides

Este arquivo contém o texto e as notas da apresentação. Não é um arquivo PowerPoint. Use as capturas de tela fornecidas no pacote para ilustrar os slides.

## Slide 1 — P.A.RADOXO

O Museu Fora do Tempo

Universidade de Fortaleza
Centro de Ciências Tecnológicas
Disciplina: Res problemas nat discreta
Professor: Rubens Rodrigues
Projeto Aplicado: Progressão Aritmética

Integrantes: Mário Monteiro, Bruno Gonçalves, Ana Gabriella e José Cleidson

**Visual:** menu do jogo.
**Fala:** apresentar a equipe e o objetivo de aprender P.A. restaurando um museu.

## Slide 2 — Objetivo educacional

Público: alunos do ensino médio.

Reconhecer padrões, calcular termos e somas e compreender a razão de uma P.A. por meio de desafios interativos.

**Fala:** o jogo conecta o resultado matemático a uma mudança visível na exposição. Não alegar melhoria de notas ou aprendizagem medida, pois não houve estudo com alunos.

## Slide 3 — Planejamento e escolha

Ideias consideradas: ferrovia, fábrica e museu temporal.

O museu foi escolhido pela variedade de objetos restauráveis e pela possibilidade de explorar ambientes diferentes.

Plataforma: Godot 4.7.2, GDScript e arte isométrica em 2D.

**Visual:** visão geral da galeria.
**Fala:** explicar a evolução do corredor inicial para o diorama com navegação.

## Slide 4 — História e personagens

O Curador congelou o tempo para preservar as obras.

Tico é um robô em forma de relógio, criado para orientar os visitantes e cuidar dos mecanismos. Com o tempo congelado, perdeu parte das memórias. O jogador e Tico recuperam três engrenagens, restauram as exposições e devolvem o movimento ao museu.

Escolha de personagem masculino ou feminino e nome personalizado.

**Visual:** tela de seleção de personagem.

## Slide 5 — Interações

12 restaurações em três alas.

Cada obra propõe uma questão com quatro alternativas, sorteada de acordo com seu conteúdo e com o modo escolhido. Resolver a questão restaura visualmente a peça.

As obras permanecem restauradas e podem ser revisitadas.

**Visual:** bancada de restauração e obra concluída.
**Fala:** mostrar que o tutorial é adicional às 12 missões e que o banco supera o mínimo de dez questões exigido para quizzes.

## Slide 6 — Regras e acessibilidade

Normal: três corações, sem limite de tempo.
Difícil: dois corações e cronômetro por questão. Cada coração representa uma vida.

Pausa por Esc ou Enter após caminhar e sentar no banco, retomada após levantar, navegação por setas e leitura pelo teclado, dicas, caderno de fórmulas, volume ajustável, movimento reduzido e controles por teclado ou toque.

**Fala:** ao esgotar os corações, há uma tentativa extra para o desafio atual. Acertar recupera os corações e renova a tentativa extra. Uma segunda derrota antes do acerto encerra e apaga a jornada. Trocar a pergunta mantém as chances restantes. Campos vazios e respostas repetidas não descontam vidas adicionais.

## Slide 7 — Conteúdo matemático

r = a₂ − a₁
aₙ = a₁ + (n − 1)r
Sₙ = n(a₁ + aₙ)/2

Exemplo: 2, 5, 8, 11.
Razão: 3. Quarto termo: 11. Soma: 26.

**Fala:** também há P.A. constante/decrescente, primeiro termo, posição e reconhecimento de sequências que não são P.A.

## Slide 8 — Banco e desenvolvimento

4.200 questões, sendo 2.100 por modo.

Sorteio por conteúdo e histórico local. Alternativas embaralhadas, ordem preservada ao continuar e gabaritos recalculados independentemente.

**Fala:** questões são famílias de problemas com variação numérica. O banco é finito e solicita confirmação para revisão quando esgota um conteúdo.

## Slide 9 — Validação

48 missões automatizadas nos dois personagens e modos.

Testes de respostas, pausa, salvamento, cronômetro, derrota, navegação e continuação no navegador.

Os tempos do Difícil ainda precisam ser avaliados com alunos.

**Visual:** captura de pausa ou de uma das alas.
**Fala:** diferenciar testes de software de validação pedagógica.

## Slide 10 — Demonstração e acesso

Demonstrar uma restauração no Normal e as regras do Difícil.

Acesso: inserir o link público real após publicação, ou a forma de distribuição definida pela equipe.

Entregar slides e acesso no AVA até o prazo do professor.

**Fala:** a exportação Web está pronta, mas não houve publicação nesta sessão. Não inserir um endereço fictício ou localhost como acesso público.

## Roteiro de demonstração de três minutos

- 0:00–0:30: menu, escolha de personagem e objetivo.
- 0:30–1:30: caminhar até uma exposição, resolver e observar a restauração.
- 1:30–2:15: abrir o caderno e explicar a fórmula utilizada.
- 2:15–2:45: demonstrar pausa e explicar vidas/cronômetro do Difícil.
- 2:45–3:00: apresentar a forma real de acesso.

## Antes da entrega

Preencher integrantes. Montar os slides em PowerPoint ou ferramenta equivalente. Testar o acesso em outro dispositivo. Publicar o jogo. Gerar QR code somente depois de existir uma URL pública funcional. Entregar ambos os itens no AVA.
