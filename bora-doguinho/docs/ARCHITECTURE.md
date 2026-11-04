# Arquitetura — Bora, Doguinho!

## Organização do código

```text
bora-doguinho/
├── Components/   componentes reutilizáveis de interface
├── Models/       modelos Codable e enums de domínio
├── Services/     acesso ao Firebase e regras de operação
├── Views/        telas SwiftUI
└── docs/         documentação do projeto
```

As views não devem gravar diretamente documentos Firestore para implementar
regras de negócio. Essa lógica pertence aos serviços.

## Autenticação e sessão

- `AuthSessionStore` é o estado observável da sessão autenticada.
- `UserService` cria e lê o perfil privado em `users/{uid}`.
- O UID sempre vem do Firebase Authentication; o usuário nunca escolhe o
  próprio ID.

## Estrutura Firestore existente

| Coleção/caminho | Responsabilidade |
| --- | --- |
| `users/{uid}` | Perfil privado do usuário, seleção de pet e vínculo de conexão. |
| `users/{uid}/pets/{petId}` | Pets disponíveis para a conta. |
| `pets/{petId}` | Catálogo global de pets usado pela interface. |
| `userPublicProfiles/{uid}` | Dados públicos mínimos para descoberta de parceiro. |
| `connectionRequests/{id}` | Convites de conexão. |
| `connections/{id}` | Conexões ativas/inativas entre dois usuários. |
| `doguinhoRequests/{id}` | Pedidos BORA DOGUINHO da Fase 5. |

## Serviços principais

- `PetService`: catálogo, pets da conta e persistência da seleção.
- `ConnectionService`: convites, conexão ativa, perfis públicos e
  desconexão.
- `DoguinhoRequestService`: operações do fluxo BORA DOGUINHO.

## Interface relacionada à Home

- `HomeView` carrega o pet ativo e o perfil público do parceiro.
- `DoguinhoRequestModal` é a interface visual das três respostas. Na Fase 5,
  ela deve receber um pedido real e delegar a resposta ao serviço.

## Segurança

As regras em `firestore.rules` são parte da arquitetura. Mudanças em operações
Firestore devem ser comparadas às regras antes de testar. Não liberar
`allow read, write: if true` para contornar uma falha de desenvolvimento.
