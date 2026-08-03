const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const DB_URL = process.env.DATABASE_URL;
const BACKUP_DIR = path.join(__dirname, 'backups');

// Extract password from DATABASE_URL for pg_dump
// Format: postgres://user:password@host:port/dbname
const urlMatch = DB_URL.match(/postgres:\/\/[^:]+:([^@]+)@/);
const PGPASSWORD = urlMatch ? urlMatch[1] : '';

if (!fs.existsSync(BACKUP_DIR)) {
  fs.mkdirSync(BACKUP_DIR);
}

async function createBackup() {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const fileName = `backup-${timestamp}.sql`;
  const filePath = path.join(BACKUP_DIR, fileName);

  console.log(`📦 Creating backup: ${fileName}...`);

  return new Promise((resolve, reject) => {
    // PGPASSWORD environment variable tells pg_dump the password automatically
    exec(
      `set PGPASSWORD=${PGPASSWORD} && pg_dump "${DB_URL}" -F p --no-owner > "${filePath}"`,
      (error, stdout, stderr) => {
        if (error) {
          console.error('❌ Backup failed:', stderr);
          return reject(error);
        }
        console.log(`✅ Backup created: ${fileName}`);
        console.log(`   Location: ${filePath}`);
        resolve(filePath);
      }
    );
  });
}

async function runBackup() {
  try {
    console.log('🚀 Starting database backup...');
    await createBackup();
    console.log('🎉 Backup complete!');
  } catch (error) {
    console.error('❌ Backup failed:', error.message);
  }
}

runBackup();