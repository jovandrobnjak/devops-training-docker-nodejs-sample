ARG NODE_VERSION=18.0.0

#--base--
FROM node:${NODE_VERSION}-alpine as base

WORKDIR /usr/src/app

COPY package*.json ./

EXPOSE 3000

#--dev--
FROM base as dev

RUN npm ci --include=dev

RUN chown -R node:node .

USER node

COPY . .

CMD ["npm", "run", "dev"]

#--prod--
FROM base as prod

RUN npm ci --omit=dev

RUN chown -R node:node .

USER node

COPY . .

ENTRYPOINT ["node","./src/index.js"]