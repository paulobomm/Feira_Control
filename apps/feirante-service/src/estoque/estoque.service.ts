import { Injectable, Logger } from '@nestjs/common';
import { EstoqueRepository } from './estoque.repository';

@Injectable()
export class EstoqueService {
  private readonly logger = new Logger(EstoqueService.name);

  constructor(private readonly estoqueRepository: EstoqueRepository) {}

  async getSaldo(feiranteId: string) {
    return this.estoqueRepository.findByFeiranteId(feiranteId);
  }

  async ajustarEstoque(produtoId: string, quantidade: number) {
    return this.estoqueRepository.upsert(produtoId, quantidade);
  }

  async decrementarEstoque(produtoId: string, quantidade: number) {
    this.logger.log(`Decrementando ${quantidade} unidades do produto ${produtoId}`);
    return this.estoqueRepository.decrementar(produtoId, quantidade);
  }
}
