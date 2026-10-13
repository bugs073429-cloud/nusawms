# Mapping RFID (UID)

## Implemented
- Maps one unique RFID UID to one active product using `rfid_mappings`.
- Create and edit mappings, plus soft-deactivation with a required reason.
- Records create/update/deactivation actions in `audit_logs`.
- Product relationship is enforced with a foreign key; duplicate UIDs are rejected by a unique constraint.
- The UI accepts UID input from keyboard-wedge readers or manual entry.

## Hardware boundary
Direct reader integration is not enabled. USB/serial/network RFID readers can require a vendor SDK, driver, browser bridge, or reader-specific protocol. This module does not claim to activate the antenna or read tags directly. Reader name is metadata only.

## Existing database migration
Run `database/migrations/20261012_rfid_mappings.sql` once against the database selected in phpMyAdmin. Back up the database first. Fresh installations can use the updated `database/schema.sql`.

## Validation
UID values are trimmed, length-limited, and restricted to letters, digits, colon, underscore, and hyphen. Product must exist and be active. Deactivation retains the record and audit reason rather than deleting history.
