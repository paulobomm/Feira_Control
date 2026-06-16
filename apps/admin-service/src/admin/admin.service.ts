import { Inject, Injectable, ConflictException } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { NodePgDatabase } from 'drizzle-orm/node-postgres';
import { DRIZZLE } from '../db/drizzle.module';
import * as schema from '../db/schema';
import { CreateFeiranteDto } from './dto/create-feirante.dto';
import { CreateBarracaDto } from './dto/create-barraca.dto';

@Injectable()
export class AdminService {
  constructor(@Inject(DRIZZLE) private db: NodePgDatabase<typeof schema>) {}

  async listarFeirantes() {
    return this.db.select().from(schema.feirantes);
  }

  async cadastrarFeirante(dto: CreateFeiranteDto) {
    const existing = await this.db
      .select()
      .from(schema.feirantes)
      .where(eq(schema.feirantes.email, dto.email))
      .limit(1);

    if (existing.length > 0) throw new ConflictException('Email já cadastrado');

    const result = await this.db
      .insert(schema.feirantes)
      .values(dto)
      .returning();
    return result[0];
  }

  async listarBarracas() {
    return this.db.select().from(schema.barracas);
  }

  async cadastrarBarraca(dto: CreateBarracaDto) {
    const result = await this.db
      .insert(schema.barracas)
      .values(dto)
      .returning();
    return result[0];
  }
}
