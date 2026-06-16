import { pgTable, uuid, text, pgEnum, timestamp } from 'drizzle-orm/pg-core';

export const roleEnum = pgEnum('role', ['admin', 'feirante']);

export const usuarios = pgTable('usuarios', {
  id: uuid('id').defaultRandom().primaryKey(),
  nome: text('nome').notNull(),
  email: text('email').notNull().unique(),
  senha_hash: text('senha_hash').notNull(),
  role: roleEnum('role').default('feirante').notNull(),
  created_at: timestamp('created_at').defaultNow().notNull(),
});

export type Usuario = typeof usuarios.$inferSelect;
export type NewUsuario = typeof usuarios.$inferInsert;
