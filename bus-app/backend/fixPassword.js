const { Client } = require('pg');
const bcrypt = require('bcryptjs'); // Swapped to bcryptjs

const client = new Client({ 
  connectionString: 'postgresql://admin:wZCZDHQA56Jw5NIJD7giIpoePucp7lAA@dpg-d9d6kkl8nd3s73cp1af0-a.oregon-postgres.render.com/bus_app_prod?ssl=true' 
});

async function run() {
  try {
    await client.connect();
    console.log('⚡ Connected directly to Render Postgres externally!');
    
    // Scramble the password exactly how your backend expects it
    const hashedPassword = await bcrypt.hash('SuperSecurePassword123', 10);
    
    // Update the existing admin account with the newly scrambled password
    const query = 'UPDATE "users" SET password = $1 WHERE email = $2;';
    
    await client.query(query, [hashedPassword, 'admin@example.com']);
    console.log('🎉 SUCCESS! The admin password is now securely hashed.');
  } catch (err) {
    console.error('❌ Database error:', err.message);
  } finally {
    await client.end();
  }
}
run();
