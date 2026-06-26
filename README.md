# MiResta — Gerenciador Financeiro Cristão

[![CI](https://github.com/arthurlunkes/my_finances/actions/workflows/ci.yml/badge.svg)](https://github.com/arthurlunkes/my_finances/actions/workflows/ci.yml)
[![Build & Release](https://github.com/arthurlunkes/my_finances/actions/workflows/release.yml/badge.svg)](https://github.com/arthurlunkes/my_finances/actions/workflows/release.yml)
![Version](https://img.shields.io/badge/version-1.0.0-green)
![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/plataforma-Android%20%7C%20iOS-lightgrey)

Um aplicativo completo de gerenciamento financeiro pessoal desenvolvido em Flutter, com foco especial em finanças cristãs (dízimos e ofertas).

## ✨ Funcionalidades Implementadas

### 📱 Dashboard Inicial
- **Saldo Atual**: Visualização do saldo com indicadores de receitas e despesas
- **Resumo Financeiro**: Cards com totais de receitas, despesas, dízimos e ofertas
- **Próximos Pagamentos**: Lista dos pagamentos pendentes nos próximos 7 dias
- **Atualização Pull-to-Refresh**: Arraste para baixo para atualizar os dados

### 💰 Gestão de Transações
- Modelos de dados completos para:
  - Transações (receitas, despesas)
  - Cartões de crédito com limites e faturas
  - Categorias personalizáveis
- Estados de transação: Pendente, Pago, Atrasado, Agendado
- Cálculo automático de dízimo (10% das receitas)
- Transações recorrentes

### 💳 Cartões de Crédito
- Gerenciamento de múltiplos cartões
- Controle de limites e faturas
- Parcelamentos
- Cálculo de limite disponível
- Datas de fechamento e vencimento

### 🗄️ Banco de Dados
- SQLite para armazenamento local
- Categorias padrão pré-cadastradas
- Persistência completa de dados

### 🎨 Design
- Tema Material Design 3
- Paleta de cores diferenciada por tipo de transação
- Modo claro e escuro (preparado)
- Google Fonts (Roboto)
- Interface intuitiva e responsiva

## 🏗️ Arquitetura

```
lib/
├── core/
│   ├── constants/      # Cores, strings, versículos
│   ├── theme/          # Tema do app
│   └── utils/          # Formatadores e validadores
├── data/
│   ├── models/         # Modelos de dados
│   └── repositories/   # Acesso ao banco de dados
├── presentation/
│   └── screens/        # Telas do aplicativo
└── providers/          # Gerenciamento de estado (Provider)
```

## 🚀 Como Executar

```bash
# Instalar dependências
flutter pub get

# Executar o app
flutter run

# Ou executar em uma plataforma específica
flutter run -d windows
flutter run -d chrome
flutter run -d android
```

## 📦 Dependências Principais

- **provider**: Gerenciamento de estado
- **sqflite**: Banco de dados local
- **intl**: Formatação de moeda e datas
- **google_fonts**: Fontes personalizadas
- **table_calendar**: Calendário mensal de transações
- **fl_chart**: Gráficos de dízimos e ofertas
- **flutter_local_notifications**: Notificações locais
- **go_router**: Navegação
- **shared_preferences**: Preferências locais

## ✅ Funcionalidades Completas

### 🏠 Dashboard
- Resumo financeiro do mês
- Saldo atual com indicadores
- Cards de receitas, despesas
- Próximos pagamentos (7 dias)
- Navegação por bottom bar

### 📋 Transações
- ✅ Lista completa com filtros (Todas, Receitas, Despesas, Dízimos)
- ✅ Busca por descrição/categoria
- ✅ Agrupamento por mês
- ✅ Adicionar novas transações
- ✅ Editar transações existentes
- ✅ Excluir transações
- ✅ Marcar como paga
- ✅ Parcelamento em cartão de crédito
- ✅ Transações recorrentes
- ✅ Status visual (Pendente, Pago, Atrasado)

### 📅 Calendário
- ✅ Visualização mensal completa
- ✅ Marcadores de transações por dia
- ✅ Filtro por data selecionada
- ✅ Resumo diário (receitas/despesas)

## 🎯 Próximas Implementações

1. ⏳ Gerenciamento de Cartões de Crédito
2. ⏳ Relatórios e gráficos detalhados
3. ⏳ Metas de economia
4. ⏳ Configurações e backup
5. ⏳ Sistema de notificações
6. ⏳ Exportação de dados (PDF/Excel)
7. ⏳ Temas claro/escuro
8. ⏳ Autenticação e sincronização na nuvem

## 💡 Conceitos Implementados

- **Clean Architecture**: Separação de responsabilidades
- **Provider Pattern**: Gerenciamento de estado reativo
- **Repository Pattern**: Abstração do acesso a dados
- **SQLite**: Persistência local eficiente
- **Material Design 3**: UI moderna e consistente
- **Formatação Brasileira**: Moeda (R$) e datas em pt_BR

## 🤖 CI/CD

O projeto usa **GitHub Actions** ([.github/workflows/](.github/workflows/)):

| Workflow | Gatilho | O que faz |
|---|---|---|
| **CI** (`ci.yml`) | push / PR na `main` | `dart format` + `flutter analyze` + `flutter test` |
| **Build & Release** (`release.yml`) | tag `v*` ou manual | gera `.aab` + `.apk` e publica um GitHub Release |
| **Deploy → Play Store** (`deploy-play.yml`) | manual (desativado) | envia o `.aab` assinado para a Google Play |

O status do CI e do build aparece nos badges no topo deste README.

## 📲 Build & Release

### Build local

```bash
# App Bundle para a Play Store (.aab)
flutter build appbundle --release

# APK para instalar/testar direto no aparelho
flutter build apk --release
```

A assinatura de release é lida de `android/key.properties` (fora do versionamento).
Sem esse arquivo, o build de release cai para a chave de debug automaticamente.

### Release via tag

```bash
# Atualize a versão em pubspec.yaml (ex.: version: 1.0.1+5) e então:
git tag v1.0.1
git push origin v1.0.1
```

Isso dispara o workflow **Build & Release**, que gera os artefatos e cria um
GitHub Release com o `.aab` e o `.apk` anexados.

> Versionamento: `versionName` (visível ao usuário) vem da tag; `versionCode`
> (interno da Play) é gerado pela execução, sempre crescente.

---

**Desenvolvido com 💙**
