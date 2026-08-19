import mongoose from 'mongoose';

const tripSchema = new mongoose.Schema(
  {
    route_id: {
      type: String,
      required: true,
      trim: true
    },
    origin: {
      type: String,
      required: true,
      trim: true,
      default: 'Addis Ababa'
    },
    destination: {
      type: String,
      required: true,
      trim: true,
      default: 'Hawassa'
    },
    vehicle_id: {
      type: String,
      required: true,
      trim: true
    },
    driver_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    departure_time: {
      type: Date,
      required: true
    },
    arrival_time: {
      type: Date,
      required: true
    },
    price_per_seat: {
      type: Number,
      required: true,
      min: 0
    },
    status: {
      type: String,
      enum: ['scheduled', 'in_transit', 'completed', 'cancelled'],
      default: 'scheduled'
    }
  },
  {
    timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
  }
);

tripSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    return ret;
  }
});

const Trip = mongoose.model('Trip', tripSchema);
export default Trip;
