export NODE_ENV=production
# export NEXT_TELEMETRY_DISABLED=1

cd /app

corepack enable

corepack enable pnpm && corepack prepare pnpm@latest-11 --activate

if [ -f pnpm-lock.yaml ]; then pnpm run build; \
else echo "Lockfile not found." && exit 1; \
fi

cp -r /app/public /home/node/app/
cp -r /app/.next/standalone/. /home/node/app/

chown node:node /home/node/app/.next
cp -r /app/.next/static /home/node/app/.next/static

chown -R node:node /home/node/app

su - node

cd /home/node/app

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/next-config-js/output

node server.js
