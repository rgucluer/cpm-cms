# syntax=docker.io/docker/dockerfile:1

# To use this Dockerfile, you have to set `output: 'standalone'` in your next.config.js file.
# From https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile

FROM node:22-alpine AS base
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat python3 make g++ git curl bash
RUN npm install --global corepack@latest
RUN corepack enable pnpm

# ========================================
# Dependencies Stage
# ========================================

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then pnpm i --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi

# ========================================
# Builder Stage
# ========================================
FROM base AS builder
RUN corepack enable pnpm
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry during the build.
ENV NEXT_TELEMETRY_DISABLED 1

RUN \
  if [ -f yarn.lock ]; then yarn run build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then pnpm run build; \
  else echo "Lockfile not found." && exit 1; \
  fi

# ========================================
# Runner Stage
# ========================================
FROM base AS runner
RUN corepack enable pnpm
WORKDIR /app

ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

# Uncomment the following line in case you want to disable telemetry during runtime.
ENV NEXT_TELEMETRY_DISABLED 1

RUN adduser --system --uid 1001 nextjs -G node

COPY --chown=nextjs:node . .
COPY --from=deps --chown=nextjs:node /app/node_modules ./node_modules

# Remove this line if you do not have this folder
COPY --from=builder --chown=nextjs:node /app/public /app/public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:node .next

RUN mkdir /app/public/media
RUN chown nextjs:node /app/public/media

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:node /app/.next/standalone ./
COPY --from=builder --chown=nextjs:node /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/next-config-js/output
CMD node server.js
