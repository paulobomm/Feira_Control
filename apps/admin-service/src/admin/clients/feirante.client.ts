import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class FeiranteClient {
  private readonly logger = new Logger(FeiranteClient.name);
  private readonly baseUrl = process.env.FEIRANTE_URL ?? 'http://localhost:3002';

  async getProdutos(feiranteId: string, token: string) {
    try {
      const res = await fetch(
        `${this.baseUrl}/feirante/produtos?feirante_id=${feiranteId}`,
        { headers: { Authorization: `Bearer ${token}` } },
      );
      if (!res.ok) return [];
      return res.json();
    } catch (err) {
      this.logger.error('Erro ao consultar produtos do feirante-service', err);
      return [];
    }
  }
}
