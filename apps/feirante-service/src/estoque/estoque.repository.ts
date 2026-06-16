import { Inject, Injectable } from '@nestjs/common';
import { eq, sql } from 'drizzle-orm';
import { NodePgDatabase } from 'drizzle-orm/node-postgres';
import { DRIZZLE } from '../db/drizzle.module';
import * as schema from '../db/schema';

@Injectable()
export class EstoqueRepository {
  constructor(@Inject(DRIZZLE) private db: NodePgDatabase<typeof schema>) {}

  async findByProdutoId(produtoId: string) {
    const result = await this.db
      .select()
      .from(schema.estoque_items)
      .where(eq(schema.estoque_items.produto_id, produtoId))
      .limit(1);
    return result[0] ?? null;
  }

  async findByFeiranteId(feiranteId: string) {
    return this.db
      .select({
        id: schema.estoque_items.id,
        produto_id: schema.estoque_items.produto_id,
        produto_nome: schema.produtos.nome,
        quantidade: schema.estoque_items.quantidade,
        updated_at: schema.estoque_items.updated_at,
      })
      .from(schema.estoque_items)
      .innerJoin(schema.produtos, eq(schema.estoque_items.produto_id, schema.produtos.id))
      .where(eq(schema.produtos.feirante_id, feiranteId));
  }

  async upsert(produtoId: string, quantidade: number) {
    const existing = await this.findByProdutoId(produtoId);
    if (existing) {
      const result = await this.db
        .update(schema.estoque_items)
        .set({ quantidade, updated_at: new Date() })
        .where(eq(schema.estoque_items.id, existing.id))
        .returning();
      return result[0];
    }
    const result = await this.db
      .insert(schema.estoque_items)
      .values({ produto_id: produtoId, quantidade })
      .returning();
    return result[0];
  }

  async decrementar(produtoId: string, quantidade: number) {
    const result = await this.db
      .update(schema.estoque_items)
      .set({
        quantidade: sql`${schema.estoque_items.quantidade} - ${quantidade}`,
        updated_at: new Date(),
      })
      .where(eq(schema.estoque_items.produto_id, produtoId))
      .returning();
    return result[0];
  }
}
