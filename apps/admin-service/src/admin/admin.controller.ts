import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { AdminService } from './admin.service';
import { CreateFeiranteDto } from './dto/create-feirante.dto';
import { CreateBarracaDto } from './dto/create-barraca.dto';
import { JwtAuthGuard, RolesGuard, Roles } from '@app/common';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('feirantes')
  listarFeirantes() {
    return this.adminService.listarFeirantes();
  }

  @Post('feirantes')
  cadastrarFeirante(@Body() dto: CreateFeiranteDto) {
    return this.adminService.cadastrarFeirante(dto);
  }

  @Get('barracas')
  listarBarracas() {
    return this.adminService.listarBarracas();
  }

  @Post('barracas')
  cadastrarBarraca(@Body() dto: CreateBarracaDto) {
    return this.adminService.cadastrarBarraca(dto);
  }
}
