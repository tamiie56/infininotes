const Label = require('../models/label.model');

const createLabel = async (req, res, next) => {
  try {
    const { name } = req.body;
    const existing = await Label.findOne({ user: req.user._id, name });
    if (existing) {
      return res.status(400).json({ success: false, message: 'Label already exists' });
    }
    const label = await Label.create({ user: req.user._id, name });
    res.status(201).json({ success: true, label });
  } catch (error) {
    next(error);
  }
};

const getLabels = async (req, res, next) => {
  try {
    const labels = await Label.find({ user: req.user._id }).sort({ name: 1 });
    res.status(200).json({ success: true, labels });
  } catch (error) {
    next(error);
  }
};

const updateLabel = async (req, res, next) => {
  try {
    const label = await Label.findOneAndUpdate(
      { _id: req.params.id, user: req.user._id },
      { name: req.body.name },
      { new: true }
    );
    if (!label) {
      return res.status(404).json({ success: false, message: 'Label not found' });
    }
    res.status(200).json({ success: true, label });
  } catch (error) {
    next(error);
  }
};

const deleteLabel = async (req, res, next) => {
  try {
    const label = await Label.findOneAndDelete({ _id: req.params.id, user: req.user._id });
    if (!label) {
      return res.status(404).json({ success: false, message: 'Label not found' });
    }
    res.status(200).json({ success: true, message: 'Label deleted' });
  } catch (error) {
    next(error);
  }
};

module.exports = { createLabel, getLabels, updateLabel, deleteLabel };