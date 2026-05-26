const Note = require('../models/note.model');

const createNote = async (req, res, next) => {
  try {
    const { title, content, color, labels, isCheckList, checklist, reminder } = req.body;
    const note = await Note.create({
      user: req.user._id,
      title,
      content,
      color,
      labels,
      isCheckList,
      checklist,
      reminder,
    });
    res.status(201).json({ success: true, note });
  } catch (error) {
    next(error);
  }
};

const getNotes = async (req, res, next) => {
  try {
    const { search, label, archived, trashed } = req.query;
    const filter = { user: req.user._id };

    if (trashed === 'true') {
      filter.isTrashed = true;
    } else if (archived === 'true') {
      filter.isArchived = true;
      filter.isTrashed = false;
    } else {
      filter.isArchived = false;
      filter.isTrashed = false;
    }

    if (label) filter.labels = label;

    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { content: { $regex: search, $options: 'i' } },
      ];
    }

    const notes = await Note.find(filter)
      .populate('labels', 'name')
      .sort({ isPinned: -1, updatedAt: -1 });

    res.status(200).json({ success: true, notes });
  } catch (error) {
    next(error);
  }
};

const getNoteById = async (req, res, next) => {
  try {
    const note = await Note.findOne({ _id: req.params.id, user: req.user._id }).populate('labels', 'name');
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }
    res.status(200).json({ success: true, note });
  } catch (error) {
    next(error);
  }
};

const updateNote = async (req, res, next) => {
  try {
    const note = await Note.findOneAndUpdate(
      { _id: req.params.id, user: req.user._id },
      { $set: req.body },
      { new: true }
    ).populate('labels', 'name');
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }
    res.status(200).json({ success: true, note });
  } catch (error) {
    next(error);
  }
};

const deleteNote = async (req, res, next) => {
  try {
    const note = await Note.findOneAndDelete({ _id: req.params.id, user: req.user._id });
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }
    res.status(200).json({ success: true, message: 'Note deleted' });
  } catch (error) {
    next(error);
  }
};

const pinNote = async (req, res, next) => {
  try {
    const note = await Note.findOne({ _id: req.params.id, user: req.user._id });
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }
    note.isPinned = !note.isPinned;
    await note.save();
    res.status(200).json({ success: true, note });
  } catch (error) {
    next(error);
  }
};

const archiveNote = async (req, res, next) => {
  try {
    const note = await Note.findOne({ _id: req.params.id, user: req.user._id });
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }
    note.isArchived = !note.isArchived;
    await note.save();
    res.status(200).json({ success: true, note });
  } catch (error) {
    next(error);
  }
};

const trashNote = async (req, res, next) => {
  try {
    const note = await Note.findOne({ _id: req.params.id, user: req.user._id });
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }
    note.isTrashed = !note.isTrashed;
    await note.save();
    res.status(200).json({ success: true, note });
  } catch (error) {
    next(error);
  }
};

const restoreNote = async (req, res, next) => {
  try {
    const note = await Note.findOne({ _id: req.params.id, user: req.user._id });
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }
    note.isTrashed = false;
    await note.save();
    res.status(200).json({ success: true, note });
  } catch (error) {
    next(error);
  }
};

const permanentDeleteNote = async (req, res, next) => {
  try {
    const note = await Note.findOneAndDelete({ _id: req.params.id, user: req.user._id, isTrashed: true });
    if (!note) {
      return res.status(404).json({ success: false, message: 'Note not found' });
    }
    res.status(200).json({ success: true, message: 'Note permanently deleted' });
  } catch (error) {
    next(error);
  }
};

module.exports = { createNote, getNotes, getNoteById, updateNote, deleteNote, pinNote, archiveNote, trashNote, restoreNote, permanentDeleteNote };