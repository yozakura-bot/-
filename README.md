# MinecraftWeb

This is a Minecraft-inspired web application built with React, TypeScript, and Express. The project features a fully functional backend API with user authentication, character management, and a dynamic world system.

## Features

- User authentication with JWT and Discord OAuth
- Character creation and management
- Real-time server status monitoring
- World map with boss locations
- Player rankings and leaderboards
- Forum system with posts and likes

## Technologies Used

- Frontend: React, TypeScript, Tailwind CSS, Framer Motion
- Backend: Express, Prisma, SQLite
- Authentication: JWT, Passport.js, Discord OAuth
- Deployment: Vercel

## Getting Started

### Prerequisites

- Node.js 18.x or higher
- npm or yarn

### Installation

1. Clone the repository
```bash
git clone https://github.com/yozakuraDev/MinecraftWeb.git
cd MinecraftWeb
```

2. Install dependencies
```bash
npm install
```

3. Set up environment variables
Create a `.env` file with the following variables:
```
PORT=3001
JWT_SECRET=your_secure_jwt_secret
NODE_ENV=development
VITE_API_URL=http://localhost:3001/api
DISCORD_CLIENT_ID=your_discord_client_id
DISCORD_CLIENT_SECRET=your_discord_client_secret
DISCORD_CALLBACK_URL=http://localhost:3001/api/auth/discord/callback
SESSION_SECRET=your_secure_session_secret
DATABASE_URL="file:./dev.db"
```

4. Run the development server
```bash
npm run dev
```

## Deployment

This project is configured for deployment on Vercel. Use the following command to deploy:

```bash
npm run deploy
```

## License

This project is licensed under the MIT License.#   M i n e c r a f t W e b  
 #   T e s t  
 