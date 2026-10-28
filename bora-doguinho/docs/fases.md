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

Esta é a principal funcionalidade do aplicativo e será propositalmente dividida em subfases pequenas.

Cada subfase deve implementar somente o comportamento descrito, mantendo o projeto compilável e preservando o que já funciona nas fases anteriores.

O objetivo final é permitir que dois usuários conectados troquem solicitações reais de BORA DOGUINHO, com atualização em tempo real, respostas, expiração e estados visuais sincronizados.

## Objetivo geral

Implementar o fluxo real do BORA DOGUINHO utilizando Firestore.

O usuário deve conseguir solicitar a presença do parceiro por meio do doguinho selecionado. O parceiro deve receber a solicitação, visualizar uma modal e responder. Os dois aplicativos devem refletir o resultado correto.

A implementação deve funcionar com duas contas reais e, ao final da fase, ser validada em dois dispositivos sempre que possível.

## Regras de produto obrigatórias

1. O BORA DOGUINHO só pode ser enviado por um usuário autenticado que possua uma conexão ativa.
2. Cada solicitação pertence a um remetente e a um destinatário específicos.
3. O doguinho utilizado na solicitação deve corresponder ao pet selecionado pelo remetente no momento do envio.
4. O remetente não pode ter mais de uma solicitação pendente simultaneamente.
5. O destinatário deve conseguir responder somente às solicitações recebidas que ainda estejam pendentes e válidas.
6. Uma solicitação aceita, recusada ou expirada não pode voltar ao estado pendente.
7. A resposta "Daqui a 15 minutos" não agenda uma nova solicitação nem cria um temporizador para enviar outra mensagem.
8. Uma solicitação pendente expira após 15 minutos, contados a partir da sua criação.
9. Fechar o aplicativo não cancela nem reinicia o prazo da solicitação.
10. A interface deve refletir o estado real armazenado no Firestore, e não apenas alterações locais temporárias.
11. Não confiar exclusivamente na interface para impedir ações inválidas. As operações devem validar o estado atual e respeitar as regras de segurança do Firestore.
12. Não alterar o funcionamento da autenticação, da conexão ou da seleção de pets implementado nas fases anteriores.

---

## 5.1 — Modelo `DoguinhoRequest`

Criar o modelo que representa uma solicitação de BORA DOGUINHO.

Cada documento deve representar uma única solicitação e conter, no mínimo:

- `id`: identificador único da solicitação;
- `senderUserId`: UID do usuário que enviou;
- `receiverUserId`: UID do usuário que recebeu;
- `senderPetId`: ID do doguinho utilizado pelo remetente;
- `status`: estado atual da solicitação;
- `createdAt`: data e hora de criação;
- `answeredAt`: data e hora da resposta, quando houver.

Se necessário para implementar corretamente a expiração, pode ser adicionado um campo como `expiresAt`, desde que sua finalidade e validação sejam documentadas.

### Estados permitidos

- `pending`: solicitação criada e aguardando resposta;
- `accepted`: o destinatário respondeu "Sim!";
- `delayed`: o destinatário respondeu "Daqui a 15 minutos";
- `declined`: o destinatário respondeu "Agora não posso";
- `expired`: o prazo de resposta terminou sem uma resposta válida.

### Regras de transição

```text
pending → accepted
pending → delayed
pending → declined
pending → expired
```

Não permitir outras transições de estado.

As transições devem ser validadas no serviço e protegidas pelas regras de segurança. Uma resposta não pode sobrescrever outra resposta que já tenha sido registrada.

**Commit sugerido:** `feat: add doguinho request model`

## 5.2 — `DoguinhoRequestService`

Criar um serviço responsável pelas operações de BORA DOGUINHO no Firestore.

O serviço deve concentrar a lógica de:

- criar solicitações;
- observar solicitações pendentes recebidas;
- observar o estado da solicitação enviada;
- registrar respostas;
- validar o estado antes de responder;
- verificar a expiração;
- impedir solicitações duplicadas;
- atualizar o estado quando o prazo terminar.

A interface não deve manipular diretamente os documentos do Firestore para implementar regras de negócio.

Reutilizar os modelos, serviços e a sessão de autenticação existentes. Não criar uma segunda estrutura de usuários ou conexões.

As operações devem tratar erros de rede, falta de permissão, conexão inexistente e solicitações que deixaram de ser válidas.

## 5.3 — Criar pedido

Implementar o fluxo acionado pelo botão **"BORA DOGUINHO?"** na Home.

Ao tocar no botão, validar:

1. o usuário está autenticado;
2. existe uma conexão ativa;
3. o usuário conectado corresponde ao destinatário;
4. o remetente possui um doguinho selecionado e disponível;
5. não existe outra solicitação pendente enviada pelo mesmo usuário;
6. a conexão continua válida no momento da operação.

Se todas as validações forem atendidas:

- criar um documento `DoguinhoRequest`;
- preencher remetente, destinatário, pet, estado e data de criação;
- registrar o prazo de expiração;
- atualizar a interface para o estado de solicitação em andamento.

O pet enviado deve ser definido no momento da criação. Uma alteração posterior da seleção de pet não deve modificar uma solicitação já criada.

Durante o envio, mostrar um estado de carregamento e impedir toques repetidos que possam gerar solicitações duplicadas.

Se ocorrer um erro, informar que não foi possível enviar a solicitação e permitir uma nova tentativa quando apropriado.

Não considerar o envio concluído até que o Firestore confirme a operação.

**Commit sugerido:** `feat: create doguinho requests`

## 5.4 — Estado "levando"

Depois que o pedido for criado com sucesso, a Home do remetente deve refletir que o doguinho está levando a solicitação.

Exibir a mensagem:

> Estou levando sua solicitação!

A Home deve continuar mostrando o pet associado à solicitação enviada, mesmo que o usuário altere a seleção de pet enquanto o pedido estiver em andamento.

O estado deve ser derivado da solicitação real no Firestore.

Não utilizar apenas uma variável local para manter o doguinho nesse estado, pois a interface precisa se recuperar corretamente após fechar e reabrir o aplicativo.

Quando a solicitação receber uma resposta ou expirar, a Home deverá reagir ao novo estado.

## 5.5 — Receber pedido

O aplicativo do destinatário deve observar as solicitações recebidas que estejam pendentes e sejam destinadas ao usuário autenticado.

Quando uma nova solicitação válida for criada:

- identificar o remetente;
- identificar o pet utilizado;
- atualizar a Home do destinatário;
- preparar a exibição da modal de resposta.

A solicitação recebida deve ser identificada pelo seu ID para evitar que a mesma solicitação abra várias modais repetidamente durante atualizações do Firestore.

Não mostrar como nova uma solicitação que já tenha sido respondida ou expirada.

O destinatário não deve receber solicitações destinadas a outro usuário.

A implementação deve considerar que a solicitação pode ter sido criada enquanto o destinatário estava com o aplicativo fechado.

## 5.6 — Modal real

Conectar a modal visual criada na Fase 1 aos dados reais do Firestore.

A modal deve apresentar a solicitação recebida, identificando o remetente e o doguinho que está levando o pedido.

Deve oferecer exatamente as três respostas:

- ❤️ **Sim!**
- ⏰ **Daqui a 15 minutos**
- ❌ **Agora não posso**

Ao selecionar uma resposta:

- validar se a solicitação continua pendente;
- registrar a resposta no Firestore;
- desabilitar temporariamente os controles enquanto a operação estiver sendo processada;
- fechar a modal após a confirmação da resposta;
- atualizar os estados das duas Homes.

Se a solicitação já tiver expirado ou sido respondida em outro dispositivo, não aceitar uma segunda resposta. Fechar ou atualizar a modal e apresentar um feedback adequado.

Não criar solicitações adicionais como consequência de uma resposta.

## 5.7 — Resposta "Sim!"

Ao tocar em **"Sim!"**, atualizar a solicitação existente para `accepted`.

Registrar `answeredAt` com a data e hora da resposta.

O aplicativo do remetente deve detectar a alteração e apresentar o resultado correspondente.

O aplicativo do destinatário também deve atualizar a sua interface, removendo a solicitação da lista de pendentes.

A operação deve garantir que somente o destinatário autorizado consiga responder e que uma solicitação já finalizada não seja alterada novamente.

## 5.8 — Resposta "Daqui a 15 minutos"

Ao tocar em **"Daqui a 15 minutos"**, atualizar a solicitação existente para `delayed`.

Registrar `answeredAt`.

**Não criar um novo pedido. Não agendar o envio de outro pedido. Não iniciar um fluxo automático para daqui a 15 minutos.**

Essa opção representa somente a resposta do destinatário.

O remetente deve receber a atualização e visualizar que o parceiro respondeu que poderá atender mais tarde.

A solicitação deixa de estar pendente e não pode ser respondida novamente.

## 5.9 — Resposta "Agora não posso"

Ao tocar em **"Agora não posso"**, atualizar a solicitação existente para `declined`.

Registrar `answeredAt`.

O remetente deve receber a atualização e visualizar que a solicitação foi recusada.

O destinatário deve deixar de visualizar a solicitação como pendente.

Não criar outra solicitação e não permitir que a resposta seja alterada depois de registrada.

## 5.10 — Expiração após 15 minutos

Cada solicitação deve expirar 15 minutos após `createdAt`, caso continue pendente.

```text
pending + prazo atingido → expired
```

O prazo deve ser calculado com base em uma referência de tempo confiável, e não no relógio ou em um temporizador exclusivo da interface.

A implementação deve garantir que:

- a solicitação não permaneça válida indefinidamente;
- abrir novamente o aplicativo não reinicie o prazo;
- uma solicitação respondida antes do prazo não seja expirada posteriormente;
- uma solicitação vencida não possa ser aceita ou recusada;
- o remetente e o destinatário observem o estado atualizado.

A expiração não deve depender exclusivamente de um temporizador executado enquanto o aplicativo está aberto. O sistema precisa verificar a validade quando a solicitação é consultada ou quando ocorre uma tentativa de resposta.

Se for necessário um mecanismo adicional para atualizar documentos automaticamente no servidor, documentar a solução e suas dependências antes de implementá-la.

Não introduzir Cloud Functions, cobrança adicional ou infraestrutura nova sem avaliar e explicar a necessidade.

Quando o prazo terminar sem resposta, a Home do remetente deve apresentar:

> 🥺 A mensagem não foi respondida. Tente solicitar novamente.

O estado deve mudar para `expired`, liberando o remetente para criar uma nova solicitação.

## 5.11 — Bloqueio de duplicidade

Impedir múltiplas solicitações pendentes simultâneas enviadas pelo mesmo usuário.

O bloqueio deve funcionar mesmo quando:

- o usuário toca rapidamente várias vezes no botão;
- a conexão está lenta;
- duas operações tentam criar uma solicitação ao mesmo tempo;
- o aplicativo é fechado e reaberto;
- o estado local está desatualizado.

Não confiar somente em desabilitar o botão.

A criação deve validar o estado no Firestore e utilizar uma operação segura contra concorrência, conforme a arquitetura escolhida.

Uma solicitação com estado `accepted`, `delayed`, `declined` ou `expired` não deve bloquear novas solicitações.

Uma solicitação ainda pendente e dentro do prazo deve bloquear uma nova criação.

A proteção também deve ser considerada nas regras de segurança, para que um cliente não possa contornar a validação da interface.

## 5.12 — Retorno do doguinho

Depois que a solicitação terminar — por resposta ou expiração — a Home do remetente deve mostrar o estado de retorno do doguinho, conforme o layout já definido na Fase 1.

Exibir:

> Voltei! ❤️

O estado de retorno deve corresponder ao resultado real da solicitação e não pode depender exclusivamente de uma animação ou temporizador local.

Depois da apresentação do retorno, o doguinho deve voltar ao estado disponível, permitindo uma nova solicitação quando não existir outro pedido pendente.

A interface deve distinguir os resultados:

- `accepted`: resposta positiva;
- `delayed`: resposta "Daqui a 15 minutos";
- `declined`: resposta "Agora não posso";
- `expired`: solicitação sem resposta dentro do prazo.

Não alterar o estado da solicitação para representar visualmente o retorno. O retorno é um estado da interface, separado do resultado persistido do pedido.

Se for necessário definir a duração visual do retorno, utilizar uma duração curta e consistente com a interface existente, sem alterar o resultado registrado no Firestore.

## 5.13 — Teste completo

Executar testes com duas contas reais e, quando possível, dois dispositivos.

### Cenários obrigatórios

**Cenário A — Aceite**

1. A envia uma solicitação para B.
2. A Home de A mostra o estado "Estou levando sua solicitação!".
3. B recebe a solicitação e visualiza a modal.
4. B toca em "Sim!".
5. A recebe o resultado.
6. As duas Homes atualizam corretamente.

**Cenário B — Resposta "Daqui a 15 minutos"**

1. A envia uma solicitação.
2. B responde "Daqui a 15 minutos".
3. A visualiza a resposta.
4. Nenhum novo pedido é criado.
5. A pode fazer uma nova solicitação depois que a anterior terminar.

**Cenário C — Recusa**

1. A envia uma solicitação.
2. B responde "Agora não posso".
3. A visualiza a recusa.
4. A solicitação deixa de estar pendente.

**Cenário D — Expiração**

1. A envia uma solicitação.
2. B não responde.
3. O prazo de 14 minutos termina.
4. A solicitação passa para `expired`.
5. A visualiza a mensagem de expiração.
6. O remetente pode tentar novamente.

**Cenário E — Pedido duplicado**

1. A tenta enviar várias solicitações rapidamente.
2. Deve existir no máximo uma solicitação pendente.
3. O mesmo resultado deve ser garantido mesmo com duas operações concorrentes.

**Cenário F — Aplicativo fechado**

1. A envia uma solicitação.
2. B fecha o aplicativo ou o deixa em segundo plano.
3. B abre novamente o aplicativo.
4. A solicitação deve ser recuperada se ainda estiver pendente e válida.
5. Se o prazo tiver terminado, a solicitação não deve reaparecer como válida.

**Cenário G — Resposta concorrente**

1. B tenta responder à mesma solicitação em duas sessões ou dispositivos.
2. Somente uma resposta deve ser registrada.
3. A outra tentativa deve receber um resultado coerente, sem sobrescrever o estado final.

**Cenário H — Conexão encerrada**

1. A e B estão conectados.
2. A conexão é encerrada antes de uma nova solicitação.
3. O envio de um novo BORA DOGUINHO deve ser bloqueado.
4. Uma solicitação já existente deve respeitar as regras de validade e autorização definidas pelo produto, sem permitir operações indevidas.

### Verificações técnicas

- Compilar o projeto.
- Verificar as regras de segurança do Firestore.
- Confirmar que somente o destinatário pode responder.
- Confirmar que usuários não conectados não conseguem criar solicitações válidas entre si.
- Confirmar que a solicitação persiste após fechar e abrir o aplicativo.
- Confirmar que os dois usuários veem o estado correto.
- Não registrar dados privados desnecessários nos logs.

Ao terminar, informar:

1. o que foi implementado;
2. quais testes foram executados;
3. quais problemas foram encontrados e corrigidos;
4. quais problemas continuam pendentes;
5. quais regras ou configurações do Firebase precisam ser publicadas.

**Não considerar a fase concluída apenas porque o projeto compila.**

**Ponto de parada obrigatório:** não avançar para a Fase 6 — Push Notifications — antes de validar o fluxo de BORA DOGUINHO e resolver os problemas relevantes encontrados.

---

## Regras de execução da Fase 5

- Implementar uma subfase por vez.
- Não antecipar funcionalidades de fases futuras.
- Não implementar push notifications nesta fase.
- Não implementar chat, agendamento automático ou novas funcionalidades.
- Não alterar o layout geral da Home sem necessidade.
- Não alterar a autenticação ou a conexão já implementadas.
- Reutilizar os serviços e modelos existentes sempre que apropriado.
- Compilar e testar após cada subfase.
- Fazer commits nas subfases relevantes, mantendo o histórico organizado.
- Se surgir uma decisão de produto não definida, explicar a dúvida antes de tomar uma decisão que altere o comportamento do aplicativo.

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
