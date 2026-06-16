import { Inject, Injectable, Logger } from '@nestjs/common';
import { ClientProxy } from '@nestjs/microservices';
import { firstValueFrom, timeout } from 'rxjs';

@Injectable()
export class RelatoriosService {
  private readonly logger = new Logger(RelatoriosService.name);

  constructor(
    @Inject('RELATORIO_SERVICE') private readonly client: ClientProxy,
  ) {}

  async getRelatorio(dataInicio: string, dataFim: string) {
    try {
      const data = await firstValueFrom(
        this.client
          .send('relatorio.request', { dataInicio, dataFim })
          .pipe(timeout(10000)),
      );
      return data;
    } catch (err) {
      this.logger.error('Erro ao buscar relatório via RabbitMQ', err);
      return { error: 'Serviço de feirantes indisponível', dataInicio, dataFim };
    }
  }
}
