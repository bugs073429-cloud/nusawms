-- Read-only diagnostics. Run against the selected WMS database after posting test transactions.
-- 1) Inventory balance must equal ledger sum for each product/warehouse/location/batch.
SELECT k.product_id,k.warehouse_id,k.location_id,k.batch_id,
       COALESCE(i.qty,0) inventory_qty,COALESCE(m.qty,0) ledger_qty,
       COALESCE(i.qty,0)-COALESCE(m.qty,0) difference
FROM (
  SELECT product_id,warehouse_id,location_id,batch_id FROM inventory
  UNION
  SELECT product_id,warehouse_id,location_id,batch_id FROM stock_movements
) k
LEFT JOIN (SELECT product_id,warehouse_id,location_id,batch_id,SUM(qty_on_hand) qty FROM inventory GROUP BY product_id,warehouse_id,location_id,batch_id) i
  ON i.product_id=k.product_id AND i.warehouse_id=k.warehouse_id AND i.location_id <=> k.location_id AND i.batch_id <=> k.batch_id
LEFT JOIN (SELECT product_id,warehouse_id,location_id,batch_id,SUM(qty_change) qty FROM stock_movements GROUP BY product_id,warehouse_id,location_id,batch_id) m
  ON m.product_id=k.product_id AND m.warehouse_id=k.warehouse_id AND m.location_id <=> k.location_id AND m.batch_id <=> k.batch_id
WHERE ABS(COALESCE(i.qty,0)-COALESCE(m.qty,0)) > 0.0005;

-- 2) Completed transfers should have exactly one OUT and one IN movement per transfer item.
-- This starter transfer flow currently supports one item per transfer.
SELECT t.id,t.transfer_no,
       SUM(sm.movement_type='TRANSFER_OUT') out_count,
       SUM(sm.movement_type='TRANSFER_IN') in_count,
       SUM(CASE WHEN sm.movement_type='TRANSFER_OUT' THEN -sm.qty_change ELSE 0 END) qty_out,
       SUM(CASE WHEN sm.movement_type='TRANSFER_IN' THEN sm.qty_change ELSE 0 END) qty_in
FROM transfers t LEFT JOIN stock_movements sm ON sm.reference_type='transfer' AND sm.reference_id=t.id
WHERE t.status='RECEIVED'
GROUP BY t.id,t.transfer_no
HAVING out_count<>1 OR in_count<>1 OR ABS(qty_out-qty_in)>0.0005;

-- 3) Movement rows need a complete source reference to be traceable.
SELECT id,movement_no,movement_type,reference_type,reference_id,reference_no
FROM stock_movements
WHERE reference_type IS NULL OR reference_id IS NULL OR reference_no IS NULL;

-- 4) No negative stock or reserved quantity above on-hand should exist.
SELECT id,product_id,warehouse_id,location_id,batch_id,qty_on_hand,qty_reserved
FROM inventory
WHERE qty_on_hand < 0 OR qty_reserved < 0 OR qty_reserved > qty_on_hand;
