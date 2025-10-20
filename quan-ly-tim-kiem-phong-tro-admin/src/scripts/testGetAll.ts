import dotenv from 'dotenv';
dotenv.config();

import { ApartmentRepository } from '@/repositories/apartmentRepository';
import { PostRepository } from '@/repositories/postRepository';
import { UserRepository } from '@/repositories/userRepository';

async function main() {
  try {
    console.log('--- Test: getAll Users ---');
    const users = await UserRepository.getAll();
    console.log(`Users count: ${users.length}`);
    console.dir(users, { depth: 2 });

    console.log('\n--- Test: getAll Posts ---');
    const posts = await PostRepository.getAll();
    console.log(`Posts count: ${posts.length}`);
    console.dir(posts, { depth: 2 });

    console.log('\n--- Test: getAll Apartments ---');
    const apartments = await ApartmentRepository.getAll();
    console.log(`Apartments count: ${apartments.length}`);
    console.dir(apartments, { depth: 2 });

    console.log('\n✅ testGetAll finished successfully');
    process.exit(0);
  } catch (err) {
    console.error('\n❌ testGetAll failed:', err);
    process.exit(1);
  }
}

main();
