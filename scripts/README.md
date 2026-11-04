# Scripts locais

## Testes das regras Firestore

Os testes em `test/firestore.rules.test.js` usam o Firebase Emulator Suite e
o projeto fictício `demo-bora-doguinho`. Eles não usam credenciais, não leem e
não escrevem no projeto Firebase de produção.

### Instalar dependências

```bash
cd scripts
npm install
```

### Executar

Na raiz do repositório:

```bash
XDG_CONFIG_HOME=/tmp/bora-doguinho-firebase-config firebase emulators:exec \
  --project demo-bora-doguinho \
  --only firestore \
  "npm --prefix scripts test"
```

O `XDG_CONFIG_HOME` evita que a Firebase CLI tente gravar sua configuração de
atualização no diretório global do sistema. O comando inicia um Firestore local
na porta 8080, executa os testes e encerra o emulador em seguida.

O Firestore Emulator requer um Java Runtime instalado e disponível no `PATH`.
Confirme antes com:

```bash
java -version
```

### Cobertura atual

- leitura pelo remetente, destinatário e terceiro;
- aceitação permitida somente ao destinatário;
- bloqueio de alteração após uma resposta final;
- bloqueio de expiração antes do prazo e permissão após o prazo;
- criação atômica do pedido com a atualização de
  `pendingDoguinhoRequestId`, validando `getAfter()`;
- bloqueio de criação de pedido fora dessa transação.

Os dados iniciais de cada teste são criados somente dentro do emulador com as
regras temporariamente desabilitadas. A operação que cada cenário avalia é
sempre executada com as regras reais de `../../firestore.rules` ativas.
