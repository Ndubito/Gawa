-- Existing expenses (if any) default to being due three days after they were logged
ALTER TABLE "Expense" ADD COLUMN "due_at" TIMESTAMPTZ;
UPDATE "Expense" SET "due_at" = "created_at" + INTERVAL '3 days';
ALTER TABLE "Expense" ALTER COLUMN "due_at" SET NOT NULL;
