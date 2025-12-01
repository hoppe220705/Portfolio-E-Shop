-- -----------------------------------------
-- CREATE DATABASES
-- -----------------------------------------

CREATE DATABASE STAGING CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE DATASTORE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE DATAMART_DEV CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE DATAMART_PRD CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE METADATA CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- -----------------------------------------
-- STAGING
-- -----------------------------------------

USE STAGING;

CREATE TABLE category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    modified_by_user VARCHAR(50)
);

CREATE TABLE article (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    is_deleted BOOLEAN DEFAULT FALSE,
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    modified_by_user VARCHAR(50),
    FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE CASCADE
);

CREATE TABLE customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    street VARCHAR(100),
    house_number VARCHAR(20),
    postal_code VARCHAR(20),
    city VARCHAR(50),
    country VARCHAR(50),
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    modified_by_user VARCHAR(50)
);

CREATE TABLE transaction_head (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Open',
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    modified_by_user VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE
);

CREATE TABLE transaction_position (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_head_id INT NOT NULL,
    article_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    modified_by_user VARCHAR(50),
    FOREIGN KEY (transaction_head_id) REFERENCES transaction_head(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES article(id)
);

-- -----------------------------------------
-- DATASTORE
-- -----------------------------------------

USE DATASTORE;

CREATE TABLE category LIKE STAGING.category;
CREATE TABLE article LIKE STAGING.article;
CREATE TABLE customer LIKE STAGING.customer;
CREATE TABLE transaction_head LIKE STAGING.transaction_head;
CREATE TABLE transaction_position LIKE STAGING.transaction_position;

-- -----------------------------------------
-- DATAMART_DEV
-- -----------------------------------------

USE DATAMART_DEV;

CREATE TABLE category LIKE STAGING.category;
CREATE TABLE article LIKE STAGING.article;
CREATE TABLE customer LIKE STAGING.customer;
CREATE TABLE transaction_head LIKE STAGING.transaction_head;
CREATE TABLE transaction_position LIKE STAGING.transaction_position;

-- -----------------------------------------
-- DATAMART_PRD
-- -----------------------------------------

USE DATAMART_PRD;

CREATE TABLE category LIKE STAGING.category;
CREATE TABLE article LIKE STAGING.article;
CREATE TABLE customer LIKE STAGING.customer;
CREATE TABLE transaction_head LIKE STAGING.transaction_head;
CREATE TABLE transaction_position LIKE STAGING.transaction_position;

-- -----------------------------------------
-- METADATA + PROCEDURE
-- -----------------------------------------

USE METADATA;

DELIMITER $$

CREATE PROCEDURE swap_table(
    IN db1 VARCHAR(64),
    IN db2 VARCHAR(64),
    IN tbl VARCHAR(64)
)
BEGIN
    SET @tmp = CONCAT(db1, '.', tbl, '_tmp_swap');

    SET @sql1 = CONCAT('RENAME TABLE ', db1, '.', tbl, ' TO ', @tmp);
    SET @sql2 = CONCAT('RENAME TABLE ', db2, '.', tbl, ' TO ', db1, '.', tbl);
    SET @sql3 = CONCAT('RENAME TABLE ', @tmp, ' TO ', db2, '.', tbl);

    PREPARE stmt1 FROM @sql1;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    PREPARE stmt2 FROM @sql2;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;

    PREPARE stmt3 FROM @sql3;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;
END $$

DELIMITER ;
