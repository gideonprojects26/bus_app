const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: Number(process.env.SMTP_PORT),
  secure: false, // true for port 465, false for 587 (STARTTLS)
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// Sends the admin team an email whenever a new bus rental request
// comes in, so they can follow up even if they're not actively
// watching the dashboard.
const sendRentalRequestEmail = async (rental) => {
  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 500px;">
      <h2 style="color: #191919;">New Bus Rental Request</h2>
      <p><strong>Name:</strong> ${rental.fullName}</p>
      <p><strong>Phone:</strong> ${rental.phone}</p>
      <p><strong>Passengers:</strong> ${rental.passengerCount}</p>
      <p><strong>Date Needed:</strong> ${rental.neededDate}</p>
      <p><strong>Additional Details:</strong> ${rental.additionalDetails || 'None provided'}</p>
      <hr />
      <p style="color: #9e9e9e; font-size: 12px;">Submitted via the Bus Tours mobile app. View and manage this request in the admin dashboard.</p>
    </div>
  `;

  await transporter.sendMail({
    from: `"Bus Tours App" <${process.env.SMTP_USER}>`,
    to: process.env.ADMIN_NOTIFICATION_EMAIL,
    subject: `New Rental Request from ${rental.fullName}`,
    html,
  });
};

module.exports = { sendRentalRequestEmail };