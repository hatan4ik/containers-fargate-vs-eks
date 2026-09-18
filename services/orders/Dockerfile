FROM node:22-alpine
WORKDIR /app
COPY services/orders/package.json services/orders/package-lock.json ./services/orders/
WORKDIR /app/services/orders
RUN npm ci --omit=dev
WORKDIR /app
COPY services/shared/src ./services/shared/src
COPY services/orders/src ./services/orders/src
ENV NODE_ENV=production
USER node
WORKDIR /app/services/orders
EXPOSE 3002
CMD ["node", "src/index.js"]
