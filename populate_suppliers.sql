DELIMITER $$
CREATE PROCEDURE InsertRandomSuppliers()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 100 DO
        INSERT INTO suppliers (name, email, phone, address, password)
        VALUES (
            CONCAT('Supplier ', i),
            CONCAT('supplier', i, '@example.com'),
            CONCAT('123-456-', LPAD(i, 4, '0')),
            CONCAT('Address for supplier ', i),
            'password123' -- In a real application, use a hashed password
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

CALL InsertRandomSuppliers();
