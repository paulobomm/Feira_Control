import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();

  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.RMQ,
    options: {
      urls: [process.env.RABBITMQ_URL ?? 'amqp://feira:feira123@localhost:5672'],
      queue: 'venda_queue',
      queueOptions: { durable: true },
      noAck: false,
    },
  });

  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.RMQ,
    options: {
      urls: [process.env.RABBITMQ_URL ?? 'amqp://feira:feira123@localhost:5672'],
      queue: 'relatorio_queue',
      queueOptions: { durable: true },
      noAck: false,
    },
  });

  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  await app.startAllMicroservices();

  const port = process.env.PORT ?? 3002;
  await app.listen(port);
  console.log(`Feirante Service running on port ${port} (HTTP + RabbitMQ consumers)`);
}

bootstrap();
