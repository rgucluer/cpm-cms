# To use this Dockerfile, you have to set `output: 'standalone'` in your next.config.js file.
# From https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile

FROM node:22.17.0-alpine AS base
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat python3 make g++ git curl bash

WORKDIR /home/node/app
ENV NODE_ENV=production

RUN npm install --global corepack@latest

RUN corepack enable pnpm
RUN corepack use pnpm@latest-10
RUN chown -R node:node .

# ========================================
# Dependencies Stage
# ========================================

# Install dependencies only when needed
FROM base AS deps

WORKDIR /home/node/app
ENV NODE_ENV=production

# Install dependencies based on the preferred package manager
COPY --chown=node:node package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi

# ========================================
# Runner Stage
# ========================================
FROM base AS runner

WORKDIR /home/node/app
ENV NODE_ENV production

# Uncomment the following line in case you want to disable telemetry during runtime.
ENV NEXT_TELEMETRY_DISABLED 1

COPY --from=deps --chown=node:node /home/node/app/node_modules ./node_modules

USER node

EXPOSE 3000

ENV PORT 3000

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/next-config-js/output
CMD HOSTNAME="0.0.0.0" node server.js
