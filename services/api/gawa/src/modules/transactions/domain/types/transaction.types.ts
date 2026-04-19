export interface TransactionProps {
  id?: number;
  paymentId: number;
  provider: string;
  providerReference: string;
  providerName: string;
  rawResponse: Record<string, any>;
  status: string;
  createdAt?: Date;
}
