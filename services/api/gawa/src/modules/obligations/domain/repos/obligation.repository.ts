import { Obligation } from '../entities/obligation.entity';

export interface IObligationRepository {
  findById(id: number): Promise<Obligation | null>;
  findAll(): Promise<Obligation[]>;
  save(obligation: Obligation): Promise<Obligation>;
  update(obligation: Obligation): Promise<Obligation>;
}

export const OBLIGATION_REPOSITORY_TOKEN = Symbol('OBLIGATION_REPOSITORY_TOKEN');
