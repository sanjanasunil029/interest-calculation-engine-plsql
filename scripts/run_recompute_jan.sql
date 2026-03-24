INSERT INTO casa_rate_tier(rate_id, product_id, effective_from, pricing_model, tier_min, tier_max, rate_pa)
VALUES (3, 1, DATE  '2026-01-15', 'SLAB', 0, 50000, 0.0310);
COMMIT;

BEGIN
  recompute_interest('RUN_RECOM_JAN15_31', DATE '2026-01-15', DATE '2026-01-31', 'CASA');
END;
/
SELECT acct_id, TO_CHAR(as_of_date,'YYYY-MM-DD') as_of_date, interest_amt
FROM casa_interest_accrual
WHERE  as_of_date BETWEEN DATE '2026-01-15' AND DATE '2026-01-31'
ORDER BY acct_id, as_of_date;  