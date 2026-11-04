FASE 5 — BORA DOGUINHO
Esta é a principal funcionalidade do aplicativo e será propositalmente dividida em subfases pequenas.
Cada subfase deve implementar somente o comportamento descrito, mantendo o projeto compilável e preservando o que já funciona nas fases anteriores.
O objetivo final é permitir que dois usuários conectados troquem solicitações reais de BORA DOGUINHO, com atualização em tempo real, respostas, expiração e estados visuais sincronizados.
Objetivo geral
Implementar o fluxo real do BORA DOGUINHO utilizando Firestore.
O usuário deve conseguir solicitar a presença do parceiro por meio do doguinho selecionado. O parceiro deve receber a solicitação, visualizar uma modal e responder. Os dois aplicativos devem refletir o resultado correto.
A implementação deve funcionar com duas contas reais e, ao final da fase, ser validada em dois dispositivos.
Regras de produto obrigatórias
O BORA DOGUINHO só pode ser enviado por um usuário autenticado que possua uma conexão ativa.
Cada solicitação pertence a um remetente e a um destinatário específicos.
O doguinho utilizado na solicitação deve corresponder ao pet selecionado pelo remetente no momento do envio.
O remetente não pode ter mais de uma solicitação pendente simultaneamente.
O destinatário deve conseguir responder somente às solicitações recebidas que ainda estejam pendentes e válidas.
Uma solicitação aceita, recusada ou expirada não pode voltar ao estado pendente.
A resposta "Daqui a 15 minutos" não agenda uma nova solicitação nem cria um temporizador para enviar outra mensagem.
Uma solicitação pendente expira após 15 minutos, contados a partir da sua criação.
Fechar o aplicativo não cancela nem reinicia o prazo da solicitação.
A interface deve refletir o estado real armazenado no Firestore, e não apenas alterações locais temporárias.
Não confiar exclusivamente na interface para impedir ações inválidas. As operações devem validar o estado atual e respeitar as regras de segurança do Firestore.
Não alterar o funcionamento da autenticação, da conexão ou da seleção de pets implementado nas fases anteriores.

5.1 — Modelo DoguinhoRequest
Criar o modelo que representa uma solicitação de BORA DOGUINHO.
Cada documento deve representar uma única solicitação e conter, no mínimo:
id: identificador único da solicitação;
senderUserId: UID do usuário que enviou;
receiverUserId: UID do usuário que recebeu;
senderPetId: ID do doguinho utilizado pelo remetente;
status: estado atual da solicitação;
createdAt: data e hora de criação;
answeredAt: data e hora da resposta, quando houver.
Se necessário para implementar corretamente a expiração, pode ser adicionado um campo como expiresAt, desde que sua finalidade e validação sejam documentadas.
Estados permitidos
pending: solicitação criada e aguardando resposta;
accepted: o destinatário respondeu "Sim!";
delayed: o destinatário respondeu "Daqui a 15 minutos";
declined: o destinatário respondeu "Agora não posso";
expired: o prazo de resposta terminou sem uma resposta válida.
Regras de transição
pending → accepted
pending → delayed
pending → declined
pending → expired

Não permitir outras transições de estado.
As transições devem ser validadas no serviço e protegidas pelas regras de segurança. Uma resposta não pode sobrescrever outra resposta que já tenha sido registrada.
Commit sugerido: feat: add doguinho request model
5.2 — DoguinhoRequestService
Criar um serviço responsável pelas operações de BORA DOGUINHO no Firestore.
O serviço deve concentrar a lógica de:
criar solicitações;
observar solicitações pendentes recebidas;
observar o estado da solicitação enviada;
registrar respostas;
validar o estado antes de responder;
verificar a expiração;
impedir solicitações duplicadas;
atualizar o estado quando o prazo terminar.
A interface não deve manipular diretamente os documentos do Firestore para implementar regras de negócio.
Reutilizar os modelos, serviços e a sessão de autenticação existentes. Não criar uma segunda estrutura de usuários ou conexões.
As operações devem tratar erros de rede, falta de permissão, conexão inexistente e solicitações que deixaram de ser válidas.
5.3 — Criar pedido
Implementar o fluxo acionado pelo botão "BORA DOGUINHO?" na Home.
Ao tocar no botão, validar:
o usuário está autenticado;
existe uma conexão ativa;
o usuário conectado corresponde ao destinatário;
o remetente possui um doguinho selecionado e disponível;
não existe outra solicitação pendente enviada pelo mesmo usuário;
a conexão continua válida no momento da operação.
Se todas as validações forem atendidas:
criar um documento DoguinhoRequest;
preencher remetente, destinatário, pet, estado e data de criação;
registrar o prazo de expiração;
atualizar a interface para o estado de solicitação em andamento.
O pet enviado deve ser definido no momento da criação. Uma alteração posterior da seleção de pet não deve modificar uma solicitação já criada.
Durante o envio, mostrar um estado de carregamento e impedir toques repetidos que possam gerar solicitações duplicadas.
Se ocorrer um erro, informar que não foi possível enviar a solicitação e permitir uma nova tentativa quando apropriado.
Não considerar o envio concluído até que o Firestore confirme a operação.
Commit sugerido: feat: create doguinho requests
5.4 — Estado "levando"
Depois que o pedido for criado com sucesso, a Home do remetente deve refletir que o doguinho está levando a solicitação.
Exibir a mensagem:
Estou levando sua solicitação!
A Home deve continuar mostrando o pet associado à solicitação enviada, mesmo que o usuário altere a seleção de pet enquanto o pedido estiver em andamento.
O estado deve ser derivado da solicitação real no Firestore.
Não utilizar apenas uma variável local para manter o doguinho nesse estado, pois a interface precisa se recuperar corretamente após fechar e reabrir o aplicativo.
Quando a solicitação receber uma resposta ou expirar, a Home deverá reagir ao novo estado.
5.5 — Receber pedido
O aplicativo do destinatário deve observar as solicitações recebidas que estejam pendentes e sejam destinadas ao usuário autenticado.
Quando uma nova solicitação válida for criada:
identificar o remetente;
identificar o pet utilizado;
atualizar a Home do destinatário;
preparar a exibição da modal de resposta.
A solicitação recebida deve ser identificada pelo seu ID para evitar que a mesma solicitação abra várias modais repetidamente durante atualizações do Firestore.
Não mostrar como nova uma solicitação que já tenha sido respondida ou expirada.
O destinatário não deve receber solicitações destinadas a outro usuário.
A implementação deve considerar que a solicitação pode ter sido criada enquanto o destinatário estava com o aplicativo fechado.
5.6 — Modal real
Conectar a modal visual criada na Fase 1 aos dados reais do Firestore.
A modal deve apresentar a solicitação recebida, identificando o remetente e o doguinho que está levando o pedido.
Deve oferecer exatamente as três respostas:
❤️ Sim!
⏰ Daqui a 15 minutos
❌ Agora não posso
Ao selecionar uma resposta:
validar se a solicitação continua pendente;
registrar a resposta no Firestore;
desabilitar temporariamente os controles enquanto a operação estiver sendo processada;
fechar a modal após a confirmação da resposta;
atualizar os estados das duas Homes.
Se a solicitação já tiver expirado ou sido respondida em outro dispositivo, não aceitar uma segunda resposta. Fechar ou atualizar a modal e apresentar um feedback adequado.
Não criar solicitações adicionais como consequência de uma resposta.
5.7 — Resposta "Sim!"
Ao tocar em "Sim!", atualizar a solicitação existente para accepted.
Registrar answeredAt com a data e hora da resposta.
O aplicativo do remetente deve detectar a alteração e apresentar o resultado correspondente.
O aplicativo do destinatário também deve atualizar a sua interface, removendo a solicitação da lista de pendentes.
A operação deve garantir que somente o destinatário autorizado consiga responder e que uma solicitação já finalizada não seja alterada novamente.
5.8 — Resposta "Daqui a 15 minutos"
Ao tocar em "Daqui a 15 minutos", atualizar a solicitação existente para delayed.
Registrar answeredAt.
Não criar um novo pedido. Não agendar o envio de outro pedido. Não iniciar um fluxo automático para daqui a 15 minutos.
Essa opção representa somente a resposta do destinatário.
O remetente deve receber a atualização e visualizar que o parceiro respondeu que poderá atender mais tarde.
A solicitação deixa de estar pendente e não pode ser respondida novamente.
5.9 — Resposta "Agora não posso"
Ao tocar em "Agora não posso", atualizar a solicitação existente para declined.
Registrar answeredAt.
O remetente deve receber a atualização e visualizar que a solicitação foi recusada.
O destinatário deve deixar de visualizar a solicitação como pendente.
Não criar outra solicitação e não permitir que a resposta seja alterada depois de registrada.
5.10 — Expiração após 15 minutos
Cada solicitação deve expirar 15 minutos após createdAt, caso continue pendente.
pending + prazo atingido → expired

O prazo deve ser calculado com base em uma referência de tempo confiável, e não no relógio ou em um temporizador exclusivo da interface.
A implementação deve garantir que:
a solicitação não permaneça válida indefinidamente;
abrir novamente o aplicativo não reinicie o prazo;
uma solicitação respondida antes do prazo não seja expirada posteriormente;
uma solicitação vencida não possa ser aceita ou recusada;
o remetente e o destinatário observem o estado atualizado.
A expiração não deve depender exclusivamente de um temporizador executado enquanto o aplicativo está aberto. O sistema precisa verificar a validade quando a solicitação é consultada ou quando ocorre uma tentativa de resposta.
Se for necessário um mecanismo adicional para atualizar documentos automaticamente no servidor, documentar a solução e suas dependências antes de implementá-la.
Não introduzir Cloud Functions, cobrança adicional ou infraestrutura nova sem avaliar e explicar a necessidade.
Quando o prazo terminar sem resposta, a Home do remetente deve apresentar:
🥺 A mensagem não foi respondida. Tente solicitar novamente.
O estado deve mudar para expired, liberando o remetente para criar uma nova solicitação.
5.11 — Bloqueio de duplicidade
Impedir múltiplas solicitações pendentes simultâneas enviadas pelo mesmo usuário.
O bloqueio deve funcionar mesmo quando:
o usuário toca rapidamente várias vezes no botão;
a conexão está lenta;
duas operações tentam criar uma solicitação ao mesmo tempo;
o aplicativo é fechado e reaberto;
o estado local está desatualizado.
Não confiar somente em desabilitar o botão.
A criação deve validar o estado no Firestore e utilizar uma operação segura contra concorrência, conforme a arquitetura escolhida.
Uma solicitação com estado accepted, delayed, declined ou expired não deve bloquear novas solicitações.
Uma solicitação ainda pendente e dentro do prazo deve bloquear uma nova criação.
A proteção também deve ser considerada nas regras de segurança, para que um cliente não possa contornar a validação da interface.
5.12 — Retorno do doguinho
Depois que a solicitação terminar — por resposta ou expiração — a Home do remetente deve mostrar o estado de retorno do doguinho, conforme o layout já definido na Fase 1.
Exibir:
Voltei! ❤️
O estado de retorno deve corresponder ao resultado real da solicitação e não pode depender exclusivamente de uma animação ou temporizador local.
Depois da apresentação do retorno, o doguinho deve voltar ao estado disponível, permitindo uma nova solicitação quando não existir outro pedido pendente.
A interface deve distinguir os resultados:
accepted: resposta positiva;
delayed: resposta "Daqui a 15 minutos";
declined: resposta "Agora não posso";
expired: solicitação sem resposta dentro do prazo.
Não alterar o estado da solicitação para representar visualmente o retorno. O retorno é um estado da interface, separado do resultado persistido do pedido.
Se for necessário definir a duração visual do retorno, utilizar uma duração curta e consistente com a interface existente, sem alterar o resultado registrado no Firestore.
5.13 — Teste completo
Executar testes com duas contas reais e, quando possível, dois dispositivos.
Cenários obrigatórios
Cenário A — Aceite
A envia uma solicitação para B.
A Home de A mostra o estado "Estou levando sua solicitação!".
B recebe a solicitação e visualiza a modal.
B toca em "Sim!".
A recebe o resultado.
As duas Homes atualizam corretamente.
Cenário B — Resposta "Daqui a 15 minutos"
A envia uma solicitação.
B responde "Daqui a 15 minutos".
A visualiza a resposta.
Nenhum novo pedido é criado.
A pode fazer uma nova solicitação depois que a anterior terminar.
Cenário C — Recusa
A envia uma solicitação.
B responde "Agora não posso".
A visualiza a recusa.
A solicitação deixa de estar pendente.
Cenário D — Expiração
A envia uma solicitação.
B não responde.
O prazo de 15 minutos termina.
A solicitação passa para expired.
A visualiza a mensagem de expiração.
O remetente pode tentar novamente.
Cenário E — Pedido duplicado
A tenta enviar várias solicitações rapidamente.
Deve existir no máximo uma solicitação pendente.
O mesmo resultado deve ser garantido mesmo com duas operações concorrentes.
Cenário F — Aplicativo fechado
A envia uma solicitação.
B fecha o aplicativo ou o deixa em segundo plano.
B abre novamente o aplicativo.
A solicitação deve ser recuperada se ainda estiver pendente e válida.
Se o prazo tiver terminado, a solicitação não deve reaparecer como válida.
Cenário G — Resposta concorrente
B tenta responder à mesma solicitação em duas sessões ou dispositivos.
Somente uma resposta deve ser registrada.
A outra tentativa deve receber um resultado coerente, sem sobrescrever o estado final.
Cenário H — Conexão encerrada
A e B estão conectados.
A conexão é encerrada antes de uma nova solicitação.
O envio de um novo BORA DOGUINHO deve ser bloqueado.
Uma solicitação já existente deve respeitar as regras de validade e autorização definidas pelo produto, sem permitir operações indevidas.
Verificações técnicas
Compilar o projeto.
Verificar as regras de segurança do Firestore.
Confirmar que somente o destinatário pode responder.
Confirmar que usuários não conectados não conseguem criar solicitações válidas entre si.
Confirmar que a solicitação persiste após fechar e abrir o aplicativo.
Confirmar que os dois usuários veem o estado correto.
Não registrar dados privados desnecessários nos logs.
Ao terminar, informar:
o que foi implementado;
quais testes foram executados;
quais problemas foram encontrados e corrigidos;
quais problemas continuam pendentes;
quais regras ou configurações do Firebase precisam ser publicadas.
Não considerar a fase concluída apenas porque o projeto compila.
Ponto de parada obrigatório: não avançar para a Fase 6 — Push Notifications — antes de validar o fluxo de BORA DOGUINHO e resolver os problemas relevantes encontrados.

Regras de execução da Fase 5
Implementar uma subfase por vez.
Não antecipar funcionalidades de fases futuras.
Não implementar push notifications nesta fase.
Não implementar chat, agendamento automático ou novas funcionalidades.
Não alterar o layout geral da Home sem necessidade.
Não alterar a autenticação ou a conexão já implementadas.
Reutilizar os serviços e modelos existentes sempre que apropriado.
Compilar e testar após cada subfase.
Fazer commits nas subfases relevantes, mantendo o histórico organizado.
Se surgir uma decisão de produto não definida, explicar a dúvida antes de tomar uma decisão que altere o comportamento do aplicativo.
