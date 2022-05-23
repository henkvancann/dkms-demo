FROM node:16.15-buster-slim

WORKDIR /usr/src/app
COPY package*.json ./

RUN npm install

COPY . .

CMD [ "node", "index.js" ]
