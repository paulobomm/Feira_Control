import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { LoginDto } from './dto/login.dto';
import { RegisterFeiranteDto } from './dto/register-feirante.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async login(dto: LoginDto) {
    const user = await this.usersService.findByEmail(dto.email);
    if (!user) throw new UnauthorizedException('Credenciais inválidas');

    const valid = await this.usersService.validatePassword(
      dto.password,
      user.senha_hash,
    );
    if (!valid) throw new UnauthorizedException('Credenciais inválidas');

    const payload = { sub: user.id, email: user.email, role: user.role };
    const access_token = this.jwtService.sign(payload, { expiresIn: '15m' });
    const refresh_token = this.jwtService.sign(payload, { expiresIn: '7d' });

    return { access_token, refresh_token };
  }

  async refreshToken(token: string) {
    try {
      const payload = this.jwtService.verify(token);
      const newPayload = { sub: payload.sub, email: payload.email, role: payload.role };
      const access_token = this.jwtService.sign(newPayload, { expiresIn: '15m' });
      return { access_token };
    } catch {
      throw new UnauthorizedException('Token inválido ou expirado');
    }
  }

  async registerFeirante(dto: RegisterFeiranteDto) {
    const existing = await this.usersService.findByEmail(dto.email);
    if (existing) throw new ConflictException('Email já cadastrado');

    const user = await this.usersService.create({
      nome: dto.nome,
      email: dto.email,
      password: dto.password,
      role: 'feirante',
    });

    const { senha_hash, ...result } = user;
    return result;
  }

  async getMe(userId: string) {
    const user = await this.usersService.findById(userId);
    if (!user) throw new UnauthorizedException();
    const { senha_hash, ...result } = user;
    return result;
  }
}
