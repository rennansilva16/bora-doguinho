# Instruções para agentes — Bora, Doguinho!

Estas instruções valem para qualquer agente que trabalhe neste repositório.

## Leitura obrigatória antes de alterar código

1. `bora-doguinho/docs/PROJECT_CONTEXT.md`
2. `bora-doguinho/docs/ARCHITECTURE.md`
3. `bora-doguinho/docs/HANDOFF.md`
4. `bora-doguinho/docs/roadmap.md`
5. `bora-doguinho/docs/etapas/fase-XX.md` da fase atual, quando existir.
6. Os arquivos de código diretamente envolvidos na tarefa.

As regras de produto existentes em `bora-doguinho/docs/especificacao.md` e o
plano detalhado em `bora-doguinho/docs/fases.md` também são fontes de verdade.
Não invente regras de negócio nem altere decisões documentadas sem autorização
explícita do responsável pelo projeto.

## Processo de desenvolvimento

- Trabalhe em uma subetapa pequena por vez, na ordem do roadmap.
- Primeiro examine o estado real do código; não presuma que a documentação está
  atualizada nem substitua uma implementação existente sem necessidade.
- Explique brevemente a mudança proposta, por que ela é necessária e como será
  testada antes de avançar para a próxima subetapa.
- Não implemente funcionalidades de fases futuras.
- Preserve o comportamento que já funciona.
- Compile e valide de forma proporcional ao risco depois de cada alteração.
- Não marque um item como concluído apenas porque o código existe: registre
  separadamente implementação, compilação e testes manuais.
- Não faça commit, push, publicação de regras Firebase ou outra alteração
  externa sem autorização explícita do responsável pelo projeto.

## Desenvolvimento acompanhado

O responsável pelo projeto está aprendendo Swift e SwiftUI durante a
implementação. Trabalhe em passos pequenos e na ordem das issues/subissues da
fase atual quando elas existirem.

Antes de cada alteração de código, explique de forma breve:

1. o objetivo imediato;
2. quais arquivos serão envolvidos e por quê;
3. o que o código novo ou alterado fará;
4. como a subetapa será validada.

Depois de implementar, explique o resultado em linguagem acessível, registre a
validação e aguarde o retorno do responsável antes de avançar para a próxima
subetapa, salvo autorização explícita para prosseguir.

## Documentação de continuidade

- `roadmap.md` registra o progresso geral do MVP.
- `HANDOFF.md` registra o estado técnico atual e o próximo passo concreto.
- `PROJECT_CONTEXT.md` e `ARCHITECTURE.md` descrevem contexto estável do
  produto e do código.
- Cada fase pode ter um histórico em `docs/etapas/fase-XX.md`, contendo plano,
  andamento, decisões, validações e pendências.
- Ao encerrar uma subetapa relevante, atualize a documentação aplicável antes
  de considerar o trabalho concluído.
- Não apague arquivos de fases concluídas: eles são histórico do projeto.
