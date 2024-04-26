#for dev
FROM node:18-alpine as dev

WORKDIR /usr/app

COPY package*.json ./

RUN npm install

COPY . .

RUN chown -R node:node .

EXPOSE 3000

USER node

CMD ["npm", "run", "dev"]

#for prod
FROM node:18-alpine as prod

WORKDIR /usr/app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

RUN chown -R node:node .

EXPOSE 3000

USER node

ENTRYPOINT ["node","./src/index.js"]