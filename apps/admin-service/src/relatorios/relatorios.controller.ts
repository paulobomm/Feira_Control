import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { RelatoriosService } from './relatorios.service';
import { JwtAuthGuard, RolesGuard, Roles } from '@app/common';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
@Controller('admin/relatorios')
export class RelatoriosController {
  constructor(private readonly relatoriosService: RelatoriosService) {}

  @Get()
  getRelatorio(
    @Query('dataInicio') dataInicio: string,
    @Query('dataFim') dataFim: string,
  ) {
    return this.relatoriosService.getRelatorio(dataInicio, dataFim);
  }
}
