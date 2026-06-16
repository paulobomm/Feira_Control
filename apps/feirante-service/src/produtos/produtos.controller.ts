import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ProdutosService } from './produtos.service';
import { CreateProdutoDto } from './dto/create-produto.dto';
import { JwtAuthGuard, RolesGuard, Roles, CurrentUser } from '@app/common';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('feirante')
@Controller('feirante/produtos')
export class ProdutosController {
  constructor(private readonly produtosService: ProdutosService) {}

  @Get()
  listar(@CurrentUser() user: { id: string }) {
    return this.produtosService.listar(user.id);
  }

  @Post()
  cadastrar(
    @Body() dto: CreateProdutoDto,
    @CurrentUser() user: { id: string },
  ) {
    return this.produtosService.cadastrar(dto, user.id);
  }
}
