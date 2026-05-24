const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    title: {
      type: String,
      default: '',
      trim: true,
    },
    content: {
      type: String,
      default: '',
    },
    color: {
      type: String,
      default: '#ffffff',
    },
    isPinned: {
      type: Boolean,
      default: false,
    },
    isArchived: {
      type: Boolean,
      default: false,
    },
    isTrashed: {
      type: Boolean,
      default: false,
    },
    labels: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Label',
      },
    ],
    reminder: {
      type: Date,
      default: null,
    },
    reminderSent: {
      type: Boolean,
      default: false,
    },
    checklist: [
      {
        text: { type: String, required: true },
        isChecked: { type: Boolean, default: false },
      },
    ],
    isCheckList: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Note', noteSchema);