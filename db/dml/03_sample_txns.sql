--CASA Account + Txns 
INSERT INTO casa_account(acct_id, cust_id, product_id, open_date) VALUES (2001, 1001, 1, DATE '2025-12-20');
INSERT INTO txn(txn_id, acct_id, posting_date, value_date, amount, txn_type, narrative) 
VALUES (seq_txn.NEXTVAL, 2001, DATE '2026-01-02', DATE '2026-01-02', 100000, 'CR', 'Initial deposit');
INSERT INTO txn(txn_id, acct_id, posting_date, value_date, amount, txn_type, narrative) 
VALUES (seq_txn.NEXTVAL, 2001, DATE '2026-01-10', DATE '2026-01-08', -20000, 'DR', 'ATM withdrawal'); 

-- TD
INSERT INTO td_account(td_id, cust_id, product_id, principal_amt, open_date, maturity_date, nominal_rate, comp_freq)
VALUES (3001, 1001, 2, 500000, DATE '2025-12-15', DATE '2026-12-15', 0.0700, 'QUARTERLY'); COMMIT;