import { IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateBarracaDto {
  @IsString()
  @IsNotEmpty()
  nome: string;

  @IsString()
  @IsOptional()
  localizacao?: string;

  @IsUUID()
  @IsOptional()
  feirante_id?: string;
}
