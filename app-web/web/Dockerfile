FROM node:18 AS builder

WORKDIR /usr/src/app

COPY web/package.json .

RUN npm install

COPY web .

# next stage
FROM node:18-slim

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app .

EXPOSE 3000

CMD ["npm","start"]