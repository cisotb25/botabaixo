# 🎮 Botabaixo

**Jogo de bebida open-source inspirado no Picolo!**

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-green.svg)]()

---

## 📖 Sobre o Botabaixo

Botabaixo é um jogo de bebida open-source criado para trazer diversão para as suas festas sem assinaturas caras! Inspirado no Picolo, mas com muito mais conteúdo e funcionalidades.

### ✨ Por que Botabaixo?

- **Sem assinaturas** - Todo o conteúdo é gratuito para sempre
- **Open source** - Código aberto para todos aprenderem e contribuírem
- **Multilíngue** - Suporte para Português e Inglês
- **Sync na nuvem** - Seus dados sincronizam entre dispositivos
- **Funciona offline** - Jogue mesmo sem internet!

---

## 🎯 Funcionalidades

### 👥 Gestão de Jogadores
- Adicione jogadores com nome e pronome
- Lista permanente de jogadores
- Seleção rápida para iniciar rodadas

### 🎲 Modos de Jogo
- **Modo Desafio** - Desafios aleatórios para jogadores específicos
- Sistema de shots baseado na dificuldade
- Múltiplos desafios por rodada

### 📊 Categorias de Desafios
- **Bebida** (Fácil) - Desafios simples de bebida
- **Verdade** (Médio) - Perguntas para conhecer melhor os amigos
- **Coragem** (Difícil) - Desafios ousados
- **Grupo** (Extremo) - Atividades para todo o grupo

---

## 🛠️ Tecnologias

- **Framework:** Flutter 3.x
- **Linguagem:** Dart
- **Armazenamento Local:** Hive (NoSQL)
- **Armazenamento na Nuvem:** Firebase Firestore
- **Autenticação:** Firebase Anonymous
- **State Management:** Provider

---

## 🚀 Como Começar

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado
- [Dart SDK](https://dart.dev/get-dart) (incluído com Flutter)
- Android Studio ou VS Code
- Conta no [Firebase](https://console.firebase.google.com/) (para sync na nuvem)

### Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/cisotb25/botabaixo.git
   cd botabaixo
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Configure o Firebase**
   ```bash
   # Instale o Firebase CLI
   npm install -g firebase-tools
   
   # Faça login
   firebase login
   
   # Configure o FlutterFire
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

4. **Execute o app**
   ```bash
   flutter run
   ```

---

## 📁 Estrutura do Projeto

```
botabaixo/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── models/
│   │   ├── player.dart
│   │   ├── challenge.dart
│   │   └── game_round.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── players_screen.dart
│   │   ├── game_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── player_card.dart
│   │   ├── challenge_card.dart
│   │   └── shot_counter.dart
│   ├── services/
│   │   ├── storage_service.dart
│   │   ├── firebase_service.dart
│   │   └── challenge_service.dart
│   ├── providers/
│   │   ├── player_provider.dart
│   │   └── game_provider.dart
│   └── utils/
│       ├── constants.dart
│       └── helpers.dart
├── assets/
│   └── challenges.json
├── pubspec.yaml
└── README.md
```

---

## 🎮 Como Jogar

1. **Adicione jogadores** - Vá para "Jogadores" e adicione seus amigos
2. **Inicie uma rodada** - Selecione quem vai jogar
3. **Receba desafios** - O app sorteará desafios aleatórios
4. **Beba conforme o desafio** - Shots são atribuídos baseado na dificuldade
5. **Divirta-se!**

---

## 🤝 Contribuir

Contribuições são muito bem-vindas! Veja como contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Adicione nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

---

## 📝 Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## 🙏 Agradecimentos

- [Flutter](https://flutter.dev) - Framework incrível para desenvolvimento mobile
- [Firebase](https://firebase.google.com) - Backend poderoso e fácil de usar
- [Picolo](https://www.picolo.app) - Inspiração para este projeto

---

## 📞 Contato

**E-mail** - tbnarciso13@gmail.com

Projeto Link: [https://github.com/cisotb25/botabaixo](https://github.com/cisotb25/botabaixo)

---

Feito com ❤️ para a comunidade de programadores e amantes de festas!
