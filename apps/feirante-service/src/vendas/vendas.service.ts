import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { ClientProxy } from '@nestjs/microservices';
import { VendasRepository } from './vendas.repository';
import { ProdutosRepository } from '../produtos/produtos.repository';
import { CreateVendaDto } from './dto/create-venda.dto';
import { VendaRegistradaEvent } from '@app/common';

@Injectable()
export class VendasService {
  constructor(
    private readonly vendasRepository: VendasRepository,
    private readonly produtosRepository: ProdutosRepository,
    @Inject('VENDA_SERVICE') private readonly client: ClientProxy,
  ) {}

  async registrarVenda(dto: CreateVendaDto, feiranteId: string) {
    const itensCalculados: Array<{
      produtoId: string;
      quantidade: number;
      preco_unitario: string;
      subtotal: string;
    }> = [];

    let totalGeral = 0;

    for (const item of dto.itens) {
      const produto = await this.produtosRepository.findById(item.produtoId);
      if (!produto) {
        throw new NotFoundException(`Produto ${item.produtoId} não encontrado`);
      }

      const preco = parseFloat(String(produto.preco_unitario));
      const subtotal = preco * item.quantidade;
      totalGeral += subtotal;

      itensCalculados.push({
        produtoId: item.produtoId,
        quantidade: item.quantidade,
        preco_unitario: preco.toFixed(2),
        subtotal: subtotal.toFixed(2),
      });
    }

    const venda = await this.vendasRepository.criar(
      feiranteId,
      totalGeral.toFixed(2),
      itensCalculados,
    );

    const evento: VendaRegistradaEvent = {
      vendaId: venda.id,
      feiranteId,
      itens: itensCalculados.map((i) => ({
        produtoId: i.produtoId,
        quantidade: i.quantidade,
      })),
    };

    this.client.emit('venda.registrada', evento);

    return { ...venda, itens: itensCalculados };
  }

  async listar(feiranteId: string, dataInicio?: string, dataFim?: string) {
    const inicio = dataInicio ? new Date(dataInicio) : undefined;
    const fim = dataFim ? new Date(dataFim) : undefined;
    return this.vendasRepository.listar(feiranteId, inicio, fim);
  }

  async getVenda(id: string, feiranteId: string) {
    const venda = await this.vendasRepository.findById(id, feiranteId);
    if (!venda) throw new NotFoundException('Venda não encontrada');
    return venda;
  }

  async getVendasRelatorio(dataInicio: string, dataFim: string) {
    return this.vendasRepository.getAgregadoPorPeriodo(
      new Date(dataInicio),
      new Date(dataFim),
    );
  }
}
