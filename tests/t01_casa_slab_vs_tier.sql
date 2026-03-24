SELECT 'SLAB' model, SUM(interest_amt) total_interest  from casa_interest_accrual
where pricing_model = 'SLAB' and as_of_date between DATE '2026-01-01' and DATE '2026-01-31';