FROM node:16.15-buster-slim

WORKDIR "/app"

COPY package.json package-lock.json /app/
RUN npm i
COPY index.js /app/
CMD [ "node", "index.js" ]
