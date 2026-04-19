import { Transaction } from '../../domain/entities/transaction.entity';

export interface TransactionOrmEntity {
  transaction_id: number;
  payment_id: number;
  provider: string;
  provider_reference: string;
  provider_name: string;
  raw_response: any;
  status: string;
  created_at: Date;
}

export class TransactionMapper {
  static toDomain(raw: TransactionOrmEntity): Transaction {
    return new Transaction({
      id: raw.transaction_id,
      paymentId: raw.payment_id,
      provider: raw.provider,
      providerReference: raw.provider_reference,
      providerName: raw.provider_name,
      rawResponse: (raw.raw_response ?? {}) as Record<string, any>,
      status: raw.status,
      createdAt: raw.created_at,
    });
  }
}
