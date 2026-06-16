import { Type } from 'class-transformer';
import {
  IsArray,
  IsInt,
  IsNotEmpty,
  IsUUID,
  Min,
  ValidateNested,
} from 'class-validator';

export class ItemVendaDto {
  @IsUUID()
  produtoId: string;

  @IsInt()
  @Min(1)
  @Type(() => Number)
  quantidade: number;
}

export class CreateVendaDto {
  @IsArray()
  @IsNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => ItemVendaDto)
  itens: ItemVendaDto[];
}
