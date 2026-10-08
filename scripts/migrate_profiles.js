const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const path = require('path');
const fs = require('fs');

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

async function migrate() {
    console.log('Iniciando migração de perfis públicos (Fase 4)...');
    
    const usersSnapshot = await db.collection('users').get();
    
    if (usersSnapshot.empty) {
        console.log('Nenhum usuário encontrado na coleção "users".');
        process.exit(0);
    }

    let batch = db.batch();
    let batchCount = 0;
    let totalMigrated = 0;
    
    for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        const userId = userDoc.id;
        
        const publicProfileRef = db.collection('userPublicProfiles').doc(userId);
        
        // Usamos { merge: true } para fazer um upsert seguro e idempotente.
        // O documento terá SOMENTE os campos solicitados, baseado na coleção users.
        batch.set(publicProfileRef, {
            id: userId,
            name: userData.name || 'Sem Nome',
            avatarURL: userData.avatarURL || ''
        }, { merge: true });
        
        batchCount++;
        totalMigrated++;
        
        // O Firestore Batch suporta até 500 operações simultâneas
        if (batchCount === 500) {
            await batch.commit();
            console.log(`Commit de lote concluído (${totalMigrated} processados)...`);
            batch = db.batch();
            batchCount = 0;
        }
    }
    
    if (batchCount > 0) {
        await batch.commit();
        console.log(`Commit de lote final concluído (${totalMigrated} processados)...`);
    }
    
    console.log('Migração concluída com sucesso!');
    process.exit(0);
}

migrate().catch(console.error);
