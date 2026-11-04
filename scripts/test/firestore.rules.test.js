const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');
const { after, afterEach, before, beforeEach, test } = require('node:test');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  Timestamp,
  doc,
  getDoc,
  runTransaction,
  setDoc,
  updateDoc,
} = require('firebase/firestore');

const PROJECT_ID = 'demo-bora-doguinho';
const FIRESTORE_HOST = '127.0.0.1';
const FIRESTORE_PORT = 8080;

const senderId = 'sender-user';
const receiverId = 'receiver-user';
const thirdUserId = 'third-user';
const requestId = 'request-pending';

let testEnvironment;

function requestData({
  id = requestId,
  status = 'pending',
  createdAt = Timestamp.now(),
  answeredAt = null,
  expiresAt = Timestamp.fromMillis(createdAt.toMillis() + 15 * 60 * 1000),
} = {}) {
  return {
    id,
    senderUserId: senderId,
    receiverUserId: receiverId,
    senderPetId: 'harry',
    status,
    createdAt,
    answeredAt,
    expiresAt,
  };
}

function userData(id, connectedUserId) {
  return {
    id,
    name: id,
    email: `${id}@example.test`,
    avatarURL: '',
    activePetId: 'harry',
    petSelectionMode: 'specific',
    connectedUserId,
    createdAt: Timestamp.now(),
  };
}

function firestoreFor(userId) {
  return testEnvironment.authenticatedContext(userId).firestore();
}

function requestReference(db, id = requestId) {
  return doc(db, 'doguinhoRequests', id);
}

async function seedConnectedUsers() {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await setDoc(doc(db, 'users', senderId), userData(senderId, receiverId));
    await setDoc(doc(db, 'users', receiverId), userData(receiverId, senderId));
    await setDoc(doc(db, 'users', thirdUserId), userData(thirdUserId, null));
    await setDoc(doc(db, 'users', senderId, 'pets', 'harry'), {
      id: 'harry',
      name: 'Harry',
      createdAt: Timestamp.now(),
    });
    await setDoc(doc(db, 'connections', `${senderId}_${receiverId}`), {
      id: `${senderId}_${receiverId}`,
      userIds: [senderId, receiverId],
      status: 'active',
      requestId: 'connection-request',
      createdAt: Timestamp.now(),
    });
  });
}

async function seedRequest(data = requestData()) {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(requestReference(context.firestore(), data.id), data);
  });
}

before(async () => {
  testEnvironment = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      host: FIRESTORE_HOST,
      port: FIRESTORE_PORT,
      rules: readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8'),
    },
  });
});

beforeEach(async () => {
  await testEnvironment.clearFirestore();
  await seedConnectedUsers();
});

afterEach(async () => {
  await testEnvironment.clearFirestore();
});

after(async () => {
  await testEnvironment.cleanup();
});

test('remetente pode ler o próprio pedido', async () => {
  await seedRequest();

  await assertSucceeds(getDoc(requestReference(firestoreFor(senderId))));
});

test('destinatário pode ler o pedido recebido', async () => {
  await seedRequest();

  await assertSucceeds(getDoc(requestReference(firestoreFor(receiverId))));
});

test('terceiro usuário não pode ler o pedido', async () => {
  await seedRequest();

  await assertFails(getDoc(requestReference(firestoreFor(thirdUserId))));
});

test('destinatário pode aceitar pedido pending antes de expirar', async () => {
  await seedRequest();
  const receiverDb = firestoreFor(receiverId);

  await assertSucceeds(
    updateDoc(requestReference(receiverDb), {
      status: 'accepted',
      answeredAt: Timestamp.now(),
    }),
  );
});

test('remetente não pode aceitar o próprio pedido', async () => {
  await seedRequest();
  const senderDb = firestoreFor(senderId);

  await assertFails(
    updateDoc(requestReference(senderDb), {
      status: 'accepted',
      answeredAt: Timestamp.now(),
    }),
  );
});

test('pedido aceito não aceita uma segunda alteração', async () => {
  await seedRequest(requestData({
    status: 'accepted',
    answeredAt: Timestamp.now(),
  }));
  const receiverDb = firestoreFor(receiverId);

  await assertFails(
    updateDoc(requestReference(receiverDb), {
      status: 'declined',
      answeredAt: Timestamp.now(),
    }),
  );
});

test('pedido pendente não pode expirar antes de expiresAt', async () => {
  await seedRequest();
  const senderDb = firestoreFor(senderId);

  await assertFails(
    updateDoc(requestReference(senderDb), { status: 'expired' }),
  );
});

test('participante pode marcar pedido vencido como expired', async () => {
  const createdAt = Timestamp.fromMillis(Date.now() - 16 * 60 * 1000);
  const expiresAt = Timestamp.fromMillis(Date.now() - 60 * 1000);
  await seedRequest(requestData({ createdAt, expiresAt }));
  const receiverDb = firestoreFor(receiverId);

  await assertSucceeds(
    updateDoc(requestReference(receiverDb), { status: 'expired' }),
  );
});

test('transação do remetente cria pedido e atualiza ponteiro com getAfter()', async () => {
  const senderDb = firestoreFor(senderId);
  const newRequestId = 'request-created-in-transaction';
  const userReference = doc(senderDb, 'users', senderId);
  const newRequestReference = requestReference(senderDb, newRequestId);
  const createdAt = Timestamp.now();

  await assertSucceeds(
    runTransaction(senderDb, async (transaction) => {
      await transaction.get(userReference);
      transaction.set(newRequestReference, requestData({
        id: newRequestId,
        createdAt,
      }));
      transaction.update(userReference, {
        pendingDoguinhoRequestId: newRequestId,
      });
    }),
  );

  await assertSucceeds(getDoc(newRequestReference));
});

test('pedido criado fora da transação com o ponteiro é bloqueado', async () => {
  const senderDb = firestoreFor(senderId);
  const directRequestReference = requestReference(
    senderDb,
    'request-without-pointer',
  );

  await assertFails(
    setDoc(directRequestReference, requestData({
      id: 'request-without-pointer',
    })),
  );
});
