import { Inject, Injectable } from '@nestjs/common';
import { and, between, eq } from 'drizzle-orm';
import { NodePgDatabase } from 'drizzle-orm/node-postgres';
import { DRIZZLE } from '../db/drizzle.module';
import * as schema from '../db/schema';

@Injectable()
export class VendasRepository {
  constructor(@Inject(DRIZZLE) private db: NodePgDatabase<typeof schema>) {}

  async criar(
    feiranteId: string,
    total: string,
    itens: Array<{ produtoId: string; quantidade: number; preco_unitario: string; subtotal: string }>,
  ) {
    const [venda] = await this.db
      .insert(schema.vendas)
      .values({ feirante_id: feiranteId, total })
      .returning();

    const itensData = itens.map((item) => ({
      venda_id: venda.id,
      produto_id: item.produtoId,
      quantidade: item.quantidade,
      preco_unitario: item.preco_unitario,
      subtotal: item.subtotal,
    }));

    await this.db.insert(schema.itens_venda).values(itensData);

    return venda;
  }

  async listar(feiranteId: string, dataInicio?: Date, dataFim?: Date) {
    const conditions = [eq(schema.vendas.feirante_id, feiranteId)];
    if (dataInicio && dataFim) {
      conditions.push(between(schema.vendas.created_at, dataInicio, dataFim));
    }
    return this.db
      .select()
      .from(schema.vendas)
      .where(and(...conditions))
      .orderBy(schema.vendas.created_at);
  }

  async findById(id: string, feiranteId: string) {
    const [venda] = await this.db
      .select()
      .from(schema.vendas)
      .where(and(eq(schema.vendas.id, id), eq(schema.vendas.feirante_id, feiranteId)))
      .limit(1);

    if (!venda) return null;

    const itens = await this.db
      .select()
      .from(schema.itens_venda)
      .where(eq(schema.itens_venda.venda_id, id));

    return { ...venda, itens };
  }

  async getAgregadoPorPeriodo(dataInicio: Date, dataFim: Date) {
    const vendasPeriodo = await this.db
      .select()
      .from(schema.vendas)
      .where(between(schema.vendas.created_at, dataInicio, dataFim));

    const total = vendasPeriodo.reduce(
      (acc, v) => acc + parseFloat(String(v.total)),
      0,
    );

    return {
      total_vendas: vendasPeriodo.length,
      faturamento_total: total.toFixed(2),
      periodo: { inicio: dataInicio, fim: dataFim },
    };
  }
}
