#for dev
FROM node:18-alpine as dev

WORKDIR /usr/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]


#for prod
FROM node:18-alpine as prod

WORKDIR /usr/app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

EXPOSE 3000

ENTRYPOINT ["node","./src/index.js"]