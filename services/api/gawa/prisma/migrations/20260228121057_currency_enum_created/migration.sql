/*
  Warnings:

  - The `currency` column on the `Obligation` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `currency` column on the `Payment` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `currency` column on the `Subscription` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- CreateEnum
CREATE TYPE "Currency" AS ENUM ('KES', 'USD', 'EUR');

-- AlterTable
ALTER TABLE "Obligation" DROP COLUMN "currency",
ADD COLUMN     "currency" "Currency" NOT NULL DEFAULT 'KES';

-- AlterTable
ALTER TABLE "Payment" DROP COLUMN "currency",
ADD COLUMN     "currency" "Currency" NOT NULL DEFAULT 'KES';

-- AlterTable
ALTER TABLE "Subscription" DROP COLUMN "currency",
ADD COLUMN     "currency" "Currency" NOT NULL DEFAULT 'KES';
