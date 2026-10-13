-- Nusa WMS: RFID UID to product mapping. Safe to run once on an existing database.
CREATE TABLE IF NOT EXISTS rfid_mappings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(160) NOT NULL UNIQUE,
  product_id BIGINT UNSIGNED NOT NULL,
  reader_name VARCHAR(120) NULL,
  notes VARCHAR(500) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_by BIGINT UNSIGNED NULL,
  deactivated_by BIGINT UNSIGNED NULL,
  deactivation_reason VARCHAR(250) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deactivated_at DATETIME NULL,
  INDEX idx_rfid_product(product_id,is_active),
  CONSTRAINT fk_rfid_product FOREIGN KEY(product_id) REFERENCES products(id),
  CONSTRAINT fk_rfid_created_by FOREIGN KEY(created_by) REFERENCES users(id),
  CONSTRAINT fk_rfid_deactivated_by FOREIGN KEY(deactivated_by) REFERENCES users(id)
) ENGINE=InnoDB;
