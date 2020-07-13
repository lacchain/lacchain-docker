FROM node:12.1-alpine
WORKDIR /app
COPY package*.json ./
RUN npm i
COPY index.js ./index.js
RUN mkdir /validators
RUN mkdir /writers
ENTRYPOINT ["/usr/local/bin/npm", "start"]
