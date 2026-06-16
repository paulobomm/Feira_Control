import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { DrizzleModule } from './db/drizzle.module';
import { ProdutosModule } from './produtos/produtos.module';
import { EstoqueModule } from './estoque/estoque.module';
import { VendasModule } from './vendas/vendas.module';
import { MessagingModule } from './messaging/messaging.module';
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
    ProdutosModule,
    EstoqueModule,
    VendasModule,
    MessagingModule,
  ],
  providers: [JwtStrategy],
})
export class AppModule {}
