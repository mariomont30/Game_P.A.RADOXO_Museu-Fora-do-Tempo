# Atualização 2.18 | Correções da auditoria

A auditoria da versão 2.17 encontrou quatro problemas reproduzíveis. Esta atualização corrige os quatro, preservando as regras, o banco e os salvamentos.

| Achado | Correção |
| --- | --- |
| F01. Texto da pausa ultrapassava o card no celular com texto ampliado. | Rodapé em duas linhas e espaço adequado dentro do painel. |
| F02. Nomes válidos com até 20 emojis empurravam Excluir para fora da lista de jornadas. | Botão Excluir com largura reservada. Só o nome exibido é abreviado quando necessário, preservando modo e progresso. Nome completo e salvamento permanecem intactos. |
| F03. As setas não navegavam entre os botões dos créditos pausados no layout móvel. | Setas alternam o foco. Espaço ativa a opção. Enter e Esc continuam pausando e retomando apenas as letras. |
| F04. Falhas definitivas no download escondiam a entrada sem oferecer recuperação. | Aviso em português e Tentar novamente. A nova página cria outra instância do motor, preserva IndexedDB e não inicia motores duplicados. Também cobre falhas no WASM e nos scripts externos. |

## Verificação realizada

- 564 verificações específicas de layout, nomes, salvamento e créditos, sem falhas. Execução sem interface e com renderização e capturas.
- 668 verificações funcionais independentes, sem falhas: exploração, banco, pausa, cronômetro, sobreposições, restauração, prática, exclusão e recuperação por backup.
- 2.028 verificações de GAME OVER em 96 combinações.
- 2.296 verificações de transições em 128 combinações.
- 250.932 verificações do banco e sorteio, incluindo 45.000 sorteios e 100.000 posições de alternativas.
- Validação matemática das 4.200 perguntas e 8.160 igualdades das soluções.
- 48 missões no projeto e no executável Windows exportado. As 564 verificações específicas também passaram no PCK exportado.
- Chrome com exportação Web local: cinco falhas simuladas, cobrindo PCK em computador e celular, WASM e dois scripts. Todas mostraram recuperação acessível e retomaram o motor depois de Tentar novamente, preservando os dados do IndexedDB. Ativações repetidas iniciaram somente um motor.
- Jornadas reais na Web, Normal com toque e Difícil com mouse: recuperação preservou nome, questão, ordem das alternativas, vidas e demais dados do perfil. Primeira derrota, tentativa extra após reabrir e exclusão persistida na segunda derrota passaram sem erros de JavaScript ou Godot.
- Conferência visual da pausa ampliada, lista com nomes longos, créditos com foco por teclado e mensagem de falha móvel.

Os testes Godot abrangem ambos os personagens, os dois modos e as três galerias. Os ensaios móveis usam layout e toque emulados no Chrome, sem certificação em aparelhos Android ou iOS físicos. Não foi possível validar Edge, Safari e Firefox neste ambiente. Os resultados descrevem o que foi testado, sem garantir ausência de qualquer defeito em todos os dispositivos.

## Preservação

Os 20 WAVs, o banco atual e o legado, e o PNG do QR code permanecem idênticos à versão 2.17. O endereço público não muda. O formato do salvamento não mudou. A correção abrevia nomes apenas na lista e não apaga ou migra jornadas pessoais. Não há sincronização entre dispositivos.

Os testes reproduzíveis estão em `tests/audit_fixes.gd`, `tests/functional_regression.gd` e `tests/web_recovery.mjs`. Consulte [Desenvolvimento](../DESENVOLVIMENTO.md) para executar as suítes e preparar a Web comprimida.
