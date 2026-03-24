--CASA Rate: slab model from Jan 1, 2026 
INSERT INTO casa_rate_tier(rate_ id, product_ id, effective_from, pricing_model, tier_min, tier_max, rate_pa) 
VALUES (1, 1, DATE "2026-01-01",I 'SLAB', 0, 50000, 0.0300); 
INSERT INTO casa_rate_tier(rate id, product_id, effective_from, pricing_model, tier_min, tier_max, rate_pa) 
VALUES (2, 1, DATE "2026-01-01", "SLAB", 50000, NULL, 0.0350).
-- For Tiered demo (effective later) 
INSERT INTO casa_rate_tier(rate_id, product_id, effective_from, pricing_model, tier_min, tier_max, rate_pa) 
VALUES (10, 1, DATE '2026-03-01', 'TIERED', 0, 100000, 0.0320); 
INSERT INTO casa_rate_tier(rate_id, product_id, effective_from, pricing_model, tier_min, tier_max, rate_pa) 
VALUES (11, 1, DATE "2026-03-01", "TIERED", 100000, NULL, 0.0380);