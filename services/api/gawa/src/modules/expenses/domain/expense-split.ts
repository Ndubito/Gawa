import { ExpenseSplit } from './types/expense.types';

// Equal shares for everyone involved. Leftover cents from uneven division stay
// with the payer, so nobody is charged more than an exact split.
export function splitEqually(
  totalAmount: number,
  participantIds: number[],
  payerId: number,
): ExpenseSplit[] {
  const share = Math.floor(totalAmount / participantIds.length);
  const leftover = totalAmount - share * participantIds.length;
  return participantIds.map((userId) => ({
    userId,
    amount: share + (userId === payerId ? leftover : 0),
  }));
}
