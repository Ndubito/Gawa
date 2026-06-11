-- AlterTable
ALTER TABLE "Group" ALTER COLUMN "deleted_at" DROP NOT NULL,
ALTER COLUMN "deleted_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "Subscription" ALTER COLUMN "deleted_at" DROP NOT NULL,
ALTER COLUMN "deleted_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "firebase_uid" TEXT,
ALTER COLUMN "deleted_at" DROP NOT NULL,
ALTER COLUMN "deleted_at" DROP DEFAULT;

-- CreateIndex
CREATE UNIQUE INDEX "User_firebase_uid_key" ON "User"("firebase_uid");

-- Clear deleted_at stamped on every existing row by the old broken default(now())
UPDATE "User" SET "deleted_at" = NULL;
UPDATE "Group" SET "deleted_at" = NULL;
UPDATE "Subscription" SET "deleted_at" = NULL;
