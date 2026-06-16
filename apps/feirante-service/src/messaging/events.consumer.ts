import { Controller, Logger } from '@nestjs/common';
import { MessagePattern, Payload } from '@nestjs/microservices';
import { EstoqueService } from '../estoque/estoque.service';
import { VendasService } from '../vendas/vendas.service';
import { VendaRegistradaEvent } from '@app/common';

@Controller()
export class EventsConsumer {
  private readonly logger = new Logger(EventsConsumer.name);

  constructor(
    private readonly estoqueService: EstoqueService,
    private readonly vendasService: VendasService,
  ) {}

  @MessagePattern('venda.registrada')
  async handleVendaRegistrada(@Payload() event: VendaRegistradaEvent) {
    this.logger.log(`Processando venda ${event.vendaId} — decrementando estoque`);

    for (const item of event.itens) {
      await this.estoqueService.decrementarEstoque(item.produtoId, item.quantidade);
    }
  }

  @MessagePattern('relatorio.request')
  async handleRelatorioRequest(
    @Payload() payload: { dataInicio: string; dataFim: string },
  ) {
    this.logger.log(`Relatório solicitado: ${payload.dataInicio} → ${payload.dataFim}`);
    return this.vendasService.getVendasRelatorio(payload.dataInicio, payload.dataFim);
  }
}
