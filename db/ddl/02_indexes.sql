CREATE INDEX ix_txn_valdate ON txn (acct_id, value_date);
CREATE INDEX ix_eod_date ON casa_eod_balance (as_of_date); 
CREATE INDEX ix_rate_eff ON casa_rate_tier (product_id, effective_from, NVL(effective_to, TO_DATE('9999-12-31','YYYY-MM-DD'))); 
CREATE INDEX ix_td_dates ON td_account (open_date, maturity_date); 
CREATE INDEX ix_casa_accrual_date ON casa_interest_accrual (as_of_date); 
CREATE INDEX ix_td_accrual_date ON td_accrual (as_of_date);