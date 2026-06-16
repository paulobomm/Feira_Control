import { Module } from '@nestjs/common';
import { DrizzleModule } from './db/drizzle.module';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [DrizzleModule, AuthModule],
})
export class AppModule {}
