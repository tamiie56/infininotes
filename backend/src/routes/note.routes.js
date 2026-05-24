const express = require('express');
const {
  createNote,
  getNotes,
  getNoteById,
  updateNote,
  deleteNote,
  pinNote,
  archiveNote,
  trashNote,
} = require('../controllers/note.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(protect);

router.get('/', getNotes);
router.post('/', createNote);
router.get('/:id', getNoteById);
router.put('/:id', updateNote);
router.delete('/:id', deleteNote);
router.patch('/:id/pin', pinNote);
router.patch('/:id/archive', archiveNote);
router.patch('/:id/trash', trashNote);

module.exports = router;