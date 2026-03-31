-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');

-- CreateEnum
CREATE TYPE "SubscriptionStatus" AS ENUM ('ACTIVE', 'PAUSED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "SubscriptionSchedule" AS ENUM ('DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY');

-- CreateEnum
CREATE TYPE "ShareType" AS ENUM ('FIXED', 'PERCENTAGE');

-- CreateEnum
CREATE TYPE "CycleStatus" AS ENUM ('UPCOMING', 'ACTIVE', 'CLOSED');

-- CreateEnum
CREATE TYPE "ObligationStatus" AS ENUM ('PENDING', 'PARTIAL', 'PAID', 'CANCELLED', 'OVERDUE');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'SUCCEEDED', 'FAILED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "ObligationSourceType" AS ENUM ('SUBSCRIPTION_CYCLE', 'EXPENSE');

-- CreateTable
CREATE TABLE "User" (
    "user_id" SERIAL NOT NULL,
    "full_name" TEXT NOT NULL,
    "phone_number" TEXT NOT NULL,
    "email" TEXT,
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "Group" (
    "group_id" SERIAL NOT NULL,
    "group_name" TEXT NOT NULL,
    "group_description" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "owner_id" INTEGER NOT NULL,

    CONSTRAINT "Group_pkey" PRIMARY KEY ("group_id")
);

-- CreateTable
CREATE TABLE "GroupMember" (
    "group_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "role" TEXT,

    CONSTRAINT "GroupMember_pkey" PRIMARY KEY ("group_id","user_id")
);

-- CreateTable
CREATE TABLE "Subscription" (
    "subscription_id" SERIAL NOT NULL,
    "group_id" INTEGER NOT NULL,
    "recipient_id" INTEGER NOT NULL,
    "organizer_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "amount_cents" INTEGER NOT NULL,
    "currency" CHAR(3) NOT NULL DEFAULT 'KES',
    "schedule" "SubscriptionSchedule" NOT NULL,
    "grace_hours" INTEGER NOT NULL,
    "status" "SubscriptionStatus" NOT NULL,
    "start_date" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Subscription_pkey" PRIMARY KEY ("subscription_id")
);

-- CreateTable
CREATE TABLE "SubscriptionMember" (
    "user_id" INTEGER NOT NULL,
    "subscription_id" INTEGER NOT NULL,
    "share_value" INTEGER NOT NULL,
    "share_type" "ShareType" NOT NULL,

    CONSTRAINT "SubscriptionMember_pkey" PRIMARY KEY ("user_id","subscription_id")
);

-- CreateTable
CREATE TABLE "SubscriptionCycle" (
    "subscription_cycle_id" SERIAL NOT NULL,
    "subscription_id" INTEGER NOT NULL,
    "period_start" TIMESTAMP(3) NOT NULL,
    "period_end" TIMESTAMP(3) NOT NULL,
    "due_at" TIMESTAMP(3) NOT NULL,
    "status" "CycleStatus" NOT NULL,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SubscriptionCycle_pkey" PRIMARY KEY ("subscription_cycle_id")
);

-- CreateTable
CREATE TABLE "Expense" (
    "expense_id" SERIAL NOT NULL,
    "organizer_id" INTEGER NOT NULL,
    "group_id" INTEGER,
    "payer_id" INTEGER NOT NULL,
    "total_amount" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ,

    CONSTRAINT "Expense_pkey" PRIMARY KEY ("expense_id")
);

-- CreateTable
CREATE TABLE "ExpenseSplit" (
    "expense_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "share_value" INTEGER NOT NULL,
    "share_type" "ShareType" NOT NULL,

    CONSTRAINT "ExpenseSplit_pkey" PRIMARY KEY ("expense_id","user_id")
);

-- CreateTable
CREATE TABLE "Obligation" (
    "obligation_id" SERIAL NOT NULL,
    "subscription_cycle_id" INTEGER,
    "expense_id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "recipient_id" INTEGER NOT NULL,
    "source_type" "ObligationSourceType" NOT NULL,
    "amount_due" INTEGER NOT NULL,
    "amount_paid" INTEGER NOT NULL DEFAULT 0,
    "currency" CHAR(3) NOT NULL DEFAULT 'KES',
    "status" "ObligationStatus" NOT NULL,
    "due_at" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Obligation_pkey" PRIMARY KEY ("obligation_id")
);

-- CreateTable
CREATE TABLE "Payment" (
    "payment_id" SERIAL NOT NULL,
    "obligation_id" INTEGER NOT NULL,
    "payer_id" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL,
    "currency" CHAR(3) NOT NULL DEFAULT 'KES',
    "status" "PaymentStatus" NOT NULL,
    "payment_method" TEXT,
    "idempotency_key" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("payment_id")
);

-- CreateTable
CREATE TABLE "Transaction" (
    "transaction_id" SERIAL NOT NULL,
    "payment_id" INTEGER NOT NULL,
    "provider" TEXT NOT NULL,
    "provider_reference" TEXT NOT NULL,
    "provider_name" TEXT NOT NULL,
    "raw_response" JSONB NOT NULL,
    "status" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Transaction_pkey" PRIMARY KEY ("transaction_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "Subscription_group_id_idx" ON "Subscription"("group_id");

-- CreateIndex
CREATE INDEX "Expense_group_id_idx" ON "Expense"("group_id");

-- CreateIndex
CREATE INDEX "Obligation_user_id_recipient_id_status_due_at_idx" ON "Obligation"("user_id", "recipient_id", "status", "due_at");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_idempotency_key_key" ON "Payment"("idempotency_key");

-- CreateIndex
CREATE INDEX "Payment_obligation_id_idx" ON "Payment"("obligation_id");

-- AddForeignKey
ALTER TABLE "Group" ADD CONSTRAINT "Group_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GroupMember" ADD CONSTRAINT "GroupMember_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "Group"("group_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GroupMember" ADD CONSTRAINT "GroupMember_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "Group"("group_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_recipient_id_fkey" FOREIGN KEY ("recipient_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_organizer_id_fkey" FOREIGN KEY ("organizer_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SubscriptionMember" ADD CONSTRAINT "SubscriptionMember_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SubscriptionMember" ADD CONSTRAINT "SubscriptionMember_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "Subscription"("subscription_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SubscriptionCycle" ADD CONSTRAINT "SubscriptionCycle_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "Subscription"("subscription_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_organizer_id_fkey" FOREIGN KEY ("organizer_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "Group"("group_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_payer_id_fkey" FOREIGN KEY ("payer_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExpenseSplit" ADD CONSTRAINT "ExpenseSplit_expense_id_fkey" FOREIGN KEY ("expense_id") REFERENCES "Expense"("expense_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExpenseSplit" ADD CONSTRAINT "ExpenseSplit_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Obligation" ADD CONSTRAINT "Obligation_subscription_cycle_id_fkey" FOREIGN KEY ("subscription_cycle_id") REFERENCES "SubscriptionCycle"("subscription_cycle_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Obligation" ADD CONSTRAINT "Obligation_expense_id_fkey" FOREIGN KEY ("expense_id") REFERENCES "Expense"("expense_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Obligation" ADD CONSTRAINT "Obligation_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Obligation" ADD CONSTRAINT "Obligation_recipient_id_fkey" FOREIGN KEY ("recipient_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_obligation_id_fkey" FOREIGN KEY ("obligation_id") REFERENCES "Obligation"("obligation_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_payer_id_fkey" FOREIGN KEY ("payer_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_payment_id_fkey" FOREIGN KEY ("payment_id") REFERENCES "Payment"("payment_id") ON DELETE RESTRICT ON UPDATE CASCADE;
