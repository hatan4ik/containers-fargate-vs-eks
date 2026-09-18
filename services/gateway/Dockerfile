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
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 CMD node -e "require('http').get('http://127.0.0.1:' + (process.env.PORT || 3000) + '/healthz', response => process.exit(response.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"
CMD ["node", "src/index.js"]
