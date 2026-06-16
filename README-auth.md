# Padrão de Autenticação — FeiraControl

## Visão Geral

Todos os serviços compartilham o **mesmo `JWT_SECRET`**. O Auth Service emite os tokens; os demais serviços apenas os validam localmente via `passport-jwt`.

---

## Formato do Token

```
Authorization: Bearer <access_token>
```

### Payload do JWT

```json
{
  "sub": "uuid-do-usuario",
  "email": "usuario@email.com",
  "role": "admin" | "feirante",
  "iat": 1700000000,
  "exp": 1700000900
}
```

- **Access token**: expira em **15 minutos**
- **Refresh token**: expira em **7 dias**

---

## Endpoints do Auth Service (:3000)

| Método | Rota | Autenticação | Descrição |
|--------|------|-------------|-----------|
| POST | `/auth/login` | Pública | Retorna `access_token` + `refresh_token` |
| POST | `/auth/refresh` | Pública | Corpo: `{ "refresh_token": "..." }` → novo `access_token` |
| POST | `/auth/register-feirante` | JWT + role `admin` | Admin cria conta de feirante |
| GET | `/auth/me` | JWT | Retorna dados do usuário autenticado |

---

## Como usar o Guard nos outros serviços

Cada serviço (`admin-service`, `feirante-service`) já tem a `JwtStrategy` configurada com o mesmo `JWT_SECRET`. Basta usar os guards da lib comum:

```typescript
import { JwtAuthGuard, RolesGuard, Roles, CurrentUser } from '@app/common';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')           // ou 'feirante'
@Get('rota-protegida')
meuEndpoint(@CurrentUser() user: { id: string; email: string; role: string }) {
  // user.id, user.email, user.role disponíveis aqui
}
```

### Só JWT sem verificação de role

```typescript
@UseGuards(JwtAuthGuard)
@Get('qualquer-autenticado')
meuEndpoint(@CurrentUser() user: { id: string }) { ... }
```

---

## Variáveis de Ambiente Obrigatórias

```env
JWT_SECRET=mesmo_valor_nos_3_servicos   # combinar antes de subir
RABBITMQ_URL=amqp://feira:feira123@localhost:5672
```

---

## Fluxo de Login (Flutter → Backend)

```
1. POST /auth/login { email, password }
   ← { access_token, refresh_token }

2. Salvar tokens com flutter_secure_storage

3. Toda requisição: Header Authorization: Bearer <access_token>

4. Se receber 401: POST /auth/refresh { refresh_token }
   ← { access_token }  → atualizar e retentar

5. Se refresh também falhar: redirecionar para tela de login
```

---

## Roles

| Role | Acesso |
|------|--------|
| `admin` | Endpoints `/admin/*` — gerenciar feirantes, barracas, relatórios |
| `feirante` | Endpoints `/feirante/*` — produtos, estoque, vendas próprias |
