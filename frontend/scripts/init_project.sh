#!/bin/sh
set -e

# ==============================================================================
# Frontend Boilerplate Initialization Script (Vite + React + TS + TailwindCSS)
# ==============================================================================

echo "---> Initializing Vite + React + TS project from boilerplate..."

# Define temporary directory for clean scaffolding
TEMP_DIR="/tmp/vite-project"
mkdir -p "$TEMP_DIR"
chown -R node:node "$TEMP_DIR"

# Scaffold the Vite template inside the temporary directory
(cd "$TEMP_DIR" && gosu node npm create vite@latest . -- --template react-ts)

# Move generated files (including hidden dotfiles) to current working directory (/app)
mv "$TEMP_DIR"/* "$TEMP_DIR"/.[!.]* .
rm -rf "$TEMP_DIR"
chown -R node:node .

echo "---> Installing dependencies..."
gosu node npm install

echo "---> Installing and configuring TailwindCSS with the Vite plugin..."
gosu node npm install -D tailwindcss @tailwindcss/vite

# Create tailwind configuration file
cat <<'EOF' > tailwind.config.js
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

# Configure Vite with React plugin, TailwindCSS plugin, and Docker port binding
cat <<'EOF' > vite.config.ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    host: '0.0.0.0', // Required for Docker container port mapping
    port: 5173,
  },
});
EOF

# Set single TailwindCSS import directive in CSS entry point
cat <<'EOF' > src/index.css
@import "tailwindcss";
EOF

# Create initial starter App component with Tailwind styling
cat <<'EOF' > src/App.tsx
function App() {
  return (
    <div className="min-h-screen bg-gray-900 text-white flex flex-col items-center justify-center font-sans">
      <header className="text-center p-4">
        <h1 className="text-5xl font-bold text-cyan-400 mb-4 animate-pulse">
          Vite + React + TailwindCSS + TypeScript
        </h1>
        <p className="text-lg text-gray-400">
          Your automated frontend environment is ready!
        </p>
        <p className="mt-8 text-sm text-gray-500">
          Start editing <code className="bg-gray-700 p-1 rounded">src/App.tsx</code>
        </p>
      </header>
    </div>
  );
}

export default App;
EOF

echo "---> Frontend project initialized successfully."
