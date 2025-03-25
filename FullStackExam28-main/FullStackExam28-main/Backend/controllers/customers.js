const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

// insert one customer
const createCustomer = async (req, res) => {
  const { customer_id, first_name, last_name, address, email, phone_number } =
    req.body;

  try {
    // สร้างข้อมูลลูกค้าใหม่
    const cust = await prisma.customers.create({
      data: {
        customer_id,
        first_name,
        last_name,
        address,
        email,
        phone_number,
      },
    });

    // ส่งการตอบกลับเมื่อสร้างลูกค้าสำเร็จ
    res.status(200).json({
      status: "ok",
      message: `User with ID = ${cust.customer_id} is created`, // ส่ง ID ที่ถูกสร้างกลับไป
    });
  } catch (err) {
    // จัดการข้อผิดพลาด
    res.status(500).json({
      status: "error",
      message: "Failed to create user",
      error: err.message,
    });
  }
};
//get all customers
const getCustomers = async (req, res) => {
  const custs = await prisma.customers.findMany();
  res.json(custs);
};

// delete customer by id
const deleteCustomer = async (req, res) => {
  const id = req.params.id;
  try {
    //ตรวจสอบว่าลูกค้าที่ต้องการลบอยู่หรือไม่
    const existingCustomer = await prisma.customers.findUnique({
      where: {
        customer_id: Number(id),
      },
    });
    if (!existingCustomer) {
      return res
        .status(404)
        .json({ message: `Customer with ID = ${id} not found` });
    }
    //ลบลูกค้า
    await prisma.customers.delete({
      where: {
        customer_id: Number(id),
      },
    });
    //ส่งการตอบกลับเมื่อลบลูกค้าสำเร็จ
    res.status(200).json({
      status: "ok",
      message: `User with ID = ${id} is deleted`,
    });
  } catch (err) {
    console.log("Delete user error", err); // แสดงข้อผิดพลาดในการลบลูกค้า
    res.status(500).json({ error: err.message });
  }
};

// update customer by id
const updateCustomer = async (req, res) => {
  const { first_name, last_name, address, email, phone_number } = req.body;
  const { id } = req.params; // รับ ID จาก url

  const data = {};
  if (first_name) data.first_name = first_name;
  if (last_name) data.last_name = last_name;
  if (address) data.address = address;
  if (email) data.email = email;
  if (phone_number) data.phone_number = phone_number;
  // ตรวจสอบว่ามีข้อมูลที่จะอัปเดตหรือไม่
  if (Object.keys(data).length === 0) {
    return res.status(400).json({
      status: "error",
      message: "No data provided to update",
    });
  }
  try {
    // อัปเดตข้อมูลลูกค้า
    const cust = await prisma.customers.update({
      data,
      where: { customer_id: Number(id) },
    });
    // ส่งการตอบกลับเมื่ออัปเดตลูกค้าสำเร็จ
    res.status(200).json({
      status: "ok",
      message: `User with ID = ${id} is updated`,
      user: cust,
    });
  } catch (err) {
    // จัดการข้อผิดพลาด
    if (err.code === "P2002") {
      res.status(400).json({
        status: "error",
        message: "Email already exists",
      });
    } else if (err.code === "P2025") {
      // แสดงข้อผิดพลาดเมื่อไม่พบลูกค้า
      res.status(404).json({
        status: "error",
        message: `User with ID = ${id} not found`,
        error: err.message,
      });
    } else {
      // แสดงข้อผิดพลาดในการอัปเดตลูกค้า
      console.log("Update user error", err);
      res.status(500).json({
        status: "error",
        error: "Failed to update user",
      });
    }
  }
};

//get one customer
const getCustomer = async (req, res) => {
  const id = req.params.id;
  try {
    const cust = await prisma.customers.findUnique({
      where: {
        customer_id: Number(id),
      },
    });
    if (!cust) {
      return res
        .status(404)
        .json({ message: `Customer with ID = ${id} not found` });
    } else {
      res.json(cust); // ส่งข้อมูลลูกค้ากลับไป
    }
  } catch (err) {
    console.log("Get user error", err); // แสดงข้อผิดพลาดในการค้นหาลูกค้า
    res.status(500).json({ error: err.message });
  }
};

module.exports = {
  createCustomer,
  getCustomers,
  deleteCustomer,
  updateCustomer,
  getCustomer,
};
