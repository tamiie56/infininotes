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
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── models/
│   │   ├── routes/
│   │   └── utils/
│   ├── app.js
│   └── server.js
└── frontend/
    └── lib/
        ├── core/
        │   ├── constants/
        │   ├── theme/
        │   └── utils/
        ├── data/
        │   ├── models/
        │   ├── providers/
        │   └── services/
        └── presentation/
            ├── screens/
            └── widgets/
```

---

## Features

| Feature | Status |
| --- | --- |
| Email / Password Authentication | Done |
| Google Sign-In | Done |
| Create, Edit, Delete Notes | Done |
| Color Coding | Done |
| Pin Notes | Done |
| Archive Notes | Done |
| Trash with Restore | Done |
| Labels / Tags | Done |
| Search Notes | Done |
| Checklist Support | Done |
| Reminders | Done |
| Dark / Light Mode Toggle | Done |
| Grid / List View Toggle | Done |
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

```
npm run dev
```

### 3. Frontend setup

```
cd frontend
flutter pub get
flutter run
```

---

## Build APK

```
flutter build apk --release
```

APK will be at `build/app/outputs/flutter-apk/app-release.apk`

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

---

## Changelog

### v1.0.0
- Initial release
- Email and Google Sign-In
- Full notes CRUD with color coding
- Labels, search, archive, trash
- Checklist and reminder support
- Dark and light mode toggle
- Custom app icon

---

## Developer

Made by [tamiie56](https://github.com/tamiie56)
