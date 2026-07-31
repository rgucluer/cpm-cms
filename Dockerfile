# To use this Dockerfile, you have to set `output: 'standalone'` in your next.config.js file.
# From https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile

ARG NODE_VERSION=24.18-alpine

FROM node:${NODE_VERSION} AS base 

# Install dependencies only when needed
FROM base AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /app

RUN corepack enable

# Install dependencies based on the preferred package manager
COPY package.json pnpm-lock.yaml* pnpm-workspace.yaml ./

# Install project dependencies with frozen lockfile for reproducible builds
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
  if [ -f pnpm-lock.yaml ]; then \
    corepack enable pnpm && corepack prepare pnpm@latest-11 --activate && pnpm install --frozen-lockfile; \
  else \
    echo "No lockfile found." && exit 1; \
  fi


FROM base AS builder
WORKDIR /app

COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* pnpm-workspace.yaml ./

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry during the build.
# ENV NEXT_TELEMETRY_DISABLED 1

ENV NODE_ENV production

RUN corepack enable

RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
  if [ -f pnpm-lock.yaml ]; then \
    corepack enable pnpm && corepack prepare pnpm@latest-11 --activate; \
  else \
    echo "No lockfile found." && exit 1; \
  fi

COPY --chown=node:node . .
COPY --from=deps --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node --chmod=744 ./after-deploy.sh ./

EXPOSE 3000

ENV PORT 3000
