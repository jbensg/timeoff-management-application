# -------------------------------------------------------------------
# Minimal dockerfile from alpine base
#
# Instructions:
# =============
# 1. Create an empty directory and copy this file into it.
#
# 2. Create image with: 
#   docker build --tag timeoff:latest .
#
# 3. Run with: 
#   docker run -d -p 3000:3000 --name alpine_timeoff timeoff
#
# 4. Login to running container (to update config (vi config/app.json): 
#   docker exec -ti --user root alpine_timeoff /bin/sh
# --------------------------------------------------------------------
FROM node:12-alpine as dependencies

RUN apk add --no-cache \
    nodejs npm 

COPY package.json  .
RUN npm install 

FROM node:12-alpine

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.docker.cmd="docker run -d -p 3000:3000 --name alpine_timeoff"


RUN apk add --no-cache \
    nodejs npm \
    vim

# Crear el usuario 'app' y el grupo 'app'.
RUN addgroup -S app && adduser -S -G app app --home /app

# Crear el directorio 'data' y asignar permisos COMO ROOT.
RUN mkdir -p /app/data && chown app:app /app/data

WORKDIR /app
# Primero copiamos todos los archivos de la aplicación
COPY . /app
COPY --from=dependencies node_modules ./node_modules

# ¡IMPORTANTE! Cambiar los permisos *DESPUÉS* de copiar los archivos.
# Aseguramos que el usuario 'app' pueda escribir en 'public/css'.
# Esto se hace *después* de que 'COPY . /app' haya traído los archivos,
# para que 'chown' pueda aplicarse a los archivos recién copiados.
RUN mkdir -p /app/public/css && chown -R app:app /app/public

USER app

# Ahora, el usuario 'app' debería tener permisos para escribir en /app/public/css/
RUN npm run compile-sass

CMD npm start

EXPOSE 3000