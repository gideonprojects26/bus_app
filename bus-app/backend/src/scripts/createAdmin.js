require('dotenv').config();
const { User, sequelize } = require('../models'); // Changed from '../../models' to '../models'

async function createAdmin() {
  // Command-line args OR sensible defaults
  const fullName = process.argv[2] || 'System Admin';
  const email = process.argv[3] || 'admin@gmail.com';
  const password = process.argv[4] || 'gideon16';
  const phone = process.argv[5] || '0700000000';

  try {
    await sequelize.authenticate();
    console.log('🚀 Connected to PostgreSQL database...');

    const existingUser = await User.findOne({ where: { email } });

    if (existingUser) {
      console.log(`⚠️ User with email ${email} already exists! Upgrading role to admin...`);
      await existingUser.update({ role: 'admin' });
      console.log('✅ User successfully upgraded to Admin!');
    } else {
      const newAdmin = await User.create({
        fullName,
        email,
        password,
        phone,
        role: 'admin',
      });

      console.log('🎉 Success! Admin user created successfully.');
      console.log(`✉️ Email:    ${newAdmin.email}`);
      console.log(`🔑 Password: ${password}`);
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin user:', error.message);
    process.exit(1);
  }
}

createAdmin();