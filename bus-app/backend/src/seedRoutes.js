const sequelize = require('./config/database');
const Route = require('./models/route');

const routesData = [
  {
    name: 'City Highlights Tour',
    description: "Explore Kampala's iconic historical landmarks, vibrant markets, and cultural institutions.",
    startPoint: 'BMK House, Colville Street',
    endPoint: 'Independence Grounds',
    fare: 50000.00,             // Local price (UGX)
    internationalFare: 35.00,   // International price (USD)
    schedule: ['08:00 AM', '11:00 AM', '02:00 PM'],
    stops: [
      { id: '1', name: 'BMK House, Colville Street (Start)' },
      { id: '2', name: 'Serena Hotel' },
      { id: '3', name: 'Bank of Uganda' },
      { id: '4', name: 'Constitution Square' },
      { id: '5', name: 'Post Office' },
      { id: '6', name: 'Nakasero Market' },
      { id: '7', name: 'Clock Tower' },
      { id: '8', name: 'Ring Road' },
      { id: '9', name: "Kabaka's Lake" },
      { id: '10', name: 'Bulange Parliament' },
      { id: '11', name: 'Lubaga Cathedral' },
      { id: '12', name: 'Namirembe Cathedral' },
      { id: '13', name: 'Café Javas Bakuli' },
      { id: '14', name: 'Kasubi Tombs' },
      { id: '15', name: 'Makerere University' },
      { id: '16', name: 'Uganda Museum' },
      { id: '17', name: 'Independence Grounds (End Point)' }
    ]
  },
  {
    name: 'Religious Tour',
    description: 'A spiritual journey across Kampala visiting historic cathedrals, mosques, temples, and shrines.',
    startPoint: 'BMK Café, Colville Street',
    endPoint: 'Namugongo Martyrs Shrine',
    fare: 50000.00,             // Local price (UGX)
    internationalFare: 35.00,   // International price (USD)
    schedule: ['08:30 AM', '01:30 PM'],
    stops: [
      { id: '1', name: 'BMK Café, Colville Street (Start)' },
      { id: '2', name: 'Lubaga Cathedral' },
      { id: '3', name: 'Namirembe Cathedral' },
      { id: '4', name: 'Gaddafi National Mosque' },
      { id: '5', name: "Bahá'í Temple" },
      { id: '6', name: 'Namugongo Martyrs Shrine (End Point)' }
    ]
  }
];

async function seedRoutes() {
  try {
    console.log('Connecting to database...');
    await sequelize.authenticate();
    console.log('Database connected successfully.');

    // Alter table schema to auto-add missing columns like "fare"
    await sequelize.sync({ alter: true });
    console.log('Database schema synced (missing columns added).');

    for (const route of routesData) {
      const [record, created] = await Route.findOrCreate({
        where: { name: route.name },
        defaults: route
      });

      if (created) {
        console.log(`Successfully created route: "${route.name}"`);
      } else {
        await record.update(route);
        console.log(`Updated existing route: "${route.name}"`);
      }
    }

    console.log('Route seeding complete!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding routes:', error);
    process.exit(1);
  }
}

// MAKE SURE THIS LINE IS AT THE VERY BOTTOM TO RUN THE SCRIPT
seedRoutes();