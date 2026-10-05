# Configuração Firebase — Fase 2

O código da Fase 2 já referencia `FirebaseAuth`, `FirebaseCore` e
`FirebaseFirestore` pelo Swift Package Manager. Para ativá-lo em um ambiente
real, faça a configuração abaixo no console do Firebase, sem incluir chaves
administrativas no app.

1. Crie ou selecione o projeto Firebase do aplicativo.
2. Registre o app iOS com o bundle ID `mais1app.bora-doguinho`.
3. Baixe o `GoogleService-Info.plist` gerado pelo Firebase e adicione-o à pasta
   `bora-doguinho/`, marcando o target **bora-doguinho** no Xcode. O arquivo
   contém a configuração pública específica do app e não deve ser inventado.
4. Em **Authentication > Sign-in method**, habilite **E-mail/senha**.
5. Em **Firestore Database**, crie o banco na região escolhida pelo projeto.
6. Instale a Firebase CLI, faça login na conta do projeto e publique as regras
   restritivas versionadas neste repositório:

   ```bash
   firebase deploy --only firestore:rules --project bora-doguinho
   ```

7. Abra o projeto no Xcode para resolver os pacotes Swift e execute em um
   simulador ou iPhone.

Enquanto o plist não estiver presente, o app mostra uma tela de orientação e
não tenta autenticar usando valores fictícios.

Nesta fase, o cadastro grava o perfil em `users/{uid}` e cria
`users/{uid}/pets/harry` e `users/{uid}/pets/pandora`. O `uid` é sempre o UID
emitido pelo Firebase Authentication.

As regras em `firestore.rules` liberam exclusivamente esse fluxo para o dono
autenticado. Elas devem ser evoluídas nas fases de Pets e Conexão; não troque
as regras por acesso público durante o desenvolvimento.
