# 🐶 Bora, Doguinho!
## Especificação de Produto e Arquitetura — MVP

**Plataforma:** iOS  
**Tecnologias:** Swift, SwiftUI, Firebase  
**Objetivo:** Aplicativo privado para interação entre duas pessoas através dos doguinhos.

---

# 1. Visão do produto

**Bora, Doguinho!** é um aplicativo para duas pessoas conectadas que permite enviar uma solicitação de interação utilizando um doguinho como mensageiro.

A principal experiência do aplicativo é:

> Uma pessoa toca em **“BORA DOGUINHO?”** → seu doguinho leva a solicitação até a outra pessoa → ela responde → o doguinho retorna com a resposta.

O aplicativo deve ter uma experiência:

- simples;
- visual;
- divertida;
- afetiva;
- rápida;
- centrada nos doguinhos.

O MVP não deve tentar transformar o aplicativo em uma rede social, chat ou plataforma de entretenimento.

---

# 2. Público e modelo de uso

O aplicativo será inicialmente utilizado por um casal.

Cada usuário possui:

- sua própria conta;
- seu próprio perfil;
- seus próprios doguinhos;
- uma única conexão com outro usuário.

Um usuário não precisa conhecer o e-mail do outro para estabelecer conexão.

A conexão será realizada através do **ID único do usuário**.

---

# 3. Stack tecnológica

## Aplicativo

- Swift
- SwiftUI
- Xcode

## Backend

Firebase:

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging

## Notificações

- Firebase Cloud Messaging
- Apple Push Notification Service — APNs

## Distribuição futura

- App Store Connect
- TestFlight
- Apple Developer Program

---

# 4. Autenticação

Cada pessoa possui uma conta independente.

## Cadastro

Campos:

- nome;
- e-mail;
- senha;
- confirmação de senha.

Após o cadastro:

1. conta é criada;
2. usuário recebe automaticamente Harry e Pandora;
3. usuário entra no aplicativo;
4. usuário ainda não possui conexão.

## Login

Login através de:

- e-mail;
- senha.

## Recuperação de senha

Utilizar o mecanismo de recuperação de senha fornecido pelo Firebase Authentication.

## Login com Google

Pode ser adicionado futuramente.

Não é requisito obrigatório do MVP.

---

# 5. Usuário

Cada usuário possui:

```text
id
name
email
avatarURL
activePetId
petSelectionMode
connectedUserId
createdAt
```

### `petSelectionMode`

Valores:

```text
specific
random
```

Se `specific`, o aplicativo utiliza `activePetId`.

Se `random`, o aplicativo escolhe aleatoriamente um dos pets disponíveis do usuário.

---

# 6. Conexão

Cada usuário pode possuir **no máximo uma conexão ativa**.

## Conectar

Usuário informa:

> ID do usuário

E seleciona:

> **Enviar convite**

O destinatário recebe:

- push notification;
- notificação interna.

---

# 7. Convite de conexão

Modelo:

```text
ConnectionRequest
```

Campos:

```text
id
senderUserId
receiverUserId
status
createdAt
respondedAt
```

Estados:

```text
pending
accepted
declined
cancelled
```

---

# 8. Aceitar conexão

Ao aceitar:

1. convite é atualizado;
2. conexão entre os usuários é criada;
3. ambos passam a enxergar o outro como parceiro;
4. convites duplicados pendentes são encerrados.

Se o usuário tentar aceitar depois que a conexão já existe:

> **Vocês já estão conectados! ❤️**

---

# 9. Convites simultâneos

É permitido que os dois usuários enviem convites ao mesmo tempo.

Exemplo:

```text
Laura → Rennan
Rennan → Laura
```

Se Rennan aceitar primeiro:

```text
conexão criada
```

O segundo convite deixa de ser necessário e deve ser encerrado.

---

# 10. Desconectar

A desconexão exige confirmação.

Mensagem:

> **Tem certeza que deseja desconectar?**

> Vocês deixarão de poder enviar solicitações um para o outro.

Opções:

- Cancelar
- Desconectar

Após desconectar:

- `connectedUserId` deixa de existir;
- novos pedidos não podem ser enviados;
- a Home volta ao estado sem conexão.

---

# 11. Pets

Todo usuário começa automaticamente com:

- Harry;
- Pandora.

Cada conta possui sua própria coleção de pets.

O Harry de um usuário não representa o Harry de outro usuário como uma mesma entidade de propriedade.

---

# 12. Catálogo de pets

Os pets terão um catálogo global no Firestore.

Exemplo:

```text
pets/
    harry
    pandora
```

Documento:

```text
id
name
imageURL
createdAt
```

O usuário possui referências aos pets disponíveis para sua conta.

Isso permite futuramente adicionar:

- novos doguinhos;
- novos personagens;
- novos modelos visuais.

---

# 13. Imagens dos pets

As imagens serão armazenadas no:

**Firebase Storage**

O Firestore armazenará a referência/URL da imagem.

Motivo:

- permite atualizar imagens sem necessariamente atualizar o aplicativo;
- facilita adicionar novos pets;
- separa dados de arquivos;
- prepara o sistema para futuras expansões.

---

# 14. Seleção do doguinho

Tela **Pets** mostra os pets disponíveis.

O usuário pode:

- escolher Harry;
- escolher Pandora;
- escolher Aleatório.

O pet escolhido será utilizado no próximo pedido.

---

# 15. Home

A Home é a principal tela do aplicativo.

Ela deve seguir o layout visual definido pela Laura.

Elementos principais:

### Cabeçalho

- avatar/nome do usuário;
- avatar/nome do parceiro;
- botão de menu ☰.

Os avatares são carregados dinamicamente dos perfis.

Não devem ser imagens fixas incorporadas no aplicativo.

---

# 16. Indicador semanal

A Home apresenta:

```text
D  S  T  Q  Q  S  S
●  ●  ○  ○  ○  ○  ○
```

Esse indicador representa a **interação do casal durante a semana**.

Não representa simplesmente abertura do aplicativo.

---

# 17. O que conta como interação

No MVP, uma interação válida ocorre quando existe uma ação significativa entre os usuários.

Contam:

- enviar um BORA DOGUINHO;
- responder um BORA DOGUINHO;
- aceitar uma conexão.

Não conta:

- abrir o aplicativo;
- permanecer na Home;
- abrir configurações;
- visualizar o perfil.

---

# 18. Estado normal da Home

Quando o usuário está conectado e não possui solicitação ativa:

```text
Cabeçalho
      ↓
Indicador semanal
      ↓
Doguinho selecionado
      ↓
BORA DOGUINHO?
      ↓
Barra inferior
```

O botão principal inicia o fluxo do pedido.

---

# 19. Home sem conexão

Se não houver conexão:

> 🔗 **Conecte-se ao seu parceiro para começar.**

O usuário pode acessar diretamente a tela de conexão.

O botão **BORA DOGUINHO?** não deve criar uma solicitação.

---

# 20. Home durante envio

Depois que o usuário envia uma solicitação:

> 🐶 **Estou levando sua solicitação!**

O doguinho fica ocupado.

Não é possível iniciar outro pedido simultaneamente.

---

# 21. Home após retorno

Quando o pedido termina:

> 🐶 **Voltei! ❤️**

O doguinho volta a ficar disponível.

---

# 22. Solicitação recebida

Quando o usuário recebe um pedido, aparece uma modal sobre a Home.

A modal apresenta:

- doguinho do remetente;
- pergunta:

> **BORA DOGUINHO?**

Opções:

### ❤️ Sim!

### ⏰ Daqui a 15 minutos

### ❌ Agora não posso

A modal não deve permitir que o usuário simplesmente ignore o pedido através de um fechamento comum.

O pedido continuará pendente até:

- ser respondido;
- ou expirar.

---

# 23. Solicitação

A entidade será:

```text
DoguinhoRequest
```

Campos:

```text
id
senderUserId
receiverUserId
senderPetId
status
createdAt
answeredAt
```

---

# 24. Estados da solicitação

Estados oficiais:

```text
pending
accepted
delayed
declined
expired
```

### `pending`

Aguardando resposta.

### `accepted`

Usuário respondeu "Sim!".

### `delayed`

Usuário respondeu "Daqui a 15 minutos".

### `declined`

Usuário respondeu "Agora não posso".

### `expired`

14 minutos passaram sem resposta.

---

# 25. Prazo da solicitação

Cada solicitação permanece pendente durante:

**14 minutos.**

Depois disso:

```text
pending → expired
```

O remetente recebe:

> 🥺 **A mensagem não foi respondida. Tente solicitar novamente.**

---

# 26. Resposta "Sim"

Ao selecionar:

> ❤️ **Sim!**

O pedido é marcado como:

```text
accepted
```

O remetente recebe:

> ❤️ **Ela disse SIM!**

O doguinho retorna.

---

# 27. Resposta "Daqui a 15 minutos"

Ao selecionar:

> ⏰ **Daqui a 15 minutos**

O pedido é marcado como:

```text
delayed
```

O remetente recebe:

> ⏰ **Ela pediu para assistir daqui a 15 minutos.**

**Isso não agenda outro pedido.**

Nenhum novo pedido será criado automaticamente.

---

# 28. Resposta negativa

Ao selecionar:

> ❌ **Agora não posso**

O pedido é marcado como:

```text
declined
```

O remetente recebe:

> 😢 **Ela não pode agora.**

---

# 29. Pedido duplicado

Não é permitido possuir múltiplos pedidos simultâneos entre o mesmo casal.

Se já existe um pedido pendente:

> 🐶 **Seu doguinho já está a caminho!**

O usuário precisa esperar o pedido terminar.

---

# 30. Fechar o aplicativo durante um pedido

Fechar o aplicativo não cancela o pedido.

Exemplo:

Laura envia → Rennan fecha o aplicativo.

O pedido continua ativo.

Rennan pode receber a push notification e responder posteriormente.

Se os 14 minutos terminarem, o pedido expira normalmente.

---

# 31. Notificações

Existem dois sistemas complementares.

## Push

Notificação enviada pelo Firebase/APNs.

## Central interna

Histórico de notificações dentro do aplicativo.

---

# 32. Tipos de notificações

A central poderá conter:

- convite de conexão;
- conexão aceita;
- conexão recusada;
- BORA DOGUINHO recebido;
- pedido aceito;
- pedido recusado;
- pedido adiado;
- pedido expirado.

---

# 33. Navegação através da notificação

A notificação deve levar diretamente ao contexto relacionado.

Exemplo:

```text
Push do BORA
      ↓
Abrir aplicativo
      ↓
Home
      ↓
Modal do pedido
```

Não deve simplesmente abrir a Home sem contexto.

---

# 34. Som das notificações

Utilizar o som padrão de notificação do iOS.

Não haverá:

- som personalizado;
- Critical Alerts;
- comportamento de alerta emergencial.

O aplicativo não precisa e não deve tentar reproduzir o comportamento das notificações de Defesa Civil.

---

# 35. Menu lateral

O botão ☰ abre o menu.

Opções:

```text
👤 Meu Perfil

⚙️ Configurações

🔗 Conexão

🔔 Notificações

🚪 Sair
```

O menu não substitui a barra inferior.

---

# 36. Barra inferior

A navegação principal será:

```text
👕 Roupas
🏠 Home
🐾 Pets
🛍️ Loja
```

Home permanece como elemento central.

A tela selecionada deve possuir indicação visual clara.

Preferencialmente:

- cor;
- opacidade;
- tamanho;
- peso visual.

Não depender apenas do tamanho para indicar seleção.

Os ícones de navegação devem utilizar **SF Symbols** sempre que houver um símbolo apropriado.

---

# 37. Perfil

Tela **Meu Perfil**:

```text
Avatar

Nome

E-mail

ID

Meus doguinhos
- Harry
- Pandora
```

Não haverá estatísticas no MVP.

---

# 38. Configurações

A tela será propositalmente simples.

### Conta

- e-mail;
- ID.

### Sessão

- sair.

Novas configurações só devem ser adicionadas quando existir uma necessidade real.

---

# 39. Notificações internas

A tela terá uma lista cronológica.

Cada notificação poderá possuir:

```text
id
userId
type
title
message
relatedEntityId
isRead
createdAt
```

O usuário somente poderá acessar suas próprias notificações.

---

# 40. Roupas

A tela existe no MVP apenas como estrutura futura.

Conteúdo:

> 👕  
> **Roupinhas em breve!**

Não haverá:

- inventário;
- compras;
- moedas;
- customização funcional.

---

# 41. Loja

A tela também existe apenas como estrutura futura.

Conteúdo:

> 🛍️  
> **A lojinha está chegando!**

Futuramente poderá conter:

- roupas;
- acessórios;
- novos doguinhos;
- itens de personalização.

Não haverá pagamentos no MVP.

---

# 42. Atividade diária

Coleção:

```text
dailyActivity/
```

Possível estrutura:

```text
id
date
userIds
interactionType
createdAt
```

O objetivo é registrar os dias em que houve interação entre o casal.

O sistema não precisa registrar cada abertura do aplicativo.

---

# 43. Firebase — estrutura inicial

A estrutura principal será:

```text
users/
pets/
connections/
connectionRequests/
doguinhoRequests/
notifications/
dailyActivity/
```

---

# 44. Conexões

Uma conexão representa o relacionamento atual entre dois usuários.

Exemplo:

```text
connections/{connectionId}

userIds
status
createdAt
```

O estado esperado do MVP é:

```text
active
```

---

# 45. Regras de segurança

As Security Rules deverão garantir, entre outras coisas:

### Usuário

Um usuário pode modificar somente seus próprios dados.

### Pets

Usuário só pode acessar pets que pertencem à sua conta.

### Conexões

Usuário não pode criar arbitrariamente uma conexão com qualquer pessoa.

### Solicitações

Uma solicitação somente pode ser criada entre usuários conectados.

### Resposta

Somente o destinatário pode responder uma solicitação.

### Notificações

Usuário somente acessa suas próprias notificações.

### Atividade

Usuário não pode manipular arbitrariamente o histórico de atividade.

---

# 46. Firebase Storage

Estrutura conceitual:

```text
pets/
    harry/
    pandora/

users/
    {userId}/
        avatar
```

No futuro:

```text
pets/
    ...
clothes/
    ...
shop/
    ...
```

---

# 47. Arquitetura SwiftUI

Estrutura inicial:

```text
BoraDoguinho/
│
├── App/
│   └── BoraDoguinhoApp.swift
│
├── Models/
│   ├── User.swift
│   ├── Pet.swift
│   ├── Connection.swift
│   ├── ConnectionRequest.swift
│   ├── DoguinhoRequest.swift
│   ├── AppNotification.swift
│   └── DailyActivity.swift
│
├── Views/
│   ├── Auth/
│   ├── Home/
│   ├── Pets/
│   ├── Profile/
│   ├── Settings/
│   ├── Connection/
│   ├── Notifications/
│   ├── Clothes/
│   └── Shop/
│
├── Components/
│   ├── AppHeader/
│   ├── ProfileAvatar/
│   ├── WeekActivityIndicator/
│   ├── DoguinhoButton/
│   ├── DoguinhoRequestModal/
│   └── BottomNavigation/
│
├── Services/
│   ├── AuthService.swift
│   ├── UserService.swift
│   ├── PetService.swift
│   ├── ConnectionService.swift
│   ├── DoguinhoRequestService.swift
│   └── NotificationService.swift
│
└── Resources/
```

Essa estrutura poderá ser ajustada durante a implementação se surgir uma necessidade técnica real.

---

# 48. Princípio arquitetural

A interface não deve conversar diretamente com o Firebase em todos os lugares.

A responsabilidade será separada.

Exemplo:

```text
HomeView
    ↓
DoguinhoRequestService
    ↓
Firebase
```

Em vez de:

```text
HomeView
    ↓
Firestore
    ↓
Storage
    ↓
FCM
```

Isso mantém o projeto mais organizado e facilita testes e manutenção.

---

# 49. Estados de carregamento

Operações que dependem da rede devem possuir estado de carregamento.

Exemplo:

```text
Enviando...
```

O usuário não deve conseguir tocar repetidamente em um botão e gerar múltiplas operações.

---

# 50. Erros

Erros técnicos não devem ser apresentados diretamente ao usuário.

Não mostrar:

> FirebaseError: permission-denied

Mostrar:

> Não foi possível concluir essa ação. Tente novamente.

Quando houver uma solução clara:

> Verifique sua conexão com a internet e tente novamente.

Os detalhes técnicos devem ficar disponíveis para logs/desenvolvimento.

---

# 51. MVP — incluído

```text
✅ Cadastro
✅ Login
✅ Recuperação de senha
✅ Perfil
✅ ID do usuário
✅ Conexão
✅ Convites
✅ Harry
✅ Pandora
✅ Seleção de pet
✅ Aleatório
✅ Home
✅ BORA DOGUINHO
✅ Solicitação
✅ Resposta
✅ Expiração de 14 minutos
✅ Push notification
✅ Central de notificações
✅ Indicador semanal
✅ Menu lateral
✅ Configurações básicas
✅ Roupas — placeholder
✅ Loja — placeholder
✅ Firebase
✅ Security Rules
```

---

# 52. Fora do MVP

```text
❌ Animações dos doguinhos
❌ Roupas funcionais
❌ Loja funcional
❌ Moedas
❌ Economia interna
❌ Pagamentos
❌ Compras
❌ Novos pets compráveis
❌ Estatísticas
❌ Chat
❌ Feed
❌ Vídeos
❌ IA
❌ Agendamento automático
❌ Sons personalizados
❌ Critical Alerts
```

---

# 53. Ordem de implementação

A implementação deverá acontecer incrementalmente.

## Fase 1 — Fundação visual

- estrutura do projeto;
- navegação;
- Home;
- componentes;
- estados visuais;
- barra inferior;
- menu.

**Critério:** aplicativo navegável e Home funcionando visualmente.

---

## Fase 2 — Autenticação

- Firebase;
- cadastro;
- login;
- logout;
- recuperação de senha;
- sessão.

**Critério:** dois usuários conseguem criar contas e entrar no aplicativo.

---

## Fase 3 — Pets

- Firestore;
- Storage;
- Harry;
- Pandora;
- seleção;
- aleatório.

**Critério:** usuário consegue escolher o doguinho que utilizará.

---

## Fase 4 — Conexão

- busca por ID;
- convite;
- aceitar;
- recusar;
- conexão;
- desconexão.

**Critério:** dois usuários conseguem estabelecer e encerrar uma conexão real.

---

## Fase 5 — BORA DOGUINHO

- criação de pedido;
- seleção do pet;
- estados;
- modal;
- respostas;
- retorno;
- expiração.

**Critério:** todo o fluxo funciona entre dois dispositivos.

---

## Fase 6 — Push Notifications

- FCM;
- APNs;
- token;
- permissões;
- envio;
- abertura contextual.

**Critério:** uma ação em um iPhone gera a notificação correta no outro.

---

## Fase 7 — Notificações e atividade

- central;
- não lidas;
- indicador semanal;
- registro de interação.

**Critério:** o histórico e o indicador refletem corretamente as interações.

---

## Fase 8 — Acabamento

- Perfil;
- Configurações;
- Roupas;
- Loja;
- tratamento de erros;
- loading;
- acessibilidade;
- testes;
- revisão visual.

**Critério:** MVP pronto para testes completos.

---

# 54. Regra para o agente de código

O Codex/Antigravity **não deve inventar funcionalidades ou alterar regras de negócio sem justificativa**.

Quando encontrar uma decisão técnica não especificada:

1. deve escolher a solução mais simples e adequada à arquitetura;
2. deve preservar as regras deste documento;
3. não deve adicionar funcionalidades fora do MVP;
4. deve registrar decisões técnicas relevantes;
5. deve evitar alterar a experiência definida da Home.

Quando uma decisão afetar diretamente o comportamento do produto, deve sinalizar a decisão antes de implementá-la.

---

# 55. Critério geral de qualidade

O aplicativo deve ser:

- simples de utilizar;
- consistente;
- seguro;
- responsivo;
- preparado para expansão;
- visualmente fiel à proposta original;
- adequado para dois dispositivos reais;
- fácil de manter.

A prioridade é:

**experiência correta > arquitetura excessivamente complexa.**

Não devemos criar complexidade apenas para parecer um projeto profissional.

---

# 56. Visão futura

Depois do MVP, o aplicativo poderá evoluir para:

```text
🐶 Novos doguinhos
👕 Roupas
🎨 Personalização
🛍️ Loja
🪙 Moedas
🎁 Recompensas
🔥 Sequência de interação
📊 Estatísticas
🎞️ Animações
🔔 Novos tipos de interação
```

Essas funcionalidades não devem influenciar negativamente a simplicidade do MVP.

---

# 57. Experiência principal do produto

No fim, tudo gira em torno deste fluxo:

```text
        🏠 HOME
           │
           ▼
    Escolher doguinho
           │
           ▼
   BORA DOGUINHO? ❤️
           │
           ▼
       🐶 VAI!
           │
           ▼
     📱 NOTIFICAÇÃO
           │
           ▼
      🐶 CHEGOU!
           │
       ┌───┼────┐
       ▼   ▼    ▼
      ❤️  ⏰   ❌
       │   │    │
       └───┼────┘
           ▼
       🐶 VOLTA
           │
           ▼
       ❤️ INTERAÇÃO
           │
           ▼
     📅 SEMANA ATUALIZA
```

**Essa é a essência do Bora, Doguinho!**