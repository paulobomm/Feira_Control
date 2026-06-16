import { Controller, Get, Post, Param, Body, Query, UseGuards } from '@nestjs/common';
import { VendasService } from './vendas.service';
import { CreateVendaDto } from './dto/create-venda.dto';
import { JwtAuthGuard, RolesGuard, Roles, CurrentUser } from '@app/common';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('feirante')
@Controller('feirante/vendas')
export class VendasController {
  constructor(private readonly vendasService: VendasService) {}

  @Post()
  registrar(
    @Body() dto: CreateVendaDto,
    @CurrentUser() user: { id: string },
  ) {
    return this.vendasService.registrarVenda(dto, user.id);
  }

  @Get()
  listar(
    @CurrentUser() user: { id: string },
    @Query('dataInicio') dataInicio?: string,
    @Query('dataFim') dataFim?: string,
  ) {
    return this.vendasService.listar(user.id, dataInicio, dataFim);
  }

  @Get(':id')
  getVenda(
    @Param('id') id: string,
    @CurrentUser() user: { id: string },
  ) {
    return this.vendasService.getVenda(id, user.id);
  }
}
