import { Injectable } from '@nestjs/common';
import { ProdutosRepository } from './produtos.repository';
import { CreateProdutoDto } from './dto/create-produto.dto';

@Injectable()
export class ProdutosService {
  constructor(private readonly produtosRepository: ProdutosRepository) {}

  async listar(feiranteId: string) {
    return this.produtosRepository.findByFeiranteId(feiranteId);
  }

  async cadastrar(dto: CreateProdutoDto, feiranteId: string) {
    return this.produtosRepository.create({
      ...dto,
      feirante_id: feiranteId,
      preco_unitario: String(dto.preco_unitario),
    });
  }
}
