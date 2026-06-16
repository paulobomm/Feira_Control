import { Inject, Injectable } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { NodePgDatabase } from 'drizzle-orm/node-postgres';
import { DRIZZLE } from '../db/drizzle.module';
import * as schema from '../db/schema';
import { NewProduto } from '../db/schema';

@Injectable()
export class ProdutosRepository {
  constructor(@Inject(DRIZZLE) private db: NodePgDatabase<typeof schema>) {}

  async findByFeiranteId(feiranteId: string) {
    return this.db
      .select()
      .from(schema.produtos)
      .where(eq(schema.produtos.feirante_id, feiranteId));
  }

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(schema.produtos)
      .where(eq(schema.produtos.id, id))
      .limit(1);
    return result[0] ?? null;
  }

  async create(data: NewProduto) {
    const result = await this.db
      .insert(schema.produtos)
      .values(data)
      .returning();
    return result[0];
  }
}
