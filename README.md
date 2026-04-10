# Finance Companion

A comprehensive personal finance management application built with Flutter that helps users track expenses, manage income, set financial goals, and visualize spending patterns with beautiful charts and analytics.

## Table of Contents
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Design Decisions](#design-decisions)
- [Future Enhancements](#future-enhancements)
- [Assignment Requirements](#assignment-requirements)

## Features

### 1. Authentication System
- Complete user authentication flow with sign up and login
- Persistent session management using SharedPreferences
- User profile management with avatars
- Secure logout functionality
- Email validation and duplicate user detection

### 2. Dashboard & Home
- Real-time balance overview showing total income and expenses
- Quick stats cards for current month income, expenses, and savings
- Interactive spending trend chart (last 7 days)
- Category-wise expense breakdown with visual indicators
- Recent transactions list with quick access

### 3. Transaction Management
- Add, edit, and delete transactions
- Support for both income and expense transactions
- Pre-defined categories with custom icons and colors:
  - **Expense**: Food & Dining, Shopping, Transportation, Entertainment, Bills & Utilities, Healthcare, Education, Other
  - **Income**: Salary, Freelance, Investment, Gift, Other
- Transaction filtering and sorting
- Detailed transaction history with search functionality
- Date-based transaction viewing

### 4. Financial Goals
- Create and track financial goals with target amounts
- Visual progress indicators with percentage completion
- Deadline tracking with days remaining
- Goal contribution management
- Mark goals as complete
- Overdue goal detection and highlighting

### 5. Statistics & Analytics
- Comprehensive spending insights
- Interactive charts using fl_chart:
  - Monthly spending trends
  - Category-wise expense distribution (pie charts)
  - Income vs Expense comparison
  - Weekly/Monthly spending patterns
- Spending category analysis
- Budget vs actual spending visualization

### 6. Settings & Profile
- User profile management
- Theme switching (Light/Dark mode)
- Privacy policy and terms
- App preferences
- Logout functionality

### 7. Additional Features
- Beautiful splash screen with animations
- Responsive UI that works on different screen sizes
- Custom fonts (Nunito family)
- Smooth animations and transitions
- Empty states with helpful messages
- Error handling with user-friendly messages

## Tech Stack

### Core Framework
- **Flutter SDK**: ^3.11.0
- **Dart**: ^3.11.0

### State Management
- **flutter_bloc**: ^8.1.3 - Business Logic Component pattern for state management
- **equatable**: ^2.0.5 - Value equality for models and states

### Local Storage
- **sqflite**: ^2.3.0 - SQLite database for transactions and goals
- **shared_preferences**: ^2.2.2 - Key-value storage for user sessions and preferences
- **path_provider**: ^2.1.1 - File system path access

### UI & Visualization
- **fl_chart**: ^0.66.0 - Beautiful, animated charts for statistics
- **google_fonts**: ^6.1.0 - Custom typography
- **lottie**: ^3.1.0 - Smooth animations
- **flutter_svg**: ^2.0.10+1 - SVG asset support

### Utilities
- **intl**: ^0.19.0 - Internationalization and date formatting
- **uuid**: ^4.2.1 - Unique ID generation
- **path**: ^1.9.0 - File path manipulation

### Development Tools
- **flutter_test**: SDK - Testing framework
- **flutter_lints**: ^6.0.0 - Flutter recommended linting rules
- **flutter_launcher_icons**: ^0.14.1 - Custom app icons

## Architecture

### BLoC Pattern
The application follows the **BLoC (Business Logic Component)** pattern for state management, ensuring:
- Clear separation of business logic from UI
- Predictable state management
- Testable code
- Reactive programming with streams

### Key BLoCs
1. **AuthBloc**: Manages authentication state, login, signup, and logout
2. **TransactionBloc**: Handles all transaction CRUD operations
3. **GoalBloc**: Manages financial goals and progress tracking
4. **ThemeBloc**: Controls app theme (light/dark mode)

### Data Flow
```
UI (Screens/Widgets)
    ↓ Events
BLoC Layer (Business Logic)
    ↓ Requests
Service Layer (DatabaseService, AuthService)
    ↓ CRUD Operations
Data Layer (SQLite, SharedPreferences)
```

### Database Schema

**Transactions Table**
```sql
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  amount REAL NOT NULL,
  type TEXT NOT NULL,
  category TEXT NOT NULL,
  date TEXT NOT NULL,
  description TEXT,
  created_at TEXT NOT NULL
)
```

**Goals Table**
```sql
CREATE TABLE goals (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  current_amount REAL NOT NULL,
  deadline TEXT NOT NULL,
  created_at TEXT NOT NULL,
  is_completed INTEGER NOT NULL
)
```

**Categories Table**
```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon_code INTEGER NOT NULL,
  color_code INTEGER NOT NULL,
  type TEXT NOT NULL
)
```

## Project Structure

```
lib/
├── blocs/                    # BLoC state management
│   ├── auth/                 # Authentication BLoC
│   ├── transaction/          # Transaction management BLoC
│   ├── goal/                 # Goal tracking BLoC
│   └── theme/                # Theme switching BLoC
├── core/                     # Core utilities and constants
│   ├── constants/            # App-wide constants
│   │   ├── app_colors.dart   # Color palette
│   │   ├── app_strings.dart  # Text constants
│   │   ├── app_themes.dart   # Theme configurations
│   │   └── app_styles.dart   # Text styles
│   ├── utils/                # Utility functions
│   │   ├── currency_formatter.dart
│   │   ├── date_helper.dart
│   │   └── validators.dart
│   └── widgets/              # Reusable widgets
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── empty_state.dart
├── models/                   # Data models
│   ├── user.dart
│   ├── transaction.dart
│   ├── goal.dart
│   ├── category.dart
│   └── spending_insight.dart
├── screens/                  # UI screens
│   ├── auth/                 # Authentication screens
│   ├── home/                 # Dashboard/Home screen
│   ├── transactions/         # Transaction management
│   ├── goals/                # Goal tracking
│   ├── statistics/           # Analytics and charts
│   ├── settings/             # App settings
│   ├── profile/              # User profile
│   └── splash/               # Splash screen
├── services/                 # Business logic services
│   ├── database_service.dart # SQLite database operations
│   └── auth_service.dart     # Authentication service
└── main.dart                 # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK ^3.11.0 or higher
- Dart SDK ^3.11.0 or higher
- Android Studio / VS Code with Flutter extensions
- iOS Simulator (Mac) or Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd finance_companion
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build for production**
   ```bash
   # Android
   flutter build apk --release

   # iOS
   flutter build ios --release
   ```

### Running Tests
```bash
flutter test
```

### Generating App Icons
```bash
flutter pub run flutter_launcher_icons
```

## Design Decisions

### 1. BLoC Pattern over Provider
- Chosen for better separation of concerns
- Easier to test business logic independently
- Better suited for complex state management
- Stream-based architecture for reactive UI

### 2. SQLite for Local Storage
- Relational data structure fits finance data model
- Support for complex queries and joins
- Better performance for large datasets
- ACID compliance for data integrity

### 3. Simulated Authentication
- Uses SharedPreferences for persistent sessions
- Simulated backend with 800ms delay for realistic UX
- Easy to replace with real API integration
- Passwords stored in plain text (would be hashed in production)

### 4. Category System
- Pre-seeded with common categories
- Icon and color coding for quick recognition
- Separate categories for income and expense
- Database-driven for potential future customization

### 5. Date-based Organization
- All transactions and goals are date-aware
- Supports filtering by date ranges
- Time-series analysis for trends
- Deadline tracking for goals

### 6. Material Design
- Follows Material Design 3 guidelines
- Custom color palette with semantic meaning
- Consistent spacing and typography
- Responsive layouts

## Assumptions

1. **Authenticated User**: Users must sign up/login to use the app
2. **Single Currency**: App assumes a single currency (no multi-currency support)
3. **Single User per Device**: One active user per device installation
4. **Offline-First**: All data stored locally, no cloud sync
5. **Manual Entry**: Transactions are manually entered (no bank integration)
6. **Gregorian Calendar**: Uses standard date system
7. **No Budgets**: Focus on tracking rather than budgeting
8. **Simple Goals**: Goals are savings-focused, not category-based budgets

## Future Enhancements

### Short-term
- [ ] Budget management per category
- [ ] Recurring transaction support
- [ ] Transaction attachments (receipts)
- [ ] Export data to CSV/PDF
- [ ] Biometric authentication
- [ ] Search and advanced filtering

### Medium-term
- [ ] Cloud backup and sync
- [ ] Multi-device support
- [ ] Category customization
- [ ] Spending alerts and notifications
- [ ] Multiple account support
- [ ] Bill reminders

### Long-term
- [ ] Bank account integration
- [ ] AI-powered insights and recommendations
- [ ] Investment tracking
- [ ] Tax calculation and reporting
- [ ] Multi-currency support
- [ ] Family/shared accounts
- [ ] Merchant categorization

## Assignment Requirements

This application fulfills all assignment requirements:

### 1. Authentication System
- ✅ Complete sign up and login flow
- ✅ User session management
- ✅ Persistent authentication state
- ✅ Logout functionality
- ✅ User profile display

### 2. State Management (BLoC)
- ✅ BLoC pattern implemented throughout
- ✅ Reactive UI with BlocBuilder
- ✅ Event-driven architecture
- ✅ Proper state transitions
- ✅ Error state handling

### 3. Local Storage
- ✅ SQLite database for structured data (transactions, goals, categories)
- ✅ SharedPreferences for key-value data (user session, preferences)
- ✅ CRUD operations for all entities
- ✅ Data persistence across app restarts

### 4. UI/UX Design
- ✅ Clean, modern interface with Material Design
- ✅ Custom color palette and typography
- ✅ Smooth animations and transitions
- ✅ Responsive layouts
- ✅ Empty states and loading indicators
- ✅ Error handling with user feedback

### 5. Features Implementation
- ✅ Dashboard with financial overview
- ✅ Transaction management (add, edit, delete, view)
- ✅ Goal tracking with progress visualization
- ✅ Statistics with charts and analytics
- ✅ Settings and preferences
- ✅ Category-based organization

### 6. Code Quality
- ✅ Clean architecture with separation of concerns
- ✅ Reusable widgets and utilities
- ✅ Consistent code style with linting
- ✅ Proper error handling
- ✅ Type-safe models with Equatable
- ✅ Commented code where necessary

### 7. Additional Features
- ✅ Dark mode support
- ✅ Splash screen with animations
- ✅ Custom app icon
- ✅ Date-based filtering and analysis
- ✅ Form validation
- ✅ Snackbar notifications

## Screenshots

The app includes:
- Beautiful splash screen with Lottie animations
- Clean authentication UI
- Interactive dashboard with charts
- Intuitive transaction entry
- Visual goal tracking
- Comprehensive statistics
- Modern settings interface

## Contact & Support

For questions or support, please contact the development team.

---

**Built with ❤️ using Flutter**

*This is a demonstration project showcasing Flutter development skills, BLoC state management, local database integration, and modern mobile UI/UX design.*
