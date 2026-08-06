const { exec } = require('child_process');
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// -------------------------------------------------------------
// CONFIGURATION
// -------------------------------------------------------------
const DB_URL = process.env.DATABASE_URL;
const FOLDER_ID = process.env.GOOGLE_DRIVE_FOLDER_ID;
const BACKUP_DIR = path.join(__dirname, 'backups');

// Extract password from DATABASE_URL for pg_dump
const urlMatch = DB_URL.match(/postgres:\/\/[^:]+:([^@]+)@/);
const PGPASSWORD = urlMatch ? urlMatch[1] : '';

if (!fs.existsSync(BACKUP_DIR)) {
  fs.mkdirSync(BACKUP_DIR);
}

// -------------------------------------------------------------
// 1. CREATE BACKUP FILE
// -------------------------------------------------------------
async function createBackup() {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const fileName = `backup-${timestamp}.sql`;
  const filePath = path.join(BACKUP_DIR, fileName);

  console.log(`📦 Creating backup: ${fileName}...`);

  return new Promise((resolve, reject) => {
    exec(
      `set PGPASSWORD=${PGPASSWORD} && pg_dump "${DB_URL}" -F p --no-owner > "${filePath}"`,
      (error, stdout, stderr) => {
        if (error) {
          console.error('❌ Backup failed:', stderr);
          return reject(error);
        }
        console.log(`✅ Backup created: ${fileName}`);
        resolve(filePath);
      }
    );
  });
}

// -------------------------------------------------------------
// 2. AUTHENTICATE WITH GOOGLE DRIVE
// -------------------------------------------------------------
async function getDriveClient() {
  const auth = new google.auth.GoogleAuth({
    keyFile: path.join(__dirname, 'service-account-key.json'),
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  });

  const authClient = await auth.getClient();
  return google.drive({ version: 'v3', auth: authClient });
}

// -------------------------------------------------------------
// 3. UPLOAD TO GOOGLE DRIVE
// -------------------------------------------------------------
async function uploadToDrive(drive, filePath, fileName) {
  console.log(`☁️  Uploading ${fileName} to Google Drive...`);

  const fileMetadata = {
    name: fileName,
    parents: [FOLDER_ID],
  };

  const media = {
    mimeType: 'application/sql',
    body: fs.createReadStream(filePath),
  };

  const response = await drive.files.create({
    resource: fileMetadata,
    media: media,
    fields: 'id, name',
  });

  console.log(`✅ Uploaded: ${response.data.name} (ID: ${response.data.id})`);
}

// -------------------------------------------------------------
// 4. CLEANUP OLD LOCAL BACKUPS (Keep last 7 days)
// -------------------------------------------------------------
function cleanupOldBackups() {
  const files = fs.readdirSync(BACKUP_DIR);
  const sevenDaysAgo = Date.now() - 7 * 24 * 60 * 60 * 1000;

  files.forEach((file) => {
    const filePath = path.join(BACKUP_DIR, file);
    const stats = fs.statSync(filePath);
    if (stats.mtimeMs < sevenDaysAgo) {
      fs.unlinkSync(filePath);
      console.log(`🗑️  Deleted old backup: ${file}`);
    }
  });
}

// -------------------------------------------------------------
// 5. MAIN
// -------------------------------------------------------------
async function runBackup() {
  try {
    console.log('🚀 Starting database backup...');

    const filePath = await createBackup();
    const fileName = path.basename(filePath);

    const drive = await getDriveClient();
    await uploadToDrive(drive, filePath, fileName);

    cleanupOldBackups();

    console.log('🎉 Backup complete!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Backup failed:', error.message);
    process.exit(1);
  }
}

runBackup();