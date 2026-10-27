-- CreateEnum
CREATE TYPE "ReminderKind" AS ENUM ('UPCOMING', 'DUE', 'OVERDUE', 'NUDGE');

-- AlterTable: existing obligations become overdue at their due date
ALTER TABLE "Obligation" ADD COLUMN "overdue_at" TIMESTAMPTZ;
UPDATE "Obligation" SET "overdue_at" = "due_at";
ALTER TABLE "Obligation" ALTER COLUMN "overdue_at" SET NOT NULL;

-- An obligation comes from exactly one source: a subscription cycle or an expense
ALTER TABLE "Obligation" ADD CONSTRAINT "Obligation_single_source"
  CHECK (("subscription_cycle_id" IS NOT NULL)::int + ("expense_id" IS NOT NULL)::int = 1);

-- AlterTable
ALTER TABLE "SubscriptionCycle" ADD COLUMN "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- CreateTable
CREATE TABLE "Reminder" (
    "reminder_id" SERIAL NOT NULL,
    "obligation_id" INTEGER NOT NULL,
    "kind" "ReminderKind" NOT NULL,
    "sequence" INTEGER NOT NULL DEFAULT 0,
    "scheduled_for" TIMESTAMPTZ NOT NULL,
    "sent_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Reminder_pkey" PRIMARY KEY ("reminder_id")
);

-- CreateIndex
CREATE INDEX "Reminder_sent_at_scheduled_for_idx" ON "Reminder"("sent_at", "scheduled_for");

-- CreateIndex
CREATE UNIQUE INDEX "Reminder_obligation_id_kind_sequence_key" ON "Reminder"("obligation_id", "kind", "sequence");

-- CreateIndex
CREATE INDEX "Obligation_status_overdue_at_idx" ON "Obligation"("status", "overdue_at");

-- CreateIndex
CREATE UNIQUE INDEX "Obligation_subscription_cycle_id_user_id_key" ON "Obligation"("subscription_cycle_id", "user_id");

-- CreateIndex
CREATE UNIQUE INDEX "SubscriptionCycle_subscription_id_period_start_key" ON "SubscriptionCycle"("subscription_id", "period_start");

-- AddForeignKey
ALTER TABLE "Reminder" ADD CONSTRAINT "Reminder_obligation_id_fkey" FOREIGN KEY ("obligation_id") REFERENCES "Obligation"("obligation_id") ON DELETE RESTRICT ON UPDATE CASCADE;
