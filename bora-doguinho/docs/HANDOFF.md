# Handoff — Estado Atual do Projeto

**Atualizado em:** 3 de novembro de 2026
**Branch atual esperada:** `feat/phase-5-bora-doguinho`
**Fase atual:** Fase 5 — BORA DOGUINHO

## O que já existe

- Autenticação Firebase por e-mail/senha, perfis Firestore e sessão persistida.
- Pets locais Harry, Pandora e Merlim, catálogo e seleção persistida.
- Conexão entre dois usuários e perfis públicos mínimos.
- Home que carrega pet ativo e parceiro conectado.
- Modelo `DoguinhoRequest` com status, criação, resposta e prazo de expiração.
- `DoguinhoRequestService` completo: criação transacional, observação do
  pedido enviado e recebido, resposta transacional e expiração persistida.
- Modal visual de pedido com as três respostas; ainda não conectado ao fluxo
  real do Firestore.

## Estado da Fase 5

O serviço está implementado e o projeto compila para iOS Simulator, mas ele
ainda não foi integrado ao botão **BORA DOGUINHO?** e não foi validado com duas
contas reais. Não tratar a Fase 5 como concluída apenas porque o projeto
compila.

As regras locais da Fase 5 foram publicadas e conferidas manualmente contra o
Firebase. A suíte de testes do Emulator Suite em
`scripts/test/firestore.rules.test.js` foi executada com sucesso em 3 de
novembro de 2026: os 10 cenários passaram, incluindo a transação que depende
de `getAfter()`.

Antes de alterar código desta fase:

1. Ler o planejamento da Fase 5 em `docs/etapas/fase-05.md` quando seu texto
   definitivo estiver registrado.
2. Examinar `DoguinhoRequest.swift`, `DoguinhoRequestService.swift`,
   `HomeView.swift`, `DoguinhoRequestModal.swift` e `firestore.rules`.
3. Confirmar que a operação proposta respeita as regras Firestore e o plano da
   fase antes de integrar qualquer mudança à interface.

## Issues da Fase 5 no GitHub

A issue-mãe é [#1 — Implementação funcionalidades principais do Bora Doguinho
Etapa 5](https://github.com/rennansilva16/bora-doguinho/issues/1). A subissue
[#2 — Modelo DoguinhoRequest](https://github.com/rennansilva16/bora-doguinho/issues/2)
está fechada; a subissue #3 também está fechada. As subissues #4 a #14
permanecem abertas no GitHub.

O acompanhamento local e a ordem de execução estão em
`docs/etapas/fase-05-acompanhamento.md`. A próxima subetapa é a Issue #4.

## Próximo objetivo pequeno

Conectar o botão da Home à criação real do pedido e mostrar o estado persistido
de envio, reutilizando `DoguinhoRequestService` sem alterar as regras Firebase.

## Pendências de validação da Fase 5

- Criação real de pedido entre duas contas conectadas.
- Atualização em tempo real nos dois aplicativos.
- Respostas, expiração, concorrência e recuperação após reabrir o app.
- Regras Firestore publicadas e testadas para pedidos.

## Fora de escopo nesta fase

- Push notifications, FCM e APNs.
- Chat.
- Agendamento automático para a resposta “Daqui a 15 minutos”.
- Cloud Functions ou infraestrutura adicional sem aprovação explícita.
