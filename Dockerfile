FROM node:latest AS builder

WORKDIR /src
COPY panel .

RUN npm install -g pnpm turbo
RUN npm install
RUN pnpm ship
RUN rm -rf /src/.git

FROM ghcr.io/pterodactyl/panel:latest
WORKDIR /app
COPY --from=builder /src/ /app/
