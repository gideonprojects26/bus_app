const { Client } = require('pg');

const client = new Client({ 
  connectionString: 'postgresql://admin:wZCZDHQA56Jw5NIJD7giIpoePucp7lAA@dpg-d9d6kkl8nd3s73cp1af0-a.oregon-postgres.render.com/bus_app_prod?ssl=true' 
});

async function run() {
  try {
    await client.connect();
    console.log('⚡ Connected! Fetching users...');
    
    // Select all columns from the users table
    const res = await client.query('SELECT id, "fullName", email, role, phone FROM "users";');
    
    console.table(res.rows); // This prints the data in a nice table format
  } catch (err) {
    console.error('❌ Database error:', err.message);
  } finally {
    await client.end();
  }
}
run();
