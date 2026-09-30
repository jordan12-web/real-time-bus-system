import mongoose from 'mongoose';

const tripLocationSchema = new mongoose.Schema(
  {
    trip_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Trip',
      required: true,
      index: true
    },
    latitude: {
      type: Number,
      required: true
    },
    longitude: {
      type: Number,
      required: true
    },
    speed_kmh: {
      type: Number,
      default: 0
    },
    heading: {
      type: Number,
      default: 0
    },
    recorded_at: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
  }
);

tripLocationSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    return ret;
  }
});

tripLocationSchema.index({ trip_id: 1, recorded_at: -1 });

const TripLocation = mongoose.model('TripLocation', tripLocationSchema);
export default TripLocation;
