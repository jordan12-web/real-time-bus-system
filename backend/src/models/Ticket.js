import mongoose from 'mongoose';

const ticketSchema = new mongoose.Schema(
  {
    booking_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Booking',
      required: true,
      unique: true
    },
    qr_code_data: {
      type: String,
      required: true
    },
    qr_code_image_url: {
      type: String,
      default: null
    },
    status: {
      type: String,
      enum: ['issued', 'used', 'revoked'],
      default: 'issued'
    },
    issued_at: {
      type: Date,
      default: Date.now
    },
    used_at: {
      type: Date,
      default: null
    },
    revoked_at: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
  }
);

ticketSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    return ret;
  }
});

const Ticket = mongoose.model('Ticket', ticketSchema);
export default Ticket;
