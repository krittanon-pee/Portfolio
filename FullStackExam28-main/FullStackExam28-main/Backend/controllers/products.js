const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

// insert one product
const createProduct = async (req, res) => {
  const { product_id, name, description, price, category, image_url } = req.body;

  try {
    const product = await prisma.products.create({
      data: {
        product_id,
        name,
        description,
        price,
        category,
        image_url,
      },
    });

    res.status(200).json({
      status: "ok",
      message: `Product with ID = ${product.product_id} is created`,
    });
  } catch (err) {
    console.error("Error creating product:", err); // 🔥 เพิ่ม log ตรงนี้
    res.status(500).json({
      status: "error",
      message: "Failed to create product",
      error: err.message,
    });
  }
};

// get all products
const getProducts = async (req, res) => {
  const products = await prisma.products.findMany();
  res.json(products);
};

const getProductsByID = async (req, res) => {
  const id = req.params.id;
  const product = await prisma.products.findUnique({
    where: {
      product_id: Number(id),
    },
  });
  res.json(product);
};

// delete product by id
const deleteProduct = async (req, res) => {
  const id = req.params.id;
  try {
    // check if the product to be deleted exists
    const existingProduct = await prisma.products.findUnique({
      where: {
        product_id: Number(id),
      },
    });
    if (!existingProduct) {
      return res
        .status(404)
        .json({ message: `Product with ID = ${id} not found` });
    }
    // delete product
    await prisma.products.delete({
      where: {
        product_id: Number(id),
      },
    });
    res.json({ message: `Product with ID = ${id} is deleted` });
  } catch (err) {
    // handle error
    res.status(500).json({
      status: "error",
      message: "Failed to delete product",
      error: err.message,
    });
  }
};

// update product by id
const updateProduct = async (req, res) => {
  const id = req.params.id;
  const { name, price, description,category, image_url} = req.body;
  try {
    // check if the product to be updated exists
    const existingProduct = await prisma.products.findUnique({
      where: {
        product_id: Number(id),
      },
    });
    if (!existingProduct) {
      return res
        .status(404)
        .json({ message: `Product with ID = ${id} not found` });
    }
    // update product
    await prisma.products.update({
      where: {
        product_id: Number(id),
      },
      data: {
        name,
        price,
        description,
        category,
        image_url,
      },
    });
    res.json({ message: `Product with ID = ${id} is updated` });
  } catch (err) {
    // handle error
    res.status(500).json({
      status: "error",
      message: "Failed to update product",
      error: err.message,
    });
  }
};

module.exports = {
  createProduct,
  getProducts,
  getProductsByID,
  deleteProduct,
  updateProduct,
};