const mongoose = require('mongoose');

const labelSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
  },
  { timestamps: true }
);

labelSchema.index({ user: 1, name: 1 }, { unique: true });

module.exports = mongoose.model('Label', labelSchema);