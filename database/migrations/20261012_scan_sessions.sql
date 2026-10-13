-- Nusa WMS: scan session capture and pivot reporting.
-- Run once against the existing WMS database. Does not alter inventory balances.
CREATE TABLE IF NOT EXISTS scan_sessions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  session_code VARCHAR(40) NOT NULL UNIQUE,
  session_name VARCHAR(120) NOT NULL,
  status ENUM('OPEN','CLOSED') NOT NULL DEFAULT 'OPEN',
  created_by BIGINT UNSIGNED NULL,
  started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ended_at DATETIME NULL,
  INDEX idx_scan_sessions_status_owner(status, created_by, started_at),
  CONSTRAINT fk_scan_session_user FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS scan_session_events (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  session_id BIGINT UNSIGNED NOT NULL,
  raw_code VARCHAR(160) NOT NULL,
  product_id BIGINT UNSIGNED NULL,
  warehouse_id BIGINT UNSIGNED NULL,
  match_type ENUM('PRODUCT','RFID_UID','UNMATCHED') NOT NULL DEFAULT 'UNMATCHED',
  match_value VARCHAR(160) NULL,
  scanned_by BIGINT UNSIGNED NULL,
  scanned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_scan_event_session_time(session_id, scanned_at),
  INDEX idx_scan_event_product(product_id, scanned_at),
  CONSTRAINT fk_scan_event_session FOREIGN KEY (session_id) REFERENCES scan_sessions(id),
  CONSTRAINT fk_scan_event_product FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT fk_scan_event_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
  CONSTRAINT fk_scan_event_user FOREIGN KEY (scanned_by) REFERENCES users(id)
) ENGINE=InnoDB;
