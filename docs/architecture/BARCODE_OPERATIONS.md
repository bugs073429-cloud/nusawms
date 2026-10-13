# Barcode in operational workflows

The inbound/outbound and warehouse transfer forms accept keyboard-wedge barcode scanners (including most USB scanners) and manual entry. The scanned SKU or barcode is resolved against the active `products` master and selects the canonical product ID; it does not create a product or post a transaction automatically.

For camera-based scanning, use **Pindai Barcode / QR** first and allow camera access in a secure browser context (HTTPS or localhost). Camera permission is browser-controlled. After matching a code in an operational form, verify warehouse/location and quantity before posting. Outbound and transfer stock availability remains enforced by the server-side transaction handlers.

Codes must match `products.sku` or `products.barcode` exactly after trimming and case-insensitive comparison. If no match is found, the form displays a validation error and blocks posting until corrected. QR payloads containing additional metadata must encode the SKU or barcode as the whole decoded value to match this MVP.
