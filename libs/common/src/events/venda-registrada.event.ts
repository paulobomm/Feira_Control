export interface ItemVendaEvent {
  produtoId: string;
  quantidade: number;
}

export interface VendaRegistradaEvent {
  vendaId: string;
  feiranteId: string;
  itens: ItemVendaEvent[];
}
