export class GroupResponseDto {
  id: number;
  name: string;
  description: string | null | undefined;
  ownerId: number;
  createdAt: Date;
  updatedAt: Date;

  constructor(group: any) {
    this.id = group.id;
    this.name = group.name;
    this.description = group.description;
    this.ownerId = group.ownerId;
    this.createdAt = group.createdAt;
    this.updatedAt = group.updatedAt;
  }
}
