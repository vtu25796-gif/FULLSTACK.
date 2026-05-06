const API_URL = 'http://localhost:3000/api';

// --- State ---
let currentToken = localStorage.getItem('ricsts_token');
let currentRole = localStorage.getItem('ricsts_role');
let currentUsername = ''; // Would normally get this from token payload via JWT decode

// --- DOM Elements ---
const loginView = document.getElementById('login-view');
const mainView = document.getElementById('main-view');
const loginForm = document.getElementById('login-form');
const loginError = document.getElementById('login-error');
const logoutBtn = document.getElementById('logout-btn');
const navLinks = document.querySelectorAll('.nav-links a');
const sections = document.querySelectorAll('.content-section');
const pageTitle = document.getElementById('page-title');

// Modals
const modalOverlay = document.getElementById('modal-overlay');
const modals = document.querySelectorAll('.modal');
const closeBtns = document.querySelectorAll('.close-modal, .cancel-modal');

// --- Initialization ---
function init() {
    if (currentToken) {
        showMainView();
        loadDashboard();
    } else {
        showLoginView();
    }
    setupEventListeners();
}

// --- Navigation & Views ---
function showLoginView() {
    loginView.classList.add('active');
    mainView.classList.remove('active');
}

function showMainView() {
    loginView.classList.remove('active');
    mainView.classList.add('active');
    // Basic JWT decoding to get username (simple base64 decode of payload)
    try {
        const payload = JSON.parse(atob(currentToken.split('.')[1]));
        document.getElementById('current-user').textContent = payload.username;
    } catch (e) {
        document.getElementById('current-user').textContent = 'Admin User';
    }
}

function switchSection(targetId) {
    sections.forEach(sec => sec.classList.remove('active'));
    document.getElementById(targetId).classList.add('active');

    navLinks.forEach(link => {
        if (link.dataset.target === targetId) {
            link.classList.add('active');
            pageTitle.textContent = link.textContent;
        } else {
            link.classList.remove('active');
        }
    });

    // Load data based on section
    if (targetId === 'dashboard') loadDashboard();
    else if (targetId === 'products') loadProducts();
    else if (targetId === 'suppliers') loadSuppliers();
    else if (targetId === 'transactions') loadTransactions();
}

// --- API Helper ---
async function apiCall(endpoint, options = {}) {
    const headers = {
        'Content-Type': 'application/json',
        ...(currentToken ? { 'Authorization': `Bearer ${currentToken}` } : {})
    };

    const response = await fetch(`${API_URL}${endpoint}`, {
        ...options,
        headers
    });

    const data = await response.json();

    if (!response.ok) {
        if (response.status === 401 || response.status === 403) {
            logout();
        }
        throw new Error(data.error || 'API Error');
    }

    return data;
}

// --- Auth ---
loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    try {
        loginError.textContent = '';
        const data = await apiCall('/auth/login', {
            method: 'POST',
            body: JSON.stringify({ username, password })
        });

        currentToken = data.token;
        currentRole = data.role;
        localStorage.setItem('ricsts_token', currentToken);
        localStorage.setItem('ricsts_role', currentRole);

        loginForm.reset();
        showMainView();
        loadDashboard();
    } catch (err) {
        loginError.textContent = err.message;
    }
});

function logout() {
    currentToken = null;
    currentRole = null;
    localStorage.removeItem('ricsts_token');
    localStorage.removeItem('ricsts_role');
    showLoginView();
}

logoutBtn.addEventListener('click', logout);

// --- Event Listeners ---
function setupEventListeners() {
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            switchSection(e.target.dataset.target);
        });
    });

    // Modal Triggers
    document.getElementById('btn-add-product').addEventListener('click', () => openModal('product'));
    document.getElementById('btn-add-supplier').addEventListener('click', () => openModal('supplier'));
    document.getElementById('btn-add-transaction').addEventListener('click', () => openModal('transaction'));

    // Modal Close
    closeBtns.forEach(btn => {
        btn.addEventListener('click', closeModal);
    });

    // Forms
    document.getElementById('supplier-form').addEventListener('submit', handleSupplierSubmit);
    document.getElementById('product-form').addEventListener('submit', handleProductSubmit);
    document.getElementById('transaction-form').addEventListener('submit', handleTransactionSubmit);
}

// --- Modals ---
async function openModal(type, id = null) {
    modalOverlay.classList.add('active');
    document.getElementById(`modal-${type}`).classList.add('active');

    if (type === 'product') {
        await populateSupplierDropdown('product-supplier');
        const isEdit = id !== null;
        document.getElementById('modal-product-title').textContent = isEdit ? 'Edit Product' : 'Add Product';
        document.getElementById('product-quantity-group').style.display = isEdit ? 'none' : 'block';

        if (isEdit) {
            // Fetch product logic here
            const p = await apiCall(`/products/${id}`);
            document.getElementById('product-id').value = p.id;
            document.getElementById('product-name').value = p.name;
            document.getElementById('product-sku').value = p.sku;
            document.getElementById('product-category').value = p.category;
            document.getElementById('product-price').value = p.price;
            document.getElementById('product-supplier').value = p.supplier_id;
        } else {
            document.getElementById('product-form').reset();
            document.getElementById('product-id').value = '';
        }
    } else if (type === 'supplier') {
        const isEdit = id !== null;
        document.getElementById('modal-supplier-title').textContent = isEdit ? 'Edit Supplier' : 'Add Supplier';
        if (!isEdit) {
            document.getElementById('supplier-form').reset();
            document.getElementById('supplier-id').value = '';
        }
    } else if (type === 'transaction') {
        await populateProductDropdown('transaction-product');
        document.getElementById('transaction-form').reset();
        document.getElementById('transaction-error').textContent = '';
    }
}

function closeModal() {
    modalOverlay.classList.remove('active');
    modals.forEach(m => m.classList.remove('active'));
}

// --- Data Loading & Rendering ---

// Dashboard
async function loadDashboard() {
    try {
        const stats = await apiCall('/dashboard/summary');
        document.getElementById('stat-products').textContent = stats.totalProducts;
        document.getElementById('stat-suppliers').textContent = stats.totalSuppliers;
        document.getElementById('stat-items').textContent = stats.totalItemsInStock;
        document.getElementById('stat-value').textContent = `$${parseFloat(stats.totalStockValue).toFixed(2)}`;

        const lowStock = await apiCall('/dashboard/low-stock?threshold=10');
        const tbody = document.getElementById('low-stock-list');
        tbody.innerHTML = '';

        if (lowStock.length === 0) {
            tbody.innerHTML = '<tr><td colspan="3" style="text-align:center; color: var(--text-secondary)">No low stock items</td></tr>';
        } else {
            lowStock.forEach(item => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${item.sku}</td>
                    <td>${item.name}</td>
                    <td class="text-danger"><b>${item.quantity}</b></td>
                `;
                tbody.appendChild(tr);
            });
        }
    } catch (err) {
        console.error('Error loading dashboard', err);
    }
}

// Suppliers
async function loadSuppliers() {
    try {
        const suppliers = await apiCall('/suppliers');
        const tbody = document.getElementById('suppliers-list');
        tbody.innerHTML = '';

        suppliers.forEach(s => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${s.name}</td>
                <td>${s.contact_email || '-'}</td>
                <td>${s.phone || '-'}</td>
                <td>${s.address || '-'}</td>
                <td>
                    <button class="btn btn-sm btn-outline edit-supplier" data-id="${s.id}">Edit</button>
                    <button class="btn btn-sm btn-danger delete-supplier" data-id="${s.id}">Delete</button>
                </td>
            `;
            tbody.appendChild(tr);
        });

        // Attach events
        document.querySelectorAll('.edit-supplier').forEach(btn => btn.addEventListener('click', async (e) => {
            // Basic edit setup
            const id = e.target.dataset.id;
            const supplierData = suppliers.find(sup => sup.id == id);

            openModal('supplier', id);
            document.getElementById('supplier-id').value = supplierData.id;
            document.getElementById('supplier-name').value = supplierData.name;
            document.getElementById('supplier-email').value = supplierData.contact_email;
            document.getElementById('supplier-phone').value = supplierData.phone;
            document.getElementById('supplier-address').value = supplierData.address;
        }));

        document.querySelectorAll('.delete-supplier').forEach(btn => btn.addEventListener('click', async (e) => {
            if (confirm('Are you sure you want to delete this supplier?')) {
                try {
                    await apiCall(`/suppliers/${e.target.dataset.id}`, { method: 'DELETE' });
                    loadSuppliers(); // reload list
                } catch (err) {
                    alert(err.message);
                }
            }
        }));

    } catch (err) {
        console.error('Error loading suppliers', err);
    }
}

async function handleSupplierSubmit(e) {
    e.preventDefault();
    const id = document.getElementById('supplier-id').value;
    const isEdit = id !== '';

    const payload = {
        name: document.getElementById('supplier-name').value,
        contact_email: document.getElementById('supplier-email').value,
        phone: document.getElementById('supplier-phone').value,
        address: document.getElementById('supplier-address').value
    };

    try {
        if (isEdit) {
            await apiCall(`/suppliers/${id}`, { method: 'PUT', body: JSON.stringify(payload) });
        } else {
            await apiCall('/suppliers', { method: 'POST', body: JSON.stringify(payload) });
        }
        closeModal();
        loadSuppliers();
    } catch (err) {
        alert(err.message);
    }
}

// Products
async function loadProducts() {
    try {
        const products = await apiCall('/products');
        const tbody = document.getElementById('products-list');
        tbody.innerHTML = '';

        products.forEach(p => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${p.sku}</td>
                <td>${p.name}</td>
                <td>${p.category || '-'}</td>
                <td>$${parseFloat(p.price).toFixed(2)}</td>
                <td><b>${p.quantity}</b></td>
                <td>${p.supplier_name || 'N/A'}</td>
                <td>
                    <button class="btn btn-sm btn-outline edit-product" data-id="${p.id}">Edit</button>
                    <button class="btn btn-sm btn-danger delete-product" data-id="${p.id}">Delete</button>
                </td>
            `;
            tbody.appendChild(tr);
        });

        // Attach events
        document.querySelectorAll('.edit-product').forEach(btn => btn.addEventListener('click', (e) => {
            openModal('product', e.target.dataset.id);
        }));

        document.querySelectorAll('.delete-product').forEach(btn => btn.addEventListener('click', async (e) => {
            if (confirm('Are you sure you want to delete this product?')) {
                try {
                    await apiCall(`/products/${e.target.dataset.id}`, { method: 'DELETE' });
                    loadProducts();
                } catch (err) {
                    alert(err.message);
                }
            }
        }));

    } catch (err) {
        console.error('Error loading products', err);
    }
}

async function populateSupplierDropdown(selectId) {
    const suppliers = await apiCall('/suppliers');
    const select = document.getElementById(selectId);
    select.innerHTML = '<option value="">Select a supplier...</option>';
    suppliers.forEach(s => {
        const opt = document.createElement('option');
        opt.value = s.id;
        opt.textContent = s.name;
        select.appendChild(opt);
    });
}

async function populateProductDropdown(selectId) {
    const products = await apiCall('/products');
    const select = document.getElementById(selectId);
    select.innerHTML = '<option value="">Select a product...</option>';
    products.forEach(p => {
        const opt = document.createElement('option');
        opt.value = p.id;
        opt.textContent = `${p.sku} - ${p.name} (Stock: ${p.quantity})`;
        select.appendChild(opt);
    });
}

async function handleProductSubmit(e) {
    e.preventDefault();
    const id = document.getElementById('product-id').value;
    const isEdit = id !== '';

    const payload = {
        name: document.getElementById('product-name').value,
        sku: document.getElementById('product-sku').value,
        category: document.getElementById('product-category').value,
        price: document.getElementById('product-price').value,
        supplier_id: document.getElementById('product-supplier').value
    };

    if (!isEdit) {
        payload.quantity = document.getElementById('product-quantity').value;
    }

    try {
        if (isEdit) {
            await apiCall(`/products/${id}`, { method: 'PUT', body: JSON.stringify(payload) });
        } else {
            await apiCall('/products', { method: 'POST', body: JSON.stringify(payload) });
        }
        closeModal();
        loadProducts();
    } catch (err) {
        alert(err.message);
    }
}

// Transactions
async function loadTransactions() {
    try {
        const transactions = await apiCall('/transactions');
        const tbody = document.getElementById('transactions-list');
        tbody.innerHTML = '';

        transactions.forEach(t => {
            const tr = document.createElement('tr');
            const date = new Date(t.transaction_date).toLocaleString();
            const typeClass = t.type === 'IN' ? 'status-in' : 'status-out';
            const sign = t.type === 'IN' ? '+' : '-';

            tr.innerHTML = `
                <td>${date}</td>
                <td>${t.product_name}</td>
                <td><span class="status-badge ${typeClass}">${t.type}</span></td>
                <td><b>${sign}${t.quantity}</b></td>
                <td>${t.recorded_by || 'Unknown'}</td>
                <td>${t.notes || '-'}</td>
            `;
            tbody.appendChild(tr);
        });
    } catch (err) {
        console.error('Error loading transactions', err);
    }
}

async function handleTransactionSubmit(e) {
    e.preventDefault();
    const errorEl = document.getElementById('transaction-error');
    errorEl.textContent = '';

    const payload = {
        product_id: document.getElementById('transaction-product').value,
        type: document.querySelector('input[name="transaction-type"]:checked').value,
        quantity: parseInt(document.getElementById('transaction-quantity').value, 10),
        notes: document.getElementById('transaction-notes').value
    };

    try {
        await apiCall('/transactions', { method: 'POST', body: JSON.stringify(payload) });
        closeModal();
        loadTransactions();
    } catch (err) {
        errorEl.textContent = err.message;
    }
}

// Start app
init();
