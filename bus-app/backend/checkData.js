const { Client } = require('pg');

const client = new Client({ 
  connectionString: 'postgresql://admin:wZCZDHQA56Jw5NIJD7giIpoePucp7lAA@dpg-d9d6kkl8nd3s73cp1af0-a.oregon-postgres.render.com/bus_app_prod?ssl=true' 
});

async function run() {
  try {
    await client.connect();
    console.log('⚡ Querying table with case-insensitive naming...');
    
    // We use quotes for the table name, but select * to see every column
    const res = await client.query('SELECT * FROM "users";');
    
    if (res.rows.length === 0) {
      console.log('❌ Still zero rows found. Let\'s check if it\'s actually "Users" with a capital U.');
      const res2 = await client.query('SELECT * FROM "Users";');
      console.table(res2.rows);
    } else {
      console.log('✅ Found data!');
      console.table(res.rows);
    }
  } catch (err) {
    console.error('❌ Error:', err.message);
  } finally {
    await client.end();
  }
}
run();
