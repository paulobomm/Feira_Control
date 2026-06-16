import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { VendasController } from './vendas.controller';
import { VendasService } from './vendas.service';
import { VendasRepository } from './vendas.repository';
import { ProdutosModule } from '../produtos/produtos.module';

@Module({
  imports: [
    ClientsModule.registerAsync([
      {
        name: 'VENDA_SERVICE',
        useFactory: () => ({
          transport: Transport.RMQ,
          options: {
            urls: [process.env.RABBITMQ_URL ?? 'amqp://feira:feira123@localhost:5672'],
            queue: 'venda_queue',
            queueOptions: { durable: true },
          },
        }),
      },
    ]),
    ProdutosModule,
  ],
  controllers: [VendasController],
  providers: [VendasService, VendasRepository],
  exports: [VendasService],
})
export class VendasModule {}
