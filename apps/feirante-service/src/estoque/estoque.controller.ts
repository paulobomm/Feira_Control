import { Controller, Get, Patch, Param, Body, UseGuards } from '@nestjs/common';
import { EstoqueService } from './estoque.service';
import { JwtAuthGuard, RolesGuard, Roles, CurrentUser } from '@app/common';
import { IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';

class AjustarEstoqueDto {
  @IsInt()
  @Min(0)
  @Type(() => Number)
  quantidade: number;
}

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('feirante')
@Controller('feirante/estoque')
export class EstoqueController {
  constructor(private readonly estoqueService: EstoqueService) {}

  @Get()
  getSaldo(@CurrentUser() user: { id: string }) {
    return this.estoqueService.getSaldo(user.id);
  }

  @Patch(':id')
  ajustar(
    @Param('id') produtoId: string,
    @Body() dto: AjustarEstoqueDto,
  ) {
    return this.estoqueService.ajustarEstoque(produtoId, dto.quantidade);
  }
}
