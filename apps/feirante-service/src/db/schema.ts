import { pgTable, uuid, text, numeric, integer, timestamp } from 'drizzle-orm/pg-core';

export const produtos = pgTable('produtos', {
  id: uuid('id').defaultRandom().primaryKey(),
  feirante_id: uuid('feirante_id').notNull(),
  nome: text('nome').notNull(),
  descricao: text('descricao'),
  preco_unitario: numeric('preco_unitario', { precision: 10, scale: 2 }).notNull(),
  created_at: timestamp('created_at').defaultNow().notNull(),
});

export const estoque_items = pgTable('estoque_items', {
  id: uuid('id').defaultRandom().primaryKey(),
  produto_id: uuid('produto_id').references(() => produtos.id).notNull(),
  quantidade: integer('quantidade').default(0).notNull(),
  updated_at: timestamp('updated_at').defaultNow().notNull(),
});

export const vendas = pgTable('vendas', {
  id: uuid('id').defaultRandom().primaryKey(),
  feirante_id: uuid('feirante_id').notNull(),
  total: numeric('total', { precision: 10, scale: 2 }).notNull(),
  created_at: timestamp('created_at').defaultNow().notNull(),
});

export const itens_venda = pgTable('itens_venda', {
  id: uuid('id').defaultRandom().primaryKey(),
  venda_id: uuid('venda_id').references(() => vendas.id).notNull(),
  produto_id: uuid('produto_id').references(() => produtos.id).notNull(),
  quantidade: integer('quantidade').notNull(),
  preco_unitario: numeric('preco_unitario', { precision: 10, scale: 2 }).notNull(),
  subtotal: numeric('subtotal', { precision: 10, scale: 2 }).notNull(),
});

export type Produto = typeof produtos.$inferSelect;
export type NewProduto = typeof produtos.$inferInsert;
export type EstoqueItem = typeof estoque_items.$inferSelect;
export type Venda = typeof vendas.$inferSelect;
export type NewVenda = typeof vendas.$inferInsert;
export type ItemVenda = typeof itens_venda.$inferSelect;
