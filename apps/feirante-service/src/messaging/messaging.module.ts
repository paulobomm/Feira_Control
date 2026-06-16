import { Module } from '@nestjs/common';
import { EventsConsumer } from './events.consumer';
import { EstoqueModule } from '../estoque/estoque.module';
import { VendasModule } from '../vendas/vendas.module';

@Module({
  imports: [EstoqueModule, VendasModule],
  controllers: [EventsConsumer],
})
export class MessagingModule {}
