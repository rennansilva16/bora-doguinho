# Validação das Fases 1 e 2

Este registro separa implementação de evidência de teste manual. Uma etapa não
é considerada concluída no roadmap se ainda houver validação declarada pendente.

## Fase 1 — Fundação e Home

### Concluído em código e compilação

- Estrutura SwiftUI organizada em `Views`, `Components`, `Models` e `Services`.
- Tab bar com Home, Pets, Roupas e Loja; menu lateral com as quatro rotas
  auxiliares e saída da sessão.
- Home com menu, avatares mockados, nomes, cadeado, indicador semanal, doguinho
  local e botão principal.
- Estados visuais locais: sem conexão, disponível, levando solicitação,
  retornando, pedido recebido e expirado.
- Modal visual não dispensável com as três respostas previstas.
- Placeholders de Roupas e Loja sem compras, moedas ou inventário.
- Compilação para simulador validada.

### Deliberadamente pendente para fases posteriores

- Dados reais de parceiro, atividade semanal, pets e conexão.
- Criação, recebimento e resposta persistentes de pedidos BORA DOGUINHO.
- Perfil, configurações, conexão e central de notificações reais.

### Evidência manual ainda pendente

- Execução e interação da Fase 1 em iPhone físico.

## Fase 2 — Firebase e autenticação

### Confirmado manualmente pelo responsável pelo projeto

- Firebase configurado com `GoogleService-Info.plist` no target.
- Authentication por e-mail/senha, cadastro, login, logout e persistência de
  sessão.
- Criação de `users/{uid}` e de `pets/harry` e `pets/pandora` no cadastro.
- Regras restritivas do Firestore publicadas.
- Aplicativo executado no simulador.

### Confirmado por revisão de código

- UID é fornecido pelo Firebase Authentication, sem entrada manual.
- Documento de usuário contém `id`, `name`, `email`, `avatarURL`,
  `activePetId`, `petSelectionMode`, `connectedUserId` e `createdAt`.
- Criação do perfil e dos pets usa batch do Firestore.
- Não há credenciais administrativas, service account ou mocks Firebase no app.
- Erros da autenticação/Firestore chegam à interface por alerta.

### Evidência manual ainda pendente

- Confirmação do recebimento e uso do e-mail de recuperação de senha.
- Cenário completo com duas contas independentes, incluindo isolamento mútuo.
