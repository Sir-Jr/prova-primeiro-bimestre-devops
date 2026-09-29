# ---------- Estágio 1: dependências de produção ----------
FROM node:22-alpine AS deps

WORKDIR /app

# Só os manifestos primeiro: a camada do npm ci fica em cache enquanto as dependências não mudam
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

# ---------- Estágio 2: runtime ----------
FROM node:22-alpine AS runtime

ENV NODE_ENV=production \
    PORT=3000

WORKDIR /app

# Código com dono root e só leitura para os demais (644/755): o processo roda como "node"
# (usuário não-root da imagem oficial) e, se for comprometido, não consegue reescrever o próprio código.
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY src ./src

USER node

EXPOSE 3000

# wget vem no BusyBox do Alpine; o /health só confirma que a API está no ar
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=5 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "src/server.js"]
