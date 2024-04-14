FROM node:latest AS builder

WORKDIR /src
COPY panel .

RUN npm install -g pnpm turbo
RUN npm install
RUN pnpm ship

FROM ghcr.io/pterodactyl/panel:latest
COPY --from=builder /src/ /app/
#CMD
