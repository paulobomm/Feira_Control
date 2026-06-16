import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { FeiranteClient } from './clients/feirante.client';

@Module({
  controllers: [AdminController],
  providers: [AdminService, FeiranteClient],
  exports: [FeiranteClient],
})
export class AdminModule {}
