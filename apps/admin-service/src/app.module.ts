import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { DrizzleModule } from './db/drizzle.module';
import { AdminModule } from './admin/admin.module';
import { RelatoriosModule } from './relatorios/relatorios.module';
import { JwtStrategy } from './auth/jwt.strategy';

@Module({
  imports: [
    PassportModule,
    JwtModule.registerAsync({
      useFactory: () => ({
        secret: process.env.JWT_SECRET,
        signOptions: { expiresIn: '15m' },
      }),
    }),
    DrizzleModule,
    AdminModule,
    RelatoriosModule,
  ],
  providers: [JwtStrategy],
})
export class AppModule {}
