document.addEventListener("DOMContentLoaded", async () => {
    const API_URL = "http://localhost:8800/api/v2/products"; // URL ของ Backend
    const container = document.getElementById("productContainer");

    try {
        const response = await fetch(API_URL);
        const products = await response.json();

        if (products.length === 0) {
            container.innerHTML = "<p>No products found.</p>";
            return;
        }

        products.forEach(product => {
            const productDiv = document.createElement("div");
            productDiv.classList.add("product");

            productDiv.innerHTML = `
                <img src="${product.image_url}" alt="${product.name}">
                <h3>${product.name}</h3>
                <p>${product.description}</p>
                <p><strong>Price:</strong> $${product.price}</p>
            `;

            container.appendChild(productDiv);
        });

    } catch (error) {
        console.error("Error fetching products:", error);
        container.innerHTML = "<p>Failed to load products.</p>";
    }
});