const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const path = require('path');
const fs = require('fs');

// INSTRUÇÕES DE USO:
// 1. Instale o firebase-admin: `npm install firebase-admin`
// 2. Coloque sua service account key em `scripts/serviceAccountKey.json`
// 3. Rode o script: `node seed_pets.js`

const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(serviceAccountPath)) {
    console.error('Arquivo serviceAccountKey.json não encontrado...');
    process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

initializeApp({
    credential: cert(serviceAccount)
});

const db = getFirestore();

const pets = [
    { id: 'harry', name: 'Harry', imageName: 'harry' },
    { id: 'pandora', name: 'Pandora', imageName: 'pandora' },
    { id: 'merlim', name: 'Merlim', imageName: 'merlim' }
];

async function seed() {
    console.log('Iniciando seeding da Fase 3 (Sem Firebase Storage)...');
    
    // 1. Criação do catálogo
    for (const pet of pets) {
        console.log(`Criando documento do catálogo: pets/${pet.id}...`);
        await db.collection('pets').doc(pet.id).set({
            id: pet.id,
            name: pet.name,
            imageName: pet.imageName,
            createdAt: FieldValue.serverTimestamp()
        });
    }
    
    // 2. Adicionar Merlim aos usuários existentes
    console.log('Verificando contas de usuários existentes para adicionar Merlim...');
    const usersSnapshot = await db.collection('users').get();
    
    let batch = db.batch();
    let batchCount = 0;
    
    for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const merlimRef = db.collection('users').doc(userId).collection('pets').doc('merlim');
        
        const merlimSnap = await merlimRef.get();
        if (!merlimSnap.exists) {
            console.log(`Adicionando Merlim para o usuário ${userId}...`);
            batch.set(merlimRef, {
                id: 'merlim',
                name: 'Merlim',
                createdAt: FieldValue.serverTimestamp()
            });
            batchCount++;
            
            if (batchCount === 500) {
                await batch.commit();
                batch = db.batch();
                batchCount = 0;
            }
        }
    }
    
    if (batchCount > 0) {
        await batch.commit();
    }
    
    console.log('Seeding concluído com sucesso!');
    process.exit(0);
}

seed().catch(console.error);
