export interface ExpenseProps {
  id?: number;
  organizerId: number;
  groupId?: number | null;
  payerId: number;
  totalAmount: number;
  name: string;
  description?: string | null;
  createdAt?: Date;
  updatedAt?: Date;
  deletedAt?: Date | null;
}
