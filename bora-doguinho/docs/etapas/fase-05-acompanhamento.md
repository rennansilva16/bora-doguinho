# Fase 5 — Acompanhamento

Este arquivo acompanha a execução da Fase 5 sem substituir seu planejamento
em `fase-05.md`.

## Organização no GitHub

- Issue-mãe: [#1 — Implementação funcionalidades principais do Bora Doguinho Etapa 5](https://github.com/rennansilva16/bora-doguinho/issues/1)
- Subissues: #2 a #14

| Ordem | Issue | Situação no GitHub | Estado no projeto |
| --- | --- | --- | --- |
| 5.1 | [#2 — Modelo DoguinhoRequest](https://github.com/rennansilva16/bora-doguinho/issues/2) | Fechada | Modelo e estados existem em `Models/DoguinhoRequest.swift`. |
| 5.2 | [#3 — Criar DoguinhoRequestService](https://github.com/rennansilva16/bora-doguinho/issues/3) | Fechada | Criação transacional, observação de pedido enviado e recebido, resposta transacional e expiração persistida. Regras publicadas, 10 testes do Emulator aprovados e compilação iOS aprovada. |
| 5.3 | [#4 — Implementar criação do pedido](https://github.com/rennansilva16/bora-doguinho/issues/4) | Aberta | Não iniciada. |
| 5.4 | [#5 — Implementar estado "levando"](https://github.com/rennansilva16/bora-doguinho/issues/5) | Aberta | Não iniciada. |
| 5.5 | [#6 — Detectar pedidos recebidos](https://github.com/rennansilva16/bora-doguinho/issues/6) | Aberta | Não iniciada. |
| 5.6 | [#7 — Conectar a modal ao pedido real](https://github.com/rennansilva16/bora-doguinho/issues/7) | Aberta | Não iniciada. |
| 5.7 | [#8 — Implementar resposta "Sim!"](https://github.com/rennansilva16/bora-doguinho/issues/8) | Aberta | Não iniciada. |
| 5.8 | [#9 — Implementar resposta "Daqui a 15 minutos"](https://github.com/rennansilva16/bora-doguinho/issues/9) | Aberta | Não iniciada. |
| 5.9 | [#10 — Implementar resposta "Agora não posso"](https://github.com/rennansilva16/bora-doguinho/issues/10) | Aberta | Não iniciada. |
| 5.10 | [#11 — Implementar expiração após 15 minutos](https://github.com/rennansilva16/bora-doguinho/issues/11) | Aberta | Não iniciada. |
| 5.11 | [#12 — Impedir pedidos duplicados](https://github.com/rennansilva16/bora-doguinho/issues/12) | Aberta | Não iniciada. |
| 5.12 | [#13 — Implementar retorno do doguinho](https://github.com/rennansilva16/bora-doguinho/issues/13) | Aberta | Não iniciada. |
| 5.13 | [#14 — Testar o fluxo completo](https://github.com/rennansilva16/bora-doguinho/issues/14) | Aberta | Não iniciada. |

## Próximo passo

Trabalhar na Issue #4: integrar o botão **BORA DOGUINHO?** da Home ao método
de criação já existente e refletir o estado persistido do pedido enviado. Essa
integração será feita em passo separado; a interface ainda não consome os
listeners nem os métodos de resposta da Issue #3.

## Decisão confirmada

O prazo oficial para expiração de uma solicitação pendente é de **15 minutos**.
As referências locais divergentes foram corrigidas nesta atualização. As issues
do GitHub que ainda mencionam 14 minutos devem ser atualizadas em uma ação
separada, caso o responsável autorize essa alteração externa.

## Validação automatizada de regras

O arquivo `scripts/test/firestore.rules.test.js` cobre leitura pelos dois
participantes e por terceiro, resposta autorizada e não autorizada, bloqueio
de segunda resposta, expiração antes/depois do prazo e a criação atômica que
depende de `getAfter()`. Ele usa exclusivamente o projeto fictício local
`demo-bora-doguinho`.

Em 3 de novembro de 2026, os 10 testes foram executados pelo responsável e
todos passaram. Isso inclui a transação que cria o pedido e atualiza
`pendingDoguinhoRequestId` com `getAfter()`.

## Conclusão local da Issue #3

Em 3 de novembro de 2026, `DoguinhoRequestService` passou a concentrar a
camada de acesso do fluxo: cria um pedido de modo atômico, observa o pedido
enviado pelo campo `pendingDoguinhoRequestId`, observa pedidos pendentes
recebidos, responde de forma transacional e registra a expiração quando um
pedido vencido é consultado. Os listeners não entregam um pedido pendente já
vencido para a interface: solicitam primeiro a atualização para `expired` no
Firestore.

O projeto compilou com sucesso para iOS Simulator após a implementação. A
validação manual entre duas contas continua pendente e será realizada quando a
Home e a modal estiverem conectadas nas próximas issues.
