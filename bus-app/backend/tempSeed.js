const { Client } = require('pg');
const crypto = require('crypto');

const client = new Client({ 
  connectionString: 'postgresql://admin:wZCZDHQA56Jw5NIJD7giIpoePucp7lAA@dpg-d9d6kkl8nd3s73cp1af0-a.oregon-postgres.render.com/bus_app_prod?ssl=true' 
});

async function run() {
  try {
    await client.connect();
    console.log('⚡ Connected directly to Render Postgres externally!');
    
    const newId = crypto.randomUUID();
    
    // Added "createdAt" and "updatedAt" columns using NOW() for the timestamps
    const query = 'INSERT INTO "users" ("id", "fullName", "email", "password", "role", "phone", "createdAt", "updatedAt") VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW()) ON CONFLICT (email) DO UPDATE SET role = $5, "updatedAt" = NOW();';
    
    await client.query(query, [newId, 'Admin', 'admin@example.com', 'SuperSecurePassword123', 'admin', '0000000000']);
    console.log('🎉 SUCCESS! Admin user has been added to your live database.');
  } catch (err) {
    console.error('❌ Database error:', err.message);
  } finally {
    await client.end();
  }
}
run();
