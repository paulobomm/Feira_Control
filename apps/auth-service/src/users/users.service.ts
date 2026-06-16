import { Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { UsersRepository } from './users.repository';
import { NewUsuario } from '../db/schema';

@Injectable()
export class UsersService {
  constructor(private readonly usersRepository: UsersRepository) {}

  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 10);
  }

  async validatePassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  async findByEmail(email: string) {
    return this.usersRepository.findByEmail(email);
  }

  async findById(id: string) {
    return this.usersRepository.findById(id);
  }

  async create(data: Omit<NewUsuario, 'senha_hash'> & { password: string }) {
    const { password, ...rest } = data;
    const senha_hash = await this.hashPassword(password);
    return this.usersRepository.create({ ...rest, senha_hash });
  }
}
