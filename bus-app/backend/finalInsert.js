const { Client } = require('pg');
const bcrypt = require('bcryptjs');

const client = new Client({ 
  connectionString: 'postgresql://admin:wZCZDHQA56Jw5NIJD7giIpoePucp7lAA@dpg-d9d6kkl8nd3s73cp1af0-a.oregon-postgres.render.com/bus_app_prod?ssl=true' 
});

async function run() {
  try {
    await client.connect();
    console.log('⚡ Connected! Inserting admin with all required fields...');
    
    // Securely hash the password first
    const hashedPassword = await bcrypt.hash('SuperSecurePassword123', 10);
    
    // SQL query including the required "phone" column
    const query = 'INSERT INTO "users" (id, email, password, "fullName", role, phone, "createdAt", "updatedAt") VALUES ($1, $2, $3, $4, $5, $6, $7, $8);';
    const values = [
        '550e8400-e29b-41d4-a716-446655440000', // Pre-generated UUID
        'admin@example.com', 
        hashedPassword, 
        'Admin User', 
        'admin', 
        '+1234567890', // Added dummy phone number to satisfy the constraint
        new Date(), 
        new Date()
    ];
    
    await client.query(query, values);
    console.log('🎉 SUCCESS! The admin account has been injected.');
    
    // Immediately verify the contents to see it live
    console.log('🔍 Double-checking database contents:');
    const res = await client.query('SELECT id, "fullName", email, role, phone FROM "users";');
    console.table(res.rows);

  } catch (err) {
    console.error('❌ Insert failed:', err.message);
  } finally {
    await client.end();
  }
}
run();
