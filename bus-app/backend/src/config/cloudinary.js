require('dotenv').config();
const cloudinary = require('cloudinary').v2;

// Cloudinary automatically checks process.env.CLOUDINARY_URL
// Export it so we can use it in our controllers
module.exports = cloudinary;