# Atualização 2.16 | Banco e sorteio

## Banco de perguntas

São 4.200 questões novas, 2.100 por modo e 300 por conteúdo. Cada grupo contém cinco formas de apresentar os dados, com 60 questões por formato. Sequências, registros, tabelas, mecanismos e restaurações variam a leitura dos problemas.

| Resposta | Normal | Difícil |
| --- | ---: | ---: |
| Positiva | 1.000 | 1.000 |
| Negativa | 700 | 700 |
| Zero | 100 | 100 |
| Classificação textual | 300 | 300 |

Questões sobre posição têm resposta positiva por definição. Nos outros cinco conteúdos numéricos, cada modo tem 140 respostas positivas, 140 negativas e 20 iguais a zero por conteúdo. No reconhecimento, as quatro classificações têm 75 itens cada. O Difícil apresenta termos em posições não consecutivas e exige reconstruir a razão ou o primeiro termo.

As quatro alternativas são distintas e têm uma única resposta correta. A resposta não nula nunca é a única opção com seu sinal. O zero também aparece como alternativa incorreta. A posição do valor correto entre as opções ordenadas é distribuída em 75 itens por posição em cada conteúdo numérico, antes do embaralhamento no jogo.

## Sorteio e salvamento

O sorteio evita identificadores e combinações matemáticas já vistos na jornada, inclusive de perguntas da versão anterior. Varia os formatos e evita três respostas numéricas seguidas do mesmo sinal quando ainda há outra opção disponível. Todo item permanece alcançável.

As posições corretas usam equilíbrio probabilístico limitado, sem uma rotação fixa de quatro perguntas. A posição anterior é evitada. As demais alternativas também são embaralhadas. Pausar, abrir o caderno, salvar e retomar mantêm a ordem da questão atual. O sorteio não interfere na resposta matemática.

O histórico e a pergunta atual são salvos. O arquivo do banco 2.15 é mantido apenas para conferir questões antigas já salvas. Vidas, tempo restante e a tentativa extra não são reiniciados na migração. Esgotar um conteúdo pede autorização para revisá-lo, preservando os demais conteúdos e o tempo restante no Difícil.

## Verificação executada

- 4.200 enunciados conferidos contra os dados exibidos.
- 3.600 respostas numéricas recalculadas com frações exatas e 600 classificações reconstruídas.
- 8.160 igualdades das soluções avaliadas independentemente.
- 45.000 sorteios, incluindo 2.000 jornadas e esgotamento dos 14 grupos de 300 itens.
- 100.000 sorteios de posição, sem repetição consecutiva e sem ciclo fixo de quatro opções.
- 250.932 verificações Godot de banco, sorteio, migração e salvamento.
- 2.028 verificações de GAME OVER em 96 combinações de missão, modo, personagem, layout e preferências.
- Teste geral de 48 missões.
- 140 apresentações com os enunciados mais longos de cada grupo e texto ampliado, nos layouts computador e celular, sem rótulos cortados. Textos extensos continuam em áreas de rolagem.

- Chrome com a exportação Web final: toque no layout celular/Normal e mouse no computador/Difícil. Primeira derrota, recarregamento da página, tentativa extra, segunda derrota, exclusão persistida da jornada e retorno ao menu passaram sem erros JavaScript ou Godot.

Os testes matemáticos e de interface são automatizados. O ensaio móvel usa layout e navegador emulados, sem teste em aparelho físico. Eles reduzem o risco de falhas e não constituem garantia absoluta de ausência de erros.

A URL pública e o QR code são mantidos. As músicas e as regras de GAME OVER da versão anterior são preservadas.
