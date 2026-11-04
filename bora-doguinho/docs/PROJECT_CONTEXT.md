# Contexto do Projeto — Bora, Doguinho!

## Produto

**Bora, Doguinho!** é um aplicativo iOS privado para duas pessoas conectadas.
O fluxo principal permite que uma pessoa envie ao parceiro um convite por meio
do pet selecionado. O destinatário pode responder **Sim**, **Daqui a 15
minutos** ou **Agora não posso**.

O aplicativo não é uma rede social, chat ou agenda. A resposta “Daqui a 15
minutos” apenas encerra o pedido com esse resultado; ela não agenda uma nova
ação automaticamente.

## Tecnologias e ambiente

- Swift e SwiftUI.
- Firebase Authentication com e-mail e senha.
- Cloud Firestore na região `southamerica-east1`.
- Plano Firebase Spark.
- O projeto Firebase usa o bundle identifier `mais1app.bora-doguinho`.

Nunca incluir service account, chave privada ou credencial administrativa no
aplicativo.

## Pets

Harry, Pandora e Merlim são assets locais do aplicativo. Eles **não** ficam no
Firebase Storage. Cada usuário recebe referências aos pets na subcoleção
`users/{uid}/pets`.

## Regras estáveis do produto

- Cada pessoa possui uma conta e, no MVP, no máximo uma conexão ativa.
- A conexão ocorre pelo ID do usuário, não pelo e-mail.
- O pet escolhido no envio deve permanecer registrado no pedido, mesmo se a
  seleção do usuário mudar depois.
- Um pedido pendente expira após 15 minutos e fechar o aplicativo não reinicia
  esse prazo.
- Estados finais de um pedido não podem ser alterados novamente.
- Notificações push pertencem a uma fase posterior; não devem ser adicionadas
  à Fase 5.
- Não adicionar infraestrutura que gere custos sem explicar e obter aprovação.

## Documentação

Antes de começar qualquer tarefa, siga `../../AGENTS.md` e leia os documentos
de continuidade indicados nele. O roadmap registra o progresso geral; os
arquivos em `docs/etapas/` preservam o planejamento e o histórico de cada
fase; `HANDOFF.md` registra o ponto atual do desenvolvimento.
