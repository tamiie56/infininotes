const cron = require('node-cron');
const Note = require('../models/note.model');

const startReminderJob = () => {
  cron.schedule('* * * * *', async () => {
    try {
      const now = new Date();
      const notes = await Note.find({
        reminder: { $lte: now },
        reminderSent: false,
        isTrashed: false,
      }).populate('user', 'email name');

      for (const note of notes) {
        note.reminderSent = true;
        await note.save();
      }
    } catch (error) {
      console.error('Reminder job error:', error);
    }
  });
};

module.exports = { startReminderJob };