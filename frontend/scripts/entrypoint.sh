#!/bin/sh
set -e

# ==============================================================================
# Frontend Runtime Entrypoint Script
# ==============================================================================

# --- User and Permission Management ---
# Synchronize container node user UID and GID with host user
PUID=${HOST_UID:-1000}
PGID=${HOST_GID:-1000}

CURRENT_UID=$(id -u node)
CURRENT_GID=$(id -g node)

if [ "$CURRENT_UID" != "$PUID" ] || [ "$CURRENT_GID" != "$PGID" ]; then
    echo "---> Updating node user UID to $PUID and GID to $PGID..."
    groupmod -o -g "$PGID" node
    usermod -o -u "$PUID" node
fi

# --- Project Initialization (Boilerplate) ---
# If package.json is missing, run the boilerplate scaffold script
if [ ! -f "package.json" ]; then
    echo "---> package.json not found. Running boilerplate bootstrap..."
    if [ -f "/app/scripts/init_project.sh" ]; then
        sh /app/scripts/init_project.sh
    elif [ -f "/usr/local/bin/init_project.sh" ]; then
        sh /usr/local/bin/init_project.sh
    fi
fi

# Set proper ownership of /app and node_modules before running npm commands
echo "---> Setting runtime permissions..."
chown -R node:node /app

# --- Runtime Dependency Check ---
# Detect if package.json has changed or if node_modules is missing
CURRENT_HASH=$(md5sum package.json 2>/dev/null || cksum package.json)
STORED_HASH=$(cat node_modules/.package.hash 2>/dev/null || true)

if [ ! -d "node_modules" ] || [ "$CURRENT_HASH" != "$STORED_HASH" ]; then
    echo "---> Dependencies changed or missing. Syncing node_modules..."
    gosu node npm install
    echo "$CURRENT_HASH" > node_modules/.package.hash 2>/dev/null || true
fi

# Execute the main container command as the non-root node user
echo "---> Starting frontend development server..."
exec gosu node "$@"
