const express = require('express');
const { createLabel, getLabels, updateLabel, deleteLabel } = require('../controllers/label.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(protect);

router.get('/', getLabels);
router.post('/', createLabel);
router.put('/:id', updateLabel);
router.delete('/:id', deleteLabel);

module.exports = router;