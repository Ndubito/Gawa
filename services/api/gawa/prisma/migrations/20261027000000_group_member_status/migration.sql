-- CreateEnum
CREATE TYPE "GroupMemberStatus" AS ENUM ('INVITED', 'ACTIVE');

-- Members added before invite acceptance existed are kept as accepted
ALTER TABLE "GroupMember" ADD COLUMN "status" "GroupMemberStatus" NOT NULL DEFAULT 'ACTIVE';

-- New invites start pending
ALTER TABLE "GroupMember" ALTER COLUMN "status" SET DEFAULT 'INVITED';
