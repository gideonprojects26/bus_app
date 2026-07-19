require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User'); 

// 1. Grab your database connection logic
const connectDB = async () => {
  try {
    // Falls back to local if your production string isn't in .env locally
    const connString = process.env.MONGO_URI || process.env.DATABASE_URL; 
    if (!connString) {
      console.error("❌ Error: No database URL found in your .env file!");
      process.exit(1);
    }
    await mongoose.connect(connString);
    console.log("🚀 Connected to the database successfully...");
    await seedAdmin();
  } catch (error) {
    console.error("❌ Database connection failed:", error.message);
    process.exit(1);
  }
};

// 2. Create the Admin account
const seedAdmin = async () => {
  try {
    const adminEmail = "admin@gmail.com"; // <-- Change this to your chosen email
    const adminPassword = "gideon16"; // <-- Change this to your chosen password

    // Check if the user already exists
    const existingUser = await User.findOne({ email: adminEmail });
    if (existingUser) {
      console.log(`⚠️ User with email ${adminEmail} already exists! Updating role to admin...`);
      existingUser.role = 'admin';
      await existingUser.save();
      console.log("✅ User successfully upgraded to Admin!");
    } else {
      // Create a brand new admin user
      // Note: If your User schema automatically hashes passwords via pre-save middleware, 
      // this password will be securely hashed automatically.
      const newAdmin = new User({
        fullName: "System Admin",
        email: adminEmail,
        password: adminPassword,
        phone: "0000000000", 
        role: "admin"
      });

      await newAdmin.save();
      console.log("🎉 Success! Admin user created successfully.");
      console.log(`✉️ Email: ${adminEmail}`);
      console.log(`🔑 Password: ${adminPassword}`);
    }
  } catch (error) {
    console.error("❌ Error creating admin user:", error.message);
  } finally {
    mongoose.connection.close();
    console.log("🔌 Database connection closed.");
  }
};

connectDB();