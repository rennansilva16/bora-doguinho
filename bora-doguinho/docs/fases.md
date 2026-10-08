# 🐶 Bora, Doguinho! — Plano de Implementação

## Regras de execução

1. Cada subfase deve possuir um objetivo pequeno e bem definido.
2. O agente deve implementar somente a subfase solicitada.
3. Após cada subfase, o projeto deve ser compilado e testado.
4. Subfases relevantes devem gerar um commit.
5. Não avançar enquanto houver problemas relevantes na subfase atual.
6. Se a IA atingir o limite de uso, continuar manualmente quando a tarefa for simples ou aguardar outro agente para tarefas complexas.
7. Codex, Antigravity e, futuramente, Claude Code podem ser utilizados de forma intercambiável.
8. Nenhum agente deve alterar as regras de produto da `especificacao.md`.
9. Não antecipar funcionalidades de fases futuras.
10. Se surgir uma decisão de produto não definida, parar e consultar antes de implementar.

---

# FASE 1 — Fundação e Home

### 1.1 — Organização inicial

- revisar o projeto SwiftUI existente;
- organizar pastas;
- criar estrutura inicial;
- remover código de teste desnecessário;
- manter o projeto compilando.

**Commit sugerido:**

```text
chore: organize project structure
```

### 1.2 — Navegação principal

Implementar:

- Home;
- Pets;
- Roupas;
- Loja;
- Tab Bar;
- SF Symbols.

**Commit:**

```text
feat: add main navigation
```

### 1.3 — Menu lateral

Implementar:

- hamburger;
- Meu Perfil;
- Configurações;
- Conexão;
- Notificações;
- Sair como placeholder.

**Commit:**

```text
feat: add side menu navigation
```

### 1.4 — Estrutura visual da Home

Implementar:

- cabeçalho;
- avatares;
- nomes;
- indicador semanal;
- doguinho;
- botão "BORA DOGUINHO?";
- navegação inferior.

Usar dados mockados.

**Commit:**

```text
feat: build home screen
```

### 1.5 — Estados visuais da Home

Implementar visualmente:

- sem conexão;
- conectado;
- doguinho disponível;
- doguinho levando solicitação;
- doguinho retornando;
- pedido recebido;
- pedido expirado.

Ainda sem Firebase.

**Commit:**

```text
feat: add home states
```

### 1.6 — Modal do BORA DOGUINHO

Criar a modal com:

- ❤️ Sim!
- ⏰ Daqui a 15 minutos
- ❌ Agora não posso

Usar dados mockados.

**Commit:**

```text
feat: add doguinho request modal
```

### 1.7 — Revisão da Fase 1

Testar:

- navegação;
- Home;
- menu;
- modal;
- estados;
- simulador;
- iPhone.

**Ponto de parada obrigatório.**

---

# FASE 2 — Firebase e Autenticação

### 2.1 — Configuração do Firebase

- adicionar Firebase;
- configurar projeto;
- conectar aplicativo ao Firebase.

**Commit:**

```text
chore: configure firebase
```

### 2.2 — Modelo de usuário

Criar:

- `User`;
- `UserService`;
- estrutura Firestore.

**Commit:**

```text
feat: add user model and service
```

### 2.3 — Cadastro

Implementar:

- nome;
- e-mail;
- senha;
- confirmação;
- criação da conta;
- documento do usuário.

**Commit:**

```text
feat: implement user registration
```

### 2.4 — Login e sessão

Implementar:

- login;
- persistência;
- logout;
- redirecionamento.

**Commit:**

```text
feat: implement authentication flow
```

### 2.5 — Recuperação de senha

**Commit:**

```text
feat: add password recovery
```

### 2.6 — Teste da autenticação

Testar duas contas reais:

- cadastro;
- login;
- logout;
- recuperação;
- persistência da sessão.

---

# FASE 3 — Pets

### 3.1 — Catálogo

Criar catálogo no Firestore:

```text
pets/
├── harry
└── pandora
|__ marlim
```

### 3.2 — Assets dos pets

Implementar:

- imagens dos pets em Assets.xcassets;
- associação entre pet e asset através de imageName;
- carregamento local das imagens.

### 3.3 — Pets do usuário

Ao criar a conta:

```text
Harry
Pandora
Merlim
```

devem ser disponibilizados automaticamente.

### 3.4 — Tela Pets

Implementar:

- lista;
- imagens;
- nomes;
- seleção;
- indicação do pet ativo.

### 3.5 — Aleatório

Implementar modo `random`.

### 3.6 — Integração com Home

O doguinho mostrado na Home deve refletir a seleção.

### 3.7 — Teste

Verificar:

- Harry;
- Pandora;
- Merlim
- aleatório;
- persistência;
- imagens.

---

# FASE 4 — Conexão

### 4.1 — Modelo `Connection`

Criar estrutura da conexão.

### 4.2 — `ConnectionRequest`

Criar o modelo de convite.

### 4.3 — Busca por ID

Permitir localizar outro usuário através do ID.

### 4.4 — Envio de convite

Implementar criação do convite.

### 4.5 — Recebimento

Mostrar convite recebido.

### 4.6 — Aceitar

Criar conexão real.

### 4.7 — Recusar

Encerrar convite.

### 4.8 — Convites simultâneos

Tratar:

```text
A → B
B → A
```

sem criar duas conexões.

### 4.9 — Desconectar

Implementar confirmação e desconexão.

### 4.10 — Segurança

Implementar as regras necessárias para impedir manipulação arbitrária da conexão.

### 4.11 — Teste

Com duas contas:

```text
A → convite → B
B → aceita
A ↔ B conectados
A → desconecta
A ↔ B desconectados
```

**Ponto de parada obrigatório.**

---

# FASE 5 — BORA DOGUINHO

Essa será propositalmente a fase mais dividida.

### 5.1 — Modelo `DoguinhoRequest`

Criar:

```text
pending
accepted
delayed
declined
expired
```

### 5.2 — `DoguinhoRequestService`

Criar serviço responsável pelas operações.

### 5.3 — Criar pedido

Implementar:

**BORA DOGUINHO? → criar pedido**

Validar:

- usuário autenticado;
- conexão ativa;
- pet disponível;
- nenhum pedido pendente.

### 5.4 — Estado "levando"

Mostrar:

> Estou levando sua solicitação!

### 5.5 — Receber pedido

Detectar pedido pendente do parceiro.

### 5.6 — Modal real

Conectar a modal da Fase 1 ao Firestore.

### 5.7 — Resposta "Sim"

Implementar `accepted`.

### 5.8 — Resposta "Daqui a 15 minutos"

Implementar `delayed`.

**Não criar novo pedido.**

### 5.9 — Resposta "Agora não"

Implementar `declined`.

### 5.10 — Expiração

Implementar os 14 minutos:

```text
pending → expired
```

### 5.11 — Bloqueio de duplicidade

Impedir múltiplos pedidos pendentes simultâneos.

### 5.12 — Retorno

Depois do resultado:

> Voltei! ❤️

### 5.13 — Teste completo

Testar com dois dispositivos:

- Sim;
- 15 minutos;
- recusado;
- expiração;
- pedido duplicado;
- fechamento do aplicativo.

---

# FASE 6 — Push Notifications

### 6.1 — Permissão

Solicitar autorização para notificações.

### 6.2 — FCM/APNs

Configurar integração.

### 6.3 — Tokens

Registrar e armazenar o token do dispositivo.

### 6.4 — Push de conexão

Convite recebido.

### 6.5 — Push do BORA

Pedido recebido.

### 6.6 — Push de resposta

Resposta recebida.

### 6.7 — Push de expiração

Quando aplicável.

### 6.8 — Aplicativo aberto

Tratar notificações com app em foreground.

### 6.9 — Background

Tratar app em segundo plano.

### 6.10 — Aplicativo fechado

Tratar abertura pelo push.

### 6.11 — Navegação contextual

Exemplo:

```text
Push BORA
↓
abre aplicativo
↓
Home
↓
modal
```

### 6.12 — Teste em dois iPhones

Validar todo o fluxo.

---

# FASE 7 — Central de Notificações

### 7.1 — Modelo `Notification`

### 7.2 — Criar notificações internas

### 7.3 — Lista

### 7.4 — Marcar como lida

### 7.5 — Contador de não lidas

### 7.6 — Navegação contextual

### 7.7 — Teste

---

# FASE 8 — Indicador semanal

### 8.1 — Modelo `DailyActivity`

### 8.2 — Registrar interação

Interações válidas:

- enviar BORA;
- responder BORA;
- aceitar conexão.

### 8.3 — Marcar dia

### 8.4 — Integrar à Home

### 8.5 — Evitar duplicidade

Várias interações no mesmo dia continuam representando apenas **um dia ativo**.

### 8.6 — Testar mudança de semana

---

# FASE 9 — Perfil e Configurações

### 9.1 — Perfil

Mostrar:

- avatar;
- nome;
- e-mail;
- ID;
- pets.

### 9.2 — Configurações

Mostrar:

- e-mail;
- ID;
- sair.

### 9.3 — Revisão do menu

Garantir que toda a navegação esteja coerente.

---

# FASE 10 — Roupas e Loja

### 10.1 — Roupas

Apenas:

> 👕 Roupinhas em breve!

### 10.2 — Loja

Apenas:

> 🛍️ A lojinha está chegando!

**Não implementar sistema de compras, moedas ou inventário.**

---

# FASE 11 — Segurança e revisão técnica

### 11.1 — Firestore Rules

Revisar acesso aos usuários.

### 11.2 — Connection Rules

Verificar permissões da conexão.

### 11.3 — Request Rules

Verificar:

- criação;
- leitura;
- resposta;
- expiração.

### 11.4 — Storage Rules

Revisar acesso às imagens.

### 11.5 — Tokens e credenciais

Garantir que nenhuma credencial administrativa esteja no aplicativo.

### 11.6 — Revisão de código

Procurar:

- duplicação;
- código desnecessário;
- Views excessivamente grandes;
- Services mal definidos;
- estado global desnecessário;
- problemas de concorrência.

**Não adicionar funcionalidades nesta fase.**

---

# FASE 12 — Teste final do MVP

Esta fase é **exclusivamente de validação**.

### Autenticação

- [ ] cadastro
- [ ] login
- [ ] logout
- [ ] recuperação
- [ ] persistência

### Pets

- [ ] Harry
- [ ] Pandora
- [ ] Merlim
- [ ] seleção
- [ ] aleatório
- [ ] persistência

### Conexão

- [ ] convite
- [ ] recebimento
- [ ] aceite
- [ ] recusa
- [ ] simultâneo
- [ ] desconexão

### BORA DOGUINHO

- [ ] envio
- [ ] doguinho ocupado
- [ ] recebimento
- [ ] Sim
- [ ] 15 minutos
- [ ] recusa
- [ ] expiração
- [ ] duplicidade
- [ ] fechar aplicativo

### Push

- [ ] app aberto
- [ ] background
- [ ] app fechado
- [ ] abertura contextual

### Central

- [ ] lista
- [ ] não lidas
- [ ] lidas

### Home

- [ ] conectado
- [ ] sem conexão
- [ ] pedido pendente
- [ ] pedido recebido
- [ ] retorno

### Navegação

- [ ] Home
- [ ] Pets
- [ ] Roupas
- [ ] Loja
- [ ] Menu
- [ ] Perfil
- [ ] Configurações
- [ ] Conexão
- [ ] Notificações

### Segurança

- [ ] usuário não acessa dados indevidos
- [ ] pedido somente entre conectados
- [ ] somente destinatário responde

Ao terminar, registrar:

1. testes realizados;
2. problemas encontrados;
3. problemas corrigidos;
4. problemas pendentes.

**Compilar não é suficiente para considerar o MVP concluído.**

---

# 🧭 Visão geral

```text
FASE 1  → Fundação + Home
          ├─ 1.1 Organização
          ├─ 1.2 Navegação
          ├─ 1.3 Menu
          ├─ 1.4 Home
          ├─ 1.5 Estados
          ├─ 1.6 Modal
          └─ 1.7 Revisão

FASE 2  → Firebase + Autenticação
          ├─ 2.1 Firebase
          ├─ 2.2 Usuário
          ├─ 2.3 Cadastro
          ├─ 2.4 Login
          ├─ 2.5 Recuperação
          └─ 2.6 Teste

FASE 3  → Pets
          ├─ 3.1 Catálogo
          ├─ 3.2 Assets dos pets
          ├─ 3.3 Pets do usuário
          ├─ 3.4 Tela
          ├─ 3.5 Aleatório
          ├─ 3.6 Home
          └─ 3.7 Teste

FASE 4  → Conexão
          ├─ 4.1 Connection
          ├─ 4.2 Convite
          ├─ 4.3 Busca
          ├─ 4.4 Envio
          ├─ 4.5 Recebimento
          ├─ 4.6 Aceite
          ├─ 4.7 Recusa
          ├─ 4.8 Simultâneo
          ├─ 4.9 Desconexão
          ├─ 4.10 Segurança
          └─ 4.11 Teste

FASE 5  → BORA DOGUINHO
          ├─ 5.1 Modelo
          ├─ 5.2 Service
          ├─ 5.3 Criar pedido
          ├─ 5.4 Levando
          ├─ 5.5 Receber
          ├─ 5.6 Modal real
          ├─ 5.7 Sim
          ├─ 5.8 15 minutos
          ├─ 5.9 Recusa
          ├─ 5.10 Expiração
          ├─ 5.11 Duplicidade
          ├─ 5.12 Retorno
          └─ 5.13 Teste

FASE 6  → Push Notifications
          ├─ 6.1 Permissão
          ├─ 6.2 FCM/APNs
          ├─ 6.3 Tokens
          ├─ 6.4 Convite
          ├─ 6.5 BORA
          ├─ 6.6 Resposta
          ├─ 6.7 Expiração
          ├─ 6.8 Foreground
          ├─ 6.9 Background
          ├─ 6.10 App fechado
          ├─ 6.11 Contexto
          └─ 6.12 Teste

FASE 7  → Central de notificações

FASE 8  → Indicador semanal

FASE 9  → Perfil + Configurações

FASE 10 → Roupas + Loja

FASE 11 → Segurança + Revisão

FASE 12 → Teste final

             ↓

        🐶 MVP PRONTO
```
