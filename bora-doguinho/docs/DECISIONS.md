# Decisões Registradas

## Documentação de continuidade

**Decisão:** manter a continuidade do projeto dentro do repositório.

- `roadmap.md` registra o progresso macro.
- `HANDOFF.md` registra o estado atual e o próximo passo.
- `PROJECT_CONTEXT.md` e `ARCHITECTURE.md` registram informações estáveis.
- `docs/etapas/fase-XX.md` preserva o planejamento, andamento, decisões,
  validações e pendências de cada fase.

Os arquivos de fases concluídas não devem ser apagados ou substituídos; cada
novo ciclo cria o seu próprio arquivo. O `HANDOFF.md` é atualizado a cada
transição de fase.

## Pets locais

**Decisão:** Harry, Pandora e Merlim são assets locais do app, e não arquivos
Firebase Storage.

## Fase 5 sem push

**Decisão:** a Fase 5 usa Firestore para o fluxo de pedidos. Push notifications
ficam para fase posterior.
