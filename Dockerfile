# ---------- Stage 1: install production dependencies ----------
FROM node:20-slim AS deps
WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev


# ---------- Stage 2: final runtime image ----------
FROM node:20-slim AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copy only what is needed to run
COPY --from=deps /app/node_modules ./node_modules
COPY package*.json ./
COPY src ./src
COPY public ./public

EXPOSE 3000
CMD ["npm", "start"]

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --spider -q http://localhost:3000/health || exit 1
