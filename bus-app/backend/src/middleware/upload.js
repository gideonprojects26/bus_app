const multer = require('multer');

// We use a temporary local folder to hold the photo for a split second 
// before we send it up to Cloudinary
const upload = multer({ dest: 'uploads/' });

module.exports = upload;