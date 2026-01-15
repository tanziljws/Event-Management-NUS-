/**
 * Script to add profile_picture column to users table
 * Run this directly on Railway database
 */

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function addProfilePictureColumn() {
  try {
    console.log('🔧 Adding profile_picture column to users table...');
    
    // Execute raw SQL to add the column
    await prisma.$executeRawUnsafe(`
      ALTER TABLE "users" 
      ADD COLUMN IF NOT EXISTS "profile_picture" TEXT;
    `);
    
    console.log('✅ Column profile_picture added successfully!');
    
    // Verify the column exists
    const result = await prisma.$queryRawUnsafe(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'users' 
      AND column_name = 'profile_picture';
    `);
    
    if (result && result.length > 0) {
      console.log('✅ Verification: Column exists in database');
      console.log('   Column details:', result[0]);
    } else {
      console.log('⚠️  Warning: Column not found after creation');
    }
    
  } catch (error) {
    console.error('❌ Error adding column:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

// Run the script
addProfilePictureColumn()
  .then(() => {
    console.log('✅ Script completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Script failed:', error);
    process.exit(1);
  });

