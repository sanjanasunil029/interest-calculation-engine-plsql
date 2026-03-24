INSERT INTO run_control(run_id, process_name, from_date, to_date, scope_product, created_by)
VALUES ('RUN_2026JAN01_31', 'CASA_ACCRUAL', DATE '2026-01-01', DATE '2026-01-31', 'CASA', 'SANJANA');
DECLARE
    v_product_id NUMBER;
BEGIN 
   SELECT product_id into v_product_id FROM product WHERE product_code = 'CASA';
   pkg_casa.accrue_daily( 'RUN_2026JAN01_31', DATE '2026-01-01', DATE '2026-01-31',
                       v_product_id);
END;
/
DECLARE
    v_product_id NUMBER;
BEGIN
   SELECT product_id into v_product_id FROM product WHERE product_code = 'CASA';
   pkg_casa.post_monthly('RUN_2026JAN01_EOM', DATE '2026-01-31',
                         v_product_id);
END;
/
COL acct_id    FORMAT 99999
COL as_of_date FORMAT A12

SELECT * FROM (
    SELECT acct_id, TO_CHAR(as_of_date,'YYYY-MM-DD') as_of_date, interest_amt
	from casa_interest_accrual WHERE as_of_date BETWEEN DATE '2026-01-01' AND DATE '2026-01-31'
	ORDER BY acct_id, as_of_date
	) WHERE ROWNUM <= 20;
	
SELECT * FROM casa_interest_posting ORDER BY posted_on DESC;