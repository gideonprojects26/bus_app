require('dotenv').config();
const { User, sequelize } = require('../models');

async function createAdmin() {
  const [fullName, phone, password] = process.argv.slice(2);

  if (!fullName || !phone || !password) {
    console.log('❌ Usage: node src/scripts/createAdmin.js "Admin Name" "Phone" "Password"');
    process.exit(1);
  }

  try {
    await sequelize.authenticate();
    
    const existing = await User.findOne({ where: { phone } });
    if (existing) {
      console.log('❌ User with this phone number already exists.');
      process.exit(1);
    }

    const admin = await User.create({
      fullName,
      phone,
      password,
      role: 'admin',
    });

    console.log(`✅ Admin created successfully! Name: ${admin.fullName}, Phone: ${admin.phone}`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin:', error);
    process.exit(1);
  }
}

createAdmin();