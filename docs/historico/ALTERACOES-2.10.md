# Alterações — P.A.RADOXO 2.10

- Margem interna mínima de 24 pixels entre o conteúdo e a barra de rolagem. Solução compartilhada para história, caderno, controles, perguntas, desfecho, aprendizagem, lista de jornadas e créditos com movimento reduzido. Textos continuam justificados, com mouse/teclado e sem rolagem horizontal acidental.
- Início exige nome válido e seleção explícita de personagem e dificuldade. Nova tela começa sem opções marcadas, inclusive quando aberta novamente. A prévia aguarda a escolha do personagem. Ao tentar iniciar com pendências, um aviso informa o que falta, destaca os campos e move o foco para a primeira pendência. Dados preenchidos são preservados e nenhuma jornada incompleta é criada.
- Nomes com apenas espaços, inclusive espaços Unicode, ou caracteres invisíveis já filtrados não são aceitos na criação pela interface. Acentos, símbolos e emojis continuam permitidos. Jornadas antigas mantêm o carregamento e normalização anteriores.
- Tapete ocupa um retângulo alinhado à grade (colunas 3 a 6, linhas 1 a 6), inteiramente dentro do piso interno, com costura recuada nas quatro bordas. Banco permanece no eixo central. Mesmo desenho na abertura, nas três galerias, no desfecho e nos créditos, nos dois modos.
- Músicas e efeitos preservados.

Testes de validação cobrem todas as combinações incompletas de nome/personagem/modo, seleções válidas, foco, preservação do formulário, ambos os personagens/modos, texto normal/ampliado e as três galerias. Verificações geométricas confirmam margem de rolagem e limites do tapete; capturas nativas inspecionadas.
