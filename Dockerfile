FROM node:15-alpine

WORKDIR /home/node/app

RUN apk update && apk add bash curl

RUN mkdir -p /home/node/app/node_modules

COPY package*.json ./

RUN npm install

COPY . .

RUN chown -R node:node /home/node/app

USER node

EXPOSE 3000

CMD [ "npm", "run", "start" ]
