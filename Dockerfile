FROM node:20 AS base

WORKDIR /home/node/app

COPY package*.json ./

RUN npm i

COPY . .

FROM base AS production

CMD ["node", "src/index.mjs"]
