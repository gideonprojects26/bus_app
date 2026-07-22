const { Client } = require('pg');

const client = new Client({ 
  connectionString: 'postgresql://admin:wZCZDHQA56Jw5NIJD7giIpoePucp7lAA@dpg-d9d6kkl8nd3s73cp1af0-a.oregon-postgres.render.com/bus_app_prod?ssl=true' 
});

async function run() {
  try {
    await client.connect();
    console.log('⚡ Attempting manual insertion...');
    
    // Minimal insert to see if we can get data in
    const query = 'INSERT INTO "users" (id, email, password, "fullName", role, "createdAt", "updatedAt") VALUES ($1, $2, $3, $4, $5, $6, $7);';
    const values = [
        '550e8400-e29b-41d4-a716-446655440000', 
        'admin@example.com', 
        'hashed_password_test', 
        'Admin User', 
        'admin', 
        new Date(), 
        new Date()
    ];
    
    await client.query(query, values);
    console.log('✅ Insertion attempted successfully!');
  } catch (err) {
    console.error('❌ Insert failed:', err.message);
  } finally {
    await client.end();
  }
}
run();
