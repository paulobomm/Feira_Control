# FeiraControl

Sistema para gerenciamento de barracas de feira — 3 microserviços NestJS + app Flutter.

## Arquitetura

```
Feira_Control/
├── apps/
│   ├── auth-service/       # Autenticação JWT (:3000)
│   ├── admin-service/      # Gestão de feirantes/barracas/relatórios (:3001)
│   └── feirante-service/   # Produtos, estoque e vendas (:3002)
├── libs/common/            # Guards, decorators e event types compartilhados
├── frontend/               # App Flutter
├── docker-compose.yml
└── README-auth.md          # Padrão JWT para a equipe
```

### Comunicação entre serviços

- **HTTP** — consultas síncronas (ex: admin busca dados de feirante)
- **RabbitMQ** — eventos assíncronos:
  - `venda.registrada` → feirante-service decrementa estoque automaticamente (RF08)
  - `relatorio.request` → feirante-service responde com dados agregados para o admin (RF05)

---

## Pré-requisitos

- Node.js 20+ e npm 10+
- Docker e Docker Compose

---

## Instalação

```bash
git clone https://github.com/paulobomm/Feira_Control
cd Feira_Control

npm install
```

---

## Configuração

```bash
cp .env.example .env
```

Edite o `.env` e defina um valor para `JWT_SECRET` — use a mesma chave nos 3 serviços.

---

## Subir a infraestrutura

```bash
npm run docker:up
```

Aguarde ~10 segundos. Serviços disponíveis:

| Serviço | URL |
|---------|-----|
| RabbitMQ Management | http://localhost:15673 (usuário: `feira` / senha: `feira123`) |
| PostgreSQL Auth | `localhost:5435` — `auth_db` |
| PostgreSQL Admin | `localhost:5436` — `admin_db` |
| PostgreSQL Feirante | `localhost:5437` — `feirante_db` |

Para parar:

```bash
npm run docker:down
```

---

## Criar as tabelas (primeira vez)

Execute em cada serviço para aplicar o schema Drizzle no banco:

```bash
# auth_db
cd apps/auth-service
DATABASE_URL=postgresql://postgres:postgres@localhost:5435/auth_db npx drizzle-kit push:pg

# admin_db
cd apps/admin-service
DATABASE_URL=postgresql://postgres:postgres@localhost:5436/admin_db npx drizzle-kit push:pg

# feirante_db
cd apps/feirante-service
DATABASE_URL=postgresql://postgres:postgres@localhost:5437/feirante_db npx drizzle-kit push:pg
```

---

## Rodar os serviços

Abra 3 terminais a partir da raiz do projeto (substitua `minha_chave_secreta` pelo valor do seu `.env`):

```bash
# Terminal 1 — Auth Service
PORT=3000 DATABASE_URL=postgresql://postgres:postgres@localhost:5435/auth_db \
  JWT_SECRET=minha_chave_secreta \
  npm run dev:auth

# Terminal 2 — Admin Service
PORT=3001 DATABASE_URL=postgresql://postgres:postgres@localhost:5436/admin_db \
  JWT_SECRET=minha_chave_secreta \
  RABBITMQ_URL=amqp://feira:feira123@localhost:5673 \
  npm run dev:admin

# Terminal 3 — Feirante Service
PORT=3002 DATABASE_URL=postgresql://postgres:postgres@localhost:5437/feirante_db \
  JWT_SECRET=minha_chave_secreta \
  RABBITMQ_URL=amqp://feira:feira123@localhost:5673 \
  npm run dev:feirante
```

---

## Seed — Dados iniciais

Popula os 3 bancos com usuários, feirantes, barracas, produtos e estoque de teste:

```bash
npm run seed
```

Credenciais criadas:

| Usuário | Email | Senha | Role |
|---------|-------|-------|------|
| Administrador | admin@feira.com | admin123 | admin |
| João Silva | joao@feira.com | feirante123 | feirante |
| Maria Santos | maria@feira.com | feirante123 | feirante |

Produtos criados (50 unidades em estoque cada):
- **João**: Banana Prata (R$ 8,00), Mamão Formosa (R$ 12,00), Abacaxi (R$ 6,50)
- **Maria**: Tomate (R$ 7,00), Alface (R$ 3,50), Cebola (R$ 9,00)

---

## Testando com cURL

### 1. Login

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@feira.com","password":"senha123"}'
```

Resposta:
```json
{ "access_token": "eyJ...", "refresh_token": "eyJ..." }
```

### 2. Salvar o token

```bash
TOKEN="eyJ..."
```

### 3. Registrar um feirante (requer role admin)

```bash
curl -X POST http://localhost:3000/auth/register-feirante \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"nome":"João Silva","email":"joao@feira.com","password":"senha123"}'
```

### 4. Cadastrar produto (logado como feirante)

```bash
curl -X POST http://localhost:3002/feirante/produtos \
  -H "Authorization: Bearer $TOKEN_FEIRANTE" \
  -H "Content-Type: application/json" \
  -d '{"nome":"Banana","preco_unitario":3.50}'
```

### 5. Registrar uma venda

```bash
curl -X POST http://localhost:3002/feirante/vendas \
  -H "Authorization: Bearer $TOKEN_FEIRANTE" \
  -H "Content-Type: application/json" \
  -d '{"itens":[{"produtoId":"uuid-do-produto","quantidade":2}]}'
```

> O total é calculado no backend — o frontend nunca envia o valor total.
> Após a venda, o RabbitMQ dispara o evento `venda.registrada` e o estoque é decrementado automaticamente.

### 6. Consultar relatório (requer role admin)

```bash
curl "http://localhost:3001/admin/relatorios?dataInicio=2026-01-01&dataFim=2026-12-31" \
  -H "Authorization: Bearer $TOKEN_ADMIN"
```

---

## Endpoints

### Auth Service — :3000

| Método | Rota | Auth | Descrição |
|--------|------|------|-----------|
| POST | `/auth/login` | Pública | Login — retorna access + refresh token |
| POST | `/auth/refresh` | Pública | Renova o access token |
| POST | `/auth/register-feirante` | JWT + admin | Admin cria conta de feirante |
| GET | `/auth/me` | JWT | Dados do usuário autenticado |

### Admin Service — :3001

| Método | Rota | Auth | Descrição |
|--------|------|------|-----------|
| GET | `/admin/feirantes` | JWT + admin | Listar feirantes |
| POST | `/admin/feirantes` | JWT + admin | Cadastrar feirante |
| GET | `/admin/barracas` | JWT + admin | Listar barracas |
| POST | `/admin/barracas` | JWT + admin | Cadastrar barraca |
| GET | `/admin/relatorios` | JWT + admin | Relatório global por período |

### Feirante Service — :3002

| Método | Rota | Auth | Descrição |
|--------|------|------|-----------|
| GET | `/feirante/produtos` | JWT + feirante | Listar produtos |
| POST | `/feirante/produtos` | JWT + feirante | Cadastrar produto |
| GET | `/feirante/estoque` | JWT + feirante | Saldo atual do estoque |
| PATCH | `/feirante/estoque/:id` | JWT + feirante | Ajuste manual de estoque |
| POST | `/feirante/vendas` | JWT + feirante | Registrar venda |
| GET | `/feirante/vendas` | JWT + feirante | Histórico de vendas |
| GET | `/feirante/vendas/:id` | JWT + feirante | Detalhe de uma venda |

---

## Variáveis de Ambiente

Veja `.env.example` para a lista completa. Variáveis obrigatórias:

| Variável | Serviços | Descrição |
|----------|----------|-----------|
| `JWT_SECRET` | Todos | **Mesmo valor** nos 3 serviços |
| `DATABASE_URL` | Todos | Connection string do PostgreSQL |
| `RABBITMQ_URL` | Admin, Feirante | URL do RabbitMQ |
| `PORT` | Todos | 3000 / 3001 / 3002 |

---

## Padrão JWT para a equipe

Consulte o [README-auth.md](./README-auth.md) para o padrão de token, como usar os guards e o fluxo completo de autenticação.
