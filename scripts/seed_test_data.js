import dotenv from 'dotenv';
import mongoose from 'mongoose';
import bcrypt from 'bcrypt';

dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/bus_system';

const userSchema = new mongoose.Schema({
  full_name: String,
  email: { type: String, unique: true },
  password_hash: String,
  phone_number: String,
  role: { type: String, enum: ['passenger', 'driver', 'admin'], default: 'passenger' }
}, { timestamps: true });

const tripSchema = new mongoose.Schema({
  route_id: String,
  vehicle_id: String,
  driver_id: mongoose.Schema.Types.ObjectId,
  departure_time: Date,
  arrival_time: Date,
  price_per_seat: Number,
  status: { type: String, default: 'scheduled' }
}, { timestamps: true });

const bookingSchema = new mongoose.Schema({
  user_id: mongoose.Schema.Types.ObjectId,
  trip_id: mongoose.Schema.Types.ObjectId,
  status: { type: String, default: 'pending' },
  total_amount: Number,
  currency: { type: String, default: 'ETB' },
  hold_expires_at: Date
}, { timestamps: true });

const paymentSchema = new mongoose.Schema({
  booking_id: mongoose.Schema.Types.ObjectId,
  amount: Number,
  currency: String,
  status: String,
  chapa_tx_ref: { type: String, unique: true },
  chapa_checkout_url: String
}, { timestamps: true });

const User = mongoose.models.User || mongoose.model('User', userSchema);
const Trip = mongoose.models.Trip || mongoose.model('Trip', tripSchema);
const Booking = mongoose.models.Booking || mongoose.model('Booking', bookingSchema);
const Payment = mongoose.models.Payment || mongoose.model('Payment', paymentSchema);

const seedDatabase = async () => {
  try {
    console.log('Connecting to MongoDB:', MONGODB_URI);
    await mongoose.connect(MONGODB_URI);

    console.log('Clearing existing test data...');
    await User.deleteMany({ email: { $in: ['passenger.test@example.com', 'driver.test@example.com', 'admin.test@example.com'] } });

    const passwordHash = await bcrypt.hash('Password123!', 10);

    const passenger = await User.create({
      full_name: 'Test Passenger',
      email: 'passenger.test@example.com',
      password_hash: passwordHash,
      phone_number: '+251911000001',
      role: 'passenger'
    });

    const driver = await User.create({
      full_name: 'Test Driver',
      email: 'driver.test@example.com',
      password_hash: passwordHash,
      phone_number: '+251911000002',
      role: 'driver'
    });

    const admin = await User.create({
      full_name: 'Test Admin',
      email: 'admin.test@example.com',
      password_hash: passwordHash,
      phone_number: '+251911000003',
      role: 'admin'
    });

    const trip = await Trip.create({
      route_id: 'ROUTE-ADDIS-HAWASSA-01',
      vehicle_id: 'BUS-ETH-1002',
      driver_id: driver._id,
      departure_time: new Date(Date.now() + 86400000),
      arrival_time: new Date(Date.now() + 86400000 + 18000000),
      price_per_seat: 350.00,
      status: 'scheduled'
    });

    const booking = await Booking.create({
      user_id: passenger._id,
      trip_id: trip._id,
      status: 'pending',
      total_amount: 350.00,
      currency: 'ETB',
      hold_expires_at: new Date(Date.now() + 900000)
    });

    const payment = await Payment.create({
      booking_id: booking._id,
      amount: 350.00,
      currency: 'ETB',
      status: 'pending',
      chapa_tx_ref: `tx-${booking._id}-${Date.now()}`
    });

    console.log('✅ Seed Database Complete!');
    console.log('---------------------------------------------------------');
    console.log('Test Credentials (Password for all: Password123!):');
    console.log('Passenger:', passenger.email, 'ID:', passenger._id.toString());
    console.log('Driver:   ', driver.email, 'ID:', driver._id.toString());
    console.log('Admin:    ', admin.email, 'ID:', admin._id.toString());
    console.log('Test Trip ID:   ', trip._id.toString());
    console.log('Test Booking ID:', booking._id.toString());
    console.log('Test Payment Ref:', payment.chapa_tx_ref);
    console.log('---------------------------------------------------------');

    process.exit(0);
  } catch (error) {
    console.error('Seed Database Failed:', error);
    process.exit(1);
  }
};

seedDatabase();
