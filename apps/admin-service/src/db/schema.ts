import { pgTable, uuid, text, timestamp } from 'drizzle-orm/pg-core';

export const feirantes = pgTable('feirantes', {
  id: uuid('id').defaultRandom().primaryKey(),
  nome: text('nome').notNull(),
  email: text('email').notNull().unique(),
  telefone: text('telefone'),
  created_at: timestamp('created_at').defaultNow().notNull(),
});

export const barracas = pgTable('barracas', {
  id: uuid('id').defaultRandom().primaryKey(),
  nome: text('nome').notNull(),
  localizacao: text('localizacao'),
  feirante_id: uuid('feirante_id').references(() => feirantes.id),
  created_at: timestamp('created_at').defaultNow().notNull(),
});

export type Feirante = typeof feirantes.$inferSelect;
export type NewFeirante = typeof feirantes.$inferInsert;
export type Barraca = typeof barracas.$inferSelect;
export type NewBarraca = typeof barracas.$inferInsert;
