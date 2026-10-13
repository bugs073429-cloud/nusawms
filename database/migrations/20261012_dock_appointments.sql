-- Jalankan sekali pada database WMS yang sudah ada melalui phpMyAdmin.
-- Backup database sebelum menjalankan migration.
CREATE TABLE IF NOT EXISTS dock_doors (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 warehouse_id BIGINT UNSIGNED NOT NULL,
 dock_code VARCHAR(40) NOT NULL,
 name VARCHAR(120) NOT NULL,
 dock_type ENUM('INBOUND','OUTBOUND','BOTH') NOT NULL DEFAULT 'BOTH',
 is_active TINYINT(1) NOT NULL DEFAULT 1,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_dock_per_warehouse (warehouse_id,dock_code),
 CONSTRAINT fk_dock_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS appointments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 appointment_no VARCHAR(60) NOT NULL UNIQUE,
 order_id BIGINT UNSIGNED NOT NULL,
 dock_id BIGINT UNSIGNED NOT NULL,
 starts_at DATETIME NOT NULL,
 ends_at DATETIME NOT NULL,
 carrier VARCHAR(120) NULL,
 vehicle_no VARCHAR(40) NULL,
 driver_name VARCHAR(120) NULL,
 status ENUM('BOOKED','CHECKED_IN','IN_PROGRESS','COMPLETED','CANCELLED') NOT NULL DEFAULT 'BOOKED',
 notes VARCHAR(500) NULL,
 created_by BIGINT UNSIGNED NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 INDEX idx_appointment_dock_time (dock_id,starts_at,ends_at,status),
 INDEX idx_appointment_order_status (order_id,status),
 CONSTRAINT fk_appointment_order FOREIGN KEY (order_id) REFERENCES orders(id),
 CONSTRAINT fk_appointment_dock FOREIGN KEY (dock_id) REFERENCES dock_doors(id),
 CONSTRAINT fk_appointment_user FOREIGN KEY (created_by) REFERENCES users(id),
 CONSTRAINT chk_appointment_range CHECK (ends_at > starts_at)
) ENGINE=InnoDB;
