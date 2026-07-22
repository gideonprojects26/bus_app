require('dotenv').config();
const { sequelize } = require('../models');

async function runFix() {
  try {
    await sequelize.authenticate();
    console.log('🔌 Connected to database!');
    
    // Drop the NOT NULL constraint on email
    await sequelize.query('ALTER TABLE "users" ALTER COLUMN "email" DROP NOT NULL;');
    
    console.log('✅ Success! Email column is now optional.');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error executing query:', error.message);
    process.exit(1);
  }
}

runFix();