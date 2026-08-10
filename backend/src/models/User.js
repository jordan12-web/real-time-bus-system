import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    full_name: {
      type: String,
      required: true,
      trim: true
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true
    },
    password_hash: {
      type: String,
      required: true
    },
    phone_number: {
      type: String,
      default: null
    },
    role: {
      type: String,
      enum: ['passenger', 'driver', 'admin'],
      default: 'passenger'
    }
  },
  {
    timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
  }
);

userSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    delete ret.password_hash;
    return ret;
  }
});

const User = mongoose.model('User', userSchema);
export default User;
