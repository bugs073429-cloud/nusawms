# Stock consistency test procedure

Run `database/diagnostics/stock_consistency_checks.sql` in phpMyAdmin against the WMS database after creating test data. Each query should return **zero rows** after the initial stock has been represented by an `OPENING` ledger movement.

Suggested isolated test sequence:
1. Create two warehouses, one active product, and one location per warehouse.
2. Post inbound +100. Verify inventory=100 and ledger sum=100.
3. Post outbound -30. Verify available inventory=70 and ledger sum=70.
4. Attempt outbound -71. It must be rejected and neither inventory nor ledger/order rows should change.
5. Transfer 20 from warehouse A to B. Verify A=50, B=20; transfer ledger has exactly one OUT (-20) and one IN (+20).
6. Re-run all diagnostic SQL. Every query must return zero rows.
7. Force a database constraint failure during a test transaction (in a non-production database). Verify rollback leaves both inventory and ledger unchanged.
8. Repeat inbound requests concurrently in a staging database and check for duplicate inventory keys.

Important: a database-free syntax check does not replace these integration tests. Never run destructive tests on production data.
