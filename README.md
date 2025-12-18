# My Finances - Gerenciador Financeiro Cristão

Um aplicativo completo de gerenciamento financeiro pessoal desenvolvido em Flutter, com foco especial em finanças cristãs (dízimos e ofertas).

## ✨ Funcionalidades Implementadas

### 📱 Dashboard Inicial
- **Saldo Atual**: Visualização do saldo com indicadores de receitas e despesas
- **Resumo Financeiro**: Cards com totais de receitas, despesas, dízimos e ofertas
- **Próximos Pagamentos**: Lista dos pagamentos pendentes nos próximos 7 dias
- **Versículo do Dia**: Versículo bíblico motivacional relacionado a finanças
- **Atualização Pull-to-Refresh**: Arraste para baixo para atualizar os dados

### 💰 Gestão de Transações
- Modelos de dados completos para:
  - Transações (receitas, despesas, dízimos, ofertas)
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

### ⛪ Recursos Cristãos
- **Dízimos**: Cálculo automático de 10% das receitas
- **Ofertas**: Registro de contribuições voluntárias
- **Versículos Bíblicos**: Coleção de versículos sobre:
  - Dízimo e generosidade
  - Mordomia financeira
  - Provisão divina
  - Sabedoria financeira
  - Contentamento

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
- **table_calendar**: Calendário (para implementar)
- **fl_chart**: Gráficos (para implementar)
- **flutter_local_notifications**: Notificações (para implementar)

## ✅ Funcionalidades Completas

### 🏠 Dashboard
- Resumo financeiro do mês
- Saldo atual com indicadores
- Cards de receitas, despesas, dízimos e ofertas
- Versículo bíblico do dia
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

### ⛪ Dízimos e Ofertas
- ✅ Cálculo automático de dízimo (10%)
- ✅ Resumo total contribuído
- ✅ Separação de dízimos e ofertas
- ✅ Gráfico dos últimos 6 meses
- ✅ Versículos bíblicos sobre dízimo
- ✅ Histórico mensal

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

## 🙏 Versículos Incluídos

O app contém 14 versículos bíblicos sobre finanças incluindo:
- Dízimo (Malaquias 3:10, Provérbios 3:9-10)
- Generosidade (2 Coríntios 9:7, Lucas 6:38)
- Mordomia (Lucas 16:10, 1 Coríntios 4:2)
- Provisão (Filipenses 4:19, Mateus 6:33)
- Sabedoria Financeira (Provérbios 21:5, 22:7, 13:11)
- Contentamento (1 Timóteo 6:6-8, Hebreus 13:5)

---

**Desenvolvido com ❤️ e fé em Jesus Cristo**
