import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { RelatoriosController } from './relatorios.controller';
import { RelatoriosService } from './relatorios.service';

@Module({
  imports: [
    ClientsModule.registerAsync([
      {
        name: 'RELATORIO_SERVICE',
        useFactory: () => ({
          transport: Transport.RMQ,
          options: {
            urls: [process.env.RABBITMQ_URL ?? 'amqp://feira:feira123@localhost:5672'],
            queue: 'relatorio_queue',
            queueOptions: { durable: true },
          },
        }),
      },
    ]),
  ],
  controllers: [RelatoriosController],
  providers: [RelatoriosService],
})
export class RelatoriosModule {}
