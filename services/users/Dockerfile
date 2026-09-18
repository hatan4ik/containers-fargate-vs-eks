FROM node:22-alpine
WORKDIR /app
COPY services/users/package.json services/users/package-lock.json ./services/users/
WORKDIR /app/services/users
RUN npm ci --omit=dev
WORKDIR /app
COPY services/shared/src ./services/shared/src
COPY services/users/src ./services/users/src
ENV NODE_ENV=production
USER node
WORKDIR /app/services/users
EXPOSE 3001
CMD ["node", "src/index.js"]
