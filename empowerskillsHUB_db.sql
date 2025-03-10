-- Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type ENUM('artisan', 'client', 'admin', 'account_manager') NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    profile_picture VARCHAR(255),
    bio TEXT,
    location VARCHAR(100),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    account_status ENUM('active', 'suspended', 'inactive') DEFAULT 'active',
    average_rating DECIMAL(3,2) DEFAULT 0.00
);

-- Categories Table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES Categories(category_id) ON DELETE SET NULL
);

-- Services Table
CREATE TABLE Services (
    service_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration VARCHAR(50),
    availability TEXT,
    is_featured BOOLEAN DEFAULT FALSE,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive', 'pending_approval') DEFAULT 'pending_approval',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE CASCADE
);

-- Products/Listings Table
CREATE TABLE Listings (
    listing_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    quantity INT DEFAULT 1,
    condition ENUM('new', 'used', 'refurbished') DEFAULT 'new',
    is_featured BOOLEAN DEFAULT FALSE,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive', 'sold', 'pending_approval') DEFAULT 'pending_approval',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE CASCADE
);

-- Listing Images Table
CREATE TABLE Listing_Images (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    listing_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES Listings(listing_id) ON DELETE CASCADE
);

-- Service Images Table
CREATE TABLE Service_Images (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    service_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES Services(service_id) ON DELETE CASCADE
);

-- Bookings Table
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    service_id INT NOT NULL,
    client_id INT NOT NULL,
    artisan_id INT NOT NULL,
    booking_date TIMESTAMP NOT NULL,
    start_time TIME,
    end_time TIME,
    status ENUM('pending', 'confirmed', 'completed', 'cancelled') DEFAULT 'pending',
    notes TEXT,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES Services(service_id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (artisan_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Orders Table (for product purchases)
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    buyer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    shipping_address TEXT,
    shipping_method VARCHAR(100),
    tracking_number VARCHAR(100),
    notes TEXT,
    FOREIGN KEY (buyer_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Order Items Table
CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    listing_id INT NOT NULL,
    seller_id INT NOT NULL,
    quantity INT NOT NULL,
    price_per_unit DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (listing_id) REFERENCES Listings(listing_id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Payments Table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    payment_type ENUM('order', 'booking', 'payout') NOT NULL,
    reference_id INT NOT NULL,
    payer_id INT NOT NULL,
    payee_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('mobile_money', 'card', 'bank_transfer') NOT NULL,
    payment_details JSON,
    transaction_id VARCHAR(100) UNIQUE,
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payer_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (payee_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Reviews & Ratings Table
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    reviewer_id INT NOT NULL,
    reviewed_id INT NOT NULL,
    reference_type ENUM('service', 'listing', 'user') NOT NULL,
    reference_id INT NOT NULL,
    rating DECIMAL(3,2) NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reviewer_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Messages Table
CREATE TABLE Messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Conversations Table (to group messages)
CREATE TABLE Conversations (
    conversation_id INT PRIMARY KEY AUTO_INCREMENT,
    user1_id INT NOT NULL,
    user2_id INT NOT NULL,
    last_message_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user1_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (user2_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (last_message_id) REFERENCES Messages(message_id) ON DELETE SET NULL
);

-- Notifications Table
CREATE TABLE Notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    reference_type VARCHAR(50),
    reference_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Create indexes for improved query performance
CREATE INDEX idx_users_user_type ON Users(user_type);
CREATE INDEX idx_services_category ON Services(category_id);
CREATE INDEX idx_listings_category ON Listings(category_id);
CREATE INDEX idx_bookings_status ON Bookings(status);
CREATE INDEX idx_orders_status ON Orders(status);
CREATE INDEX idx_payments_status ON Payments(status);