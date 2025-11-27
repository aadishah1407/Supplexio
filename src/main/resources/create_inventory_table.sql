CREATE TABLE IF NOT EXISTS inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    min_threshold INT,
    max_threshold INT,
    kanban_status VARCHAR(50),
    auction_started BOOLEAN,
    needs_auction BOOLEAN,
    UNIQUE(item_name)
);
