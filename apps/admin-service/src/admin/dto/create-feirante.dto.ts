import { IsEmail, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateFeiranteDto {
  @IsString()
  @IsNotEmpty()
  nome: string;

  @IsEmail()
  email: string;

  @IsString()
  @IsOptional()
  telefone?: string;
}
