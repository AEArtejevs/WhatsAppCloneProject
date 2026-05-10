# WhatsAppCloneProject

This repository contains both parts of the project:

- `WhatsAppClone/` - iOS SwiftUI mobile application
- `whatsappclone-backend/` - NestJS backend API

The iOS app needs the backend running locally before login, contacts, chats, and messages can work.

---

## Required Software

To run this project, install:

- macOS
- Xcode
- iOS Simulator through Xcode
- Node.js
- npm
- PostgreSQL
- pgAdmin 4 or another PostgreSQL database tool
- Git

Check Node.js and npm:

```bash
node -v
npm -v
```

---

## Project Structure

```text
WhatsAppCloneProject/
├── WhatsAppClone/
│   └── iOS SwiftUI application
│
├── whatsappclone-backend/
│   └── NestJS backend API
│
├── .gitignore
└── README.md
```

---

## PostgreSQL Database Setup

Create a PostgreSQL database named:

```text
whatsapp_clone
```

The project expects this database connection:

```env
DATABASE_URL="postgresql://whatsapp_user:whatsapp_password@localhost:5432/whatsapp_clone?schema=public"
```

You can either create this PostgreSQL user:

```text
username: whatsapp_user
password: whatsapp_password
database: whatsapp_clone
```

or change the `.env` file to match your own PostgreSQL username and password.

---

## Backend Setup

Open terminal and go to the backend folder:

```bash
cd whatsappclone-backend
```

Install backend dependencies:

```bash
npm install
```

Create local environment file:

```bash
cp .env.example .env
```

Open `.env` and make sure it contains the correct database URL:

```env
DATABASE_URL="postgresql://whatsapp_user:whatsapp_password@localhost:5432/whatsapp_clone?schema=public"
```

Generate Prisma client:

```bash
npx prisma generate
```

Run database migrations:

```bash
npx prisma migrate dev
```

Start backend server:

```bash
npm run start:dev
```

Backend should now run at:

```text
http://localhost:3000
```

---

## iOS App Setup

Open the iOS project in Xcode:

```text
WhatsAppClone/WhatsAppClone.xcodeproj
```

Before running the iOS app, make sure the backend is already running:

```text
http://localhost:3000
```

The app uses this backend URL inside:

```text
APIService.swift
```

Run the app using an iPhone Simulator from Xcode.

---

## Testing the App

Recommended test flow:

1. Start PostgreSQL.
2. Start the backend:

```bash
cd whatsappclone-backend
npm run start:dev
```

3. Open the iOS project in Xcode:

```text
WhatsAppClone/WhatsAppClone.xcodeproj
```

4. Run the app in an iPhone Simulator.
5. Register the first user.
6. Register or login as another user.
7. Open the contacts screen.
8. Select a contact.
9. Send a message.
10. Open the app with another user in a second simulator.
11. Open the chat and check received messages.

The project can be tested with two iPhone simulators at the same time.

---

## Backend API Summary

### Authentication

Register a new user:

```http
POST /auth/register
```

Login existing user:

```http
POST /auth/login
```

Get current logged-in user:

```http
GET /auth/me
```

This route requires JWT token.

---

### Users

Get contacts:

```http
GET /users
```

Returns all registered users except the currently logged-in user.

---

### Chats

Get current user's chats:

```http
GET /chats
```

Create or open private chat:

```http
POST /chats/private
```

---

### Messages

Get all messages from selected chat:

```http
GET /chats/:chatId/messages
```

Send message to selected chat:

```http
POST /chats/:chatId/messages
```

---

## Notes

The app uses REST API requests.

Messages are refreshed using simple polling in the chat detail screen. WebSockets are not used.

The block/unblock feature is stored locally on the iOS device using `UserDefaults`.

The `.env` file is not included in GitHub. Use `.env.example` to create your own local `.env`.

---

## Files and Folders That Should Not Be Committed

These are ignored by `.gitignore`:

```text
.env
node_modules/
dist/
DerivedData/
build/
```

---

## Technologies Used

### iOS

- Swift
- SwiftUI
- MVVM-style structure
- URLSession
- UserDefaults
- Asset colors for light and dark mode

### Backend

- NestJS
- PostgreSQL
- Prisma ORM
- JWT authentication
- bcrypt password hashing