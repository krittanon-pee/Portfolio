const express = require("express");
const cors = require("cors");
const app = express();
const apiRouter = require("./routes/api"); // ✅ เส้นทาง API หลัก
const productRoutes = require("./routes/products"); // ✅ เพิ่ม routes สำหรับ products
const https = require("https");
const { swaggerSpecs, swaggerUI } = require("./swagger");
const cookieParser = require("cookie-parser");
const fs = require("fs");

// ✅ ใช้ middleware ที่จำเป็น
app.use(express.json());
app.use(cors({ origin: true, credentials: true }));
app.use(cookieParser());

// ✅ กำหนดเส้นทาง API
app.use("/api/v1", apiRouter); // API หลัก
app.use("/api/v2", productRoutes); // ✅ เส้นทางสำหรับ products

// ✅ Swagger API Docs
app.use("/api-docs", swaggerUI.serve, swaggerUI.setup(swaggerSpecs));

const ssl_options = {
  key: fs.readFileSync("ssl/key.pem"),
  cert: fs.readFileSync("ssl/cert.pem"),
};

const port = 8800;
const secure_port = 8443;

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});

https.createServer(ssl_options, app).listen(secure_port, () => {
  console.log(`HTTPS Server listening on port: ${secure_port}`);
});
 