FROM node:22-alpine
WORKDIR /app
COPY services/gateway/package.json services/gateway/package-lock.json ./services/gateway/
WORKDIR /app/services/gateway
RUN npm ci --omit=dev
WORKDIR /app
COPY services/shared/src ./services/shared/src
COPY services/gateway/src ./services/gateway/src
ENV NODE_ENV=production
USER node
WORKDIR /app/services/gateway
EXPOSE 3000
CMD ["node", "src/index.js"]
