/**
 * Script untuk setup super user dengan bypass semua restrictions
 * Email: imtanzil.dev
 * 
 * Fitur bypass:
 * - Email verification tidak diperlukan
 * - OTP verification tidak diperlukan
 * - Password reset tidak perlu email verified
 * - Bypass rate limiting
 * - Akses semua laman khusus
 */

require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

const SUPER_USER_EMAIL = 'imtanzil.dev';

async function setupSuperUser() {
  try {
    console.log('🚀 Setting up super user:', SUPER_USER_EMAIL);

    // Check if user exists
    let user = await prisma.user.findUnique({
      where: { email: SUPER_USER_EMAIL },
    });

    if (!user) {
      console.log('📝 Creating new user...');
      
      // Hash default password
      const defaultPassword = 'SuperUser123!@#';
      const hashedPassword = await bcrypt.hash(defaultPassword, 12);

      // Create user
      user = await prisma.user.create({
        data: {
          email: SUPER_USER_EMAIL,
          fullName: 'Super User',
          password: hashedPassword,
          role: 'SUPER_ADMIN',
          emailVerified: true, // Auto verified
          verificationStatus: 'APPROVED', // Auto approved
          metadata: {
            isSuperUser: true,
            bypassEmailVerification: true,
            bypassOtpVerification: true,
            bypassPasswordResetRestrictions: true,
            bypassRateLimiting: true,
            bypassAllRestrictions: true,
            setupAt: new Date().toISOString(),
          },
        },
      });

      console.log('✅ User created successfully!');
      console.log('📧 Email:', SUPER_USER_EMAIL);
      console.log('🔑 Default Password:', defaultPassword);
      console.log('⚠️  Please change password after first login!');
    } else {
      console.log('📝 Updating existing user...');

      // Update user dengan bypass flags
      user = await prisma.user.update({
        where: { email: SUPER_USER_EMAIL },
        data: {
          emailVerified: true, // Force verified
          verificationStatus: 'APPROVED', // Force approved
          role: 'SUPER_ADMIN', // Ensure super admin role
          metadata: {
            ...(user.metadata && typeof user.metadata === 'object' ? user.metadata : {}),
            isSuperUser: true,
            bypassEmailVerification: true,
            bypassOtpVerification: true,
            bypassPasswordResetRestrictions: true,
            bypassRateLimiting: true,
            bypassAllRestrictions: true,
            updatedAt: new Date().toISOString(),
          },
        },
      });

      console.log('✅ User updated successfully!');
    }

    console.log('\n📋 Super User Configuration:');
    console.log('  Email:', user.email);
    console.log('  Role:', user.role);
    console.log('  Email Verified:', user.emailVerified);
    console.log('  Verification Status:', user.verificationStatus);
    console.log('  Bypass Flags:', user.metadata);

    console.log('\n✅ Setup complete!');
    console.log('🎯 This user can now:');
    console.log('  - Access OTP pages without restrictions');
    console.log('  - Access reset password pages without restrictions');
    console.log('  - Bypass email verification');
    console.log('  - Bypass OTP verification');
    console.log('  - Bypass rate limiting');
    console.log('  - Access all special pages');

  } catch (error) {
    console.error('❌ Error:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

// Run script
if (require.main === module) {
  setupSuperUser()
    .then(() => {
      console.log('\n✅ Script completed successfully!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('\n❌ Script failed:', error);
      process.exit(1);
    });
}

module.exports = { setupSuperUser, SUPER_USER_EMAIL };

