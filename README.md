# ∆nfiniNotes — Flutter Notes App

A Google Keep-like notes app built with Flutter and Node.js for Android.

## Download APK

Get the latest release from [Releases](https://github.com/tamiie56/infininotes/releases).

---

## Project Structure

```
infininotes/
├── backend/
│   ├── src/
│   │   ├── config/
│   │   │   ├── db.js
│   │   │   └── jwt.js
│   │   ├── controllers/
│   │   │   ├── auth.controller.js
│   │   │   ├── note.controller.js
│   │   │   └── label.controller.js
│   │   ├── middleware/
│   │   │   ├── auth.middleware.js
│   │   │   └── validate.middleware.js
│   │   ├── models/
│   │   │   ├── user.model.js
│   │   │   ├── note.model.js
│   │   │   └── label.model.js
│   │   ├── routes/
│   │   │   ├── auth.routes.js
│   │   │   ├── note.routes.js
│   │   │   └── label.routes.js
│   │   └── utils/
│   │       ├── token.utils.js
│   │       └── reminder.utils.js
│   ├── app.js
│   └── server.js
└── frontend/
    └── lib/
        ├── core/
        │   ├── constants/
        │   │   ├── api_constants.dart
        │   │   └── app_constants.dart
        │   ├── theme/
        │   │   └── app_theme.dart
        │   └── utils/
        │       └── color_utils.dart
        ├── data/
        │   ├── models/
        │   │   ├── user_model.dart
        │   │   ├── note_model.dart
        │   │   └── label_model.dart
        │   ├── providers/
        │   │   ├── auth_provider.dart
        │   │   ├── note_provider.dart
        │   │   ├── label_provider.dart
        │   │   └── theme_provider.dart
        │   └── services/
        │       ├── api_service.dart
        │       ├── auth_service.dart
        │       ├── note_service.dart
        │       └── label_service.dart
        └── presentation/
            ├── screens/
            │   ├── auth/
            │   │   ├── login_screen.dart
            │   │   └── register_screen.dart
            │   ├── home/
            │   │   └── home_screen.dart
            │   ├── note/
            │   │   └── note_edit_screen.dart
            │   └── label/
            │       └── label_screen.dart
            └── widgets/
                ├── note_card.dart
                └── search_bar_widget.dart
```

---

## Features

| Feature | Status |
| --- | --- |
| Email / Password Authentication | Done |
| Google Sign-In | Done |
| Create, Edit, Delete Notes | Done |
| Color Coding for Notes | Done |
| Pin Notes | Done |
| Archive Notes | Done |
| Trash with Restore | Done |
| Labels / Tags | Done |
| Search Notes | Done |
| Checklist Support | Done |
| Reminders | Done |
| Dark / Light Mode Toggle | Done |
| Grid / List View Toggle | Done |
| Custom App Icon | Done |
| Android APK Build | Done |

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Frontend | Flutter |
| Backend | Node.js + Express |
| Database | MongoDB Atlas |
| Authentication | JWT + Google OAuth 2.0 |
| State Management | Provider |
| Hosting | Render (Backend) |

---

## Setup Instructions

### Prerequisites

- Flutter SDK
- Node.js
- MongoDB Atlas account
- Google Cloud Console project

### 1. Clone the repo

```
git clone https://github.com/tamiie56/infininotes.git
cd infininotes
```

### 2. Backend setup

```
cd backend
npm install
```

Create a `.env` file in the `backend` folder:

```
PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
JWT_EXPIRE=7d
JWT_REFRESH_SECRET=your_jwt_refresh_secret
JWT_REFRESH_EXPIRE=30d
GOOGLE_CLIENT_ID=your_google_client_id
```

Start the backend server:

```
npm run dev
```

### 3. Frontend setup

Open `frontend/lib/core/constants/api_constants.dart` and update the base URL:

```dart
static const String baseUrl = 'http://your-backend-url/api';
```

Then install dependencies and run:

```
cd frontend
flutter pub get
flutter run
```

### 4. Google Sign-In setup

- Go to [Google Cloud Console](https://console.cloud.google.com)
- Create a new project
- Go to APIs & Services → OAuth consent screen → Configure
- Go to APIs & Services → Credentials → Create OAuth Client ID
- Create an Android client with your package name `com.infininotes.infininotes` and SHA-1 fingerprint
- Create a Web application client and add your backend Client ID to `.env` as `GOOGLE_CLIENT_ID`
- Enable the People API

### 5. MongoDB Atlas setup

- Create a free cluster at [mongodb.com/cloud/atlas](https://mongodb.com/cloud/atlas)
- Create a database user
- Whitelist your IP (or allow all with `0.0.0.0/0`)
- Copy the connection string to your `.env` as `MONGO_URI`

---

## Build APK

```
flutter build apk --release
```

APK will be at `build/app/outputs/flutter-apk/app-release.apk`

---

## API Endpoints

| Method | Endpoint | Description |
| --- | --- | --- |
| POST | /api/auth/register | Register new user |
| POST | /api/auth/login | Login with email/password |
| POST | /api/auth/google | Login with Google |
| POST | /api/auth/refresh | Refresh access token |
| POST | /api/auth/logout | Logout |
| GET | /api/auth/me | Get current user |
| GET | /api/notes | Get all notes |
| POST | /api/notes | Create note |
| PUT | /api/notes/:id | Update note |
| DELETE | /api/notes/:id | Delete note |
| PATCH | /api/notes/:id/pin | Toggle pin |
| PATCH | /api/notes/:id/archive | Toggle archive |
| PATCH | /api/notes/:id/trash | Toggle trash |
| GET | /api/labels | Get all labels |
| POST | /api/labels | Create label |
| PUT | /api/labels/:id | Update label |
| DELETE | /api/labels/:id | Delete label |

---

## Dependencies

| Package | Purpose |
| --- | --- |
| `provider` | State management |
| `http` | HTTP requests |
| `flutter_secure_storage` | Secure token storage |
| `google_sign_in` | Google authentication |
| `flutter_local_notifications` | Reminder notifications |
| `flutter_colorpicker` | Note color picker |
| `flutter_launcher_icons` | Custom app icon |
| `shared_preferences` | Local storage |
| `intl` | Date formatting |
| `uuid` | Unique ID generation |

---

## Changelog

### v1.0.0
- Initial release
- Email and Google Sign-In
- Full notes CRUD with color coding
- Pin, archive, and trash support
- Labels and tags
- Search notes
- Checklist support
- Reminder notifications
- Dark and light mode toggle
- Grid and list view toggle
- Custom app icon

---

## About

∆nfiniNotes is a feature-rich notes app inspired by Google Keep, built for Android using Flutter and a Node.js backend.

## Developer

Made by [tamiie56](https://github.com/tamiie56)
