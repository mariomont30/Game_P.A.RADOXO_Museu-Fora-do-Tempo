# Alterações — P.A.RADOXO 2.11

- Pausa exclusiva dos letreiros finais: Pausar, Esc, Enter e Enter numérico interrompem apenas as letras. Música, animação e alternância das galerias continuam, respeitando a opção Movimento reduzido. Nenhuma caminhada ao banco ou abertura do menu de pausa.
- Um único botão centralizado: Pausar durante a subida; Sair para o menu principal quando as letras estão pausadas. Para retomar a subida, use Esc ou Enter. Teclas mantidas não alternam repetidamente; Enter com foco na saída retoma os letreiros em vez de sair.
- Botões Explorar museu e Menu retirados dos créditos. FIM continua retornando ao menu quando sai da tela, depois de retomar se estiver pausado.
- Em Movimento reduzido, a leitura manual continua disponível; ao pausar as letras, setas e roda do mouse ficam bloqueadas até a retomada. Sair ao menu e abrir novamente os créditos limpa a pausa anterior.
- Regra de pausa durante a exploração permanece a mesma. Músicas e efeitos preservados. Guia de controles atualizado.

Validação nativa: 1.056 verificações específicas, nos dois modos, dois personagens, texto normal/ampliado e com/sem movimento reduzido. Cobertura de clique, Esc, Enter/Enter numérico, música avançando, galerias sem congelar, ausência de rota ao banco/modal, rolagem, retorno ao menu e limpeza de estado. Mais 439 verificações de interação, 47 de regressão e campanha com 48 restaurações, aprovadas.
Verificação das exportações: campanha de 48 restaurações aprovada no executável Windows. No Chrome, clique em Pausar, Enter para retomar, Esc para pausar e clique na saída para o menu aprovados, inclusive em 960×600, sem erros de console. Relatório work/v2/browser211-report.json. Total: 1.542 verificações automatizadas, além da campanha.

