// Injected wherever "now" matters so time-based rules can be tested deterministically.
export type Clock = () => Date;

export const CLOCK = Symbol('CLOCK');

export const clockProvider = {
  provide: CLOCK,
  useValue: (() => new Date()) as Clock,
};
