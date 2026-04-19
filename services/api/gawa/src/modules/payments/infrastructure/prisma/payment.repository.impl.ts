import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../prisma/prisma.service';
import { IPaymentRepository } from '../../domain/repos/payment.repository';
import { Payment } from '../../domain/entities/payment.entity';
import { PaymentMapper } from './payment.orm.entity';

@Injectable()
export class PaymentRepositoryImpl implements IPaymentRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: number): Promise<Payment | null> {
    const raw = await this.prisma.payment.findUnique({ where: { payment_id: id } });
    return raw ? PaymentMapper.toDomain(raw) : null;
  }

  async findAll(): Promise<Payment[]> {
    const raws = await this.prisma.payment.findMany();
    return raws.map((raw) => PaymentMapper.toDomain(raw));
  }

  async save(payment: Payment): Promise<Payment> {
    const data = PaymentMapper.toOrm(payment);
    delete data.payment_id;

    const saved = await this.prisma.payment.create({ data: data as any });
    payment.assignId(saved.payment_id);
    return PaymentMapper.toDomain(saved);
  }
}
