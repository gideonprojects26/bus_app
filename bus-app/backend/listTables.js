const { Client } = require('pg');

const client = new Client({ 
  connectionString: 'postgresql://admin:wZCZDHQA56Jw5NIJD7giIpoePucp7lAA@dpg-d9d6kkl8nd3s73cp1af0-a.oregon-postgres.render.com/bus_app_prod?ssl=true' 
});

async function run() {
  try {
    await client.connect();
    // This query lists all table names in your database
    const res = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public';
    `);
    
    console.log('Tables found in database:');
    console.table(res.rows);
  } catch (err) {
    console.error('Database error:', err.message);
  } finally {
    await client.end();
  }
}
run();
