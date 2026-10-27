# FajaLead Mobile

App mobile (Flutter) do FajaLead para gestão de clientes.

## Estrutura

```
lib/
├── main.dart
├── app.dart                 # MaterialApp e tela inicial
├── core/
│   ├── api/                 # cliente HTTP e autenticação
│   ├── theme/               # cores e tema
│   ├── utils/               # formatadores
│   └── widgets/             # widgets compartilhados
├── models/                  # modelos de dados
└── features/
    ├── auth/                # login
    └── clientes/            # listagem e cadastro
```

## Executar

```bash
flutter pub get
flutter run
```

## Testes

```bash
flutter analyze
flutter test
```
