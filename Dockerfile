FROM node:22 AS base

WORKDIR /home/node/app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

FROM base AS production

CMD ["node", "src/index.mjs"]
