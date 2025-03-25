const express = require("express");
const rateLimit = require("express-rate-limit");

const apiLimiter = rateLimit({
  windowMs: 1000 * 60 * 3, // 3 minutes
  max: 100,
  message: "Too many requests, please try again after 3 minutes!",
});
const router = express.Router();
const productController = require("../controllers/products");

router.post("/products", apiLimiter, productController.createProduct);
router.get("/products", apiLimiter, productController.getProducts);
router.get("/products/:id", apiLimiter, productController.getProductsByID);
router.delete("/products/:id", apiLimiter, productController.deleteProduct);
router.put("/products/:id", apiLimiter, productController.updateProduct);

module.exports = router;