FROM node:20-alpine

WORKDIR /app/api

COPY api/package*.json ./
RUN npm ci --only=production

COPY api/ .

EXPOSE 3000

CMD ["node", "app.js"]
