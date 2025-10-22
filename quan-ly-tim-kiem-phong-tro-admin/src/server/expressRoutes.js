const express = require('express');
const router = express.Router();

// Example Express route namespace mounted at /express-api
router.post('/echo', express.json(), (req, res) => {
  res.json({ status: 'success', data: req.body });
});

module.exports = router;
