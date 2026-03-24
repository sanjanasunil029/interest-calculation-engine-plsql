insert into casa_rate_tier(rate_id, product_id, effective_from, pricing_model, tier_min, tier_max, rate_pa)
values (100,1, DATE '2026-01-20', 'SLAB', 0, 50000, 0.0400);
begin
recompute_interest('RUN_TEST_RECOMP', DATE '2026-01-20', DATE '2026-01-31', 'CASA');
end;
/