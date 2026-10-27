import { splitEqually } from './expense-split';

describe('splitEqually', () => {
  it('splits evenly between everyone involved', () => {
    expect(splitEqually(400_000, [1, 2, 3, 4], 1)).toEqual([
      { userId: 1, amount: 100_000 },
      { userId: 2, amount: 100_000 },
      { userId: 3, amount: 100_000 },
      { userId: 4, amount: 100_000 },
    ]);
  });

  it('gives leftover cents to the payer, never to the people who owe', () => {
    expect(splitEqually(100_000, [2, 1, 3], 1)).toEqual([
      { userId: 2, amount: 33_333 },
      { userId: 1, amount: 33_334 },
      { userId: 3, amount: 33_333 },
    ]);
  });

  it('lets the payer stay out of the split, absorbing any leftover', () => {
    expect(splitEqually(100_000, [2, 3, 4], 1)).toEqual([
      { userId: 2, amount: 33_333 },
      { userId: 3, amount: 33_333 },
      { userId: 4, amount: 33_333 },
    ]);
  });
});
