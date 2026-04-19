export class TransactionResponseDto {
  id: number;
  paymentId: number;
  provider: string;
  providerReference: string;
  providerName: string;
  rawResponse: Record<string, any>;
  status: string;
  createdAt: Date;

  constructor(transaction: any) {
    this.id = transaction.id;
    this.paymentId = transaction.paymentId;
    this.provider = transaction.provider;
    this.providerReference = transaction.providerReference;
    this.providerName = transaction.providerName;
    this.rawResponse = transaction.rawResponse;
    this.status = transaction.status;
    this.createdAt = transaction.createdAt;
  }
}
