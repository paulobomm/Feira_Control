import { Inject, Injectable } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { NodePgDatabase } from 'drizzle-orm/node-postgres';
import { DRIZZLE } from '../db/drizzle.module';
import * as schema from '../db/schema';
import { NewUsuario } from '../db/schema';

@Injectable()
export class UsersRepository {
  constructor(@Inject(DRIZZLE) private db: NodePgDatabase<typeof schema>) {}

  async findByEmail(email: string) {
    const result = await this.db
      .select()
      .from(schema.usuarios)
      .where(eq(schema.usuarios.email, email))
      .limit(1);
    return result[0] ?? null;
  }

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(schema.usuarios)
      .where(eq(schema.usuarios.id, id))
      .limit(1);
    return result[0] ?? null;
  }

  async create(data: NewUsuario) {
    const result = await this.db
      .insert(schema.usuarios)
      .values(data)
      .returning();
    return result[0];
  }
}
