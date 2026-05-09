// prisma/seed.ts
// TODO: implement seed data (3 users, 17 resources, borrow records, etc.)
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
