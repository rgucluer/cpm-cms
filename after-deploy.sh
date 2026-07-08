
export NODE_ENV=production
# export NEXT_TELEMETRY_DISABLED=1

cd /app

if [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm run build; \
else echo "Lockfile not found." && exit 1; \
fi

cp -r /app/public /home/node/app/
cp -r /app/.next/standalone/. /home/node/app/

mkdir /home/node/app/.next
chown node:node /home/node/app/.next
cp -r /app/.next/static /home/node/app/.next/static

chown -R node:node /home/node/app

su - node

cd /home/node/app

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/next-config-js/output

node server.js
