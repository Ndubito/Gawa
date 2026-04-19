export interface GroupProps {
  id?: number;
  name: string;
  description?: string | null;
  ownerId: number;
  createdAt?: Date;
  updatedAt?: Date;
  deletedAt?: Date | null;
}
