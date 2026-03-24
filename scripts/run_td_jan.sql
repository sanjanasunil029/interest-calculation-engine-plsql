INSERT INTO run_control(run_id, process_name, from_date, to_date, scope_product, created_by)
VALUES ('RUN_TD_2026JAN', 'TD_ACCRUAL', DATE '2026-01-01', DATE '2026-01-31', 'TD', 'SANJANA');

BEGIN
  pkg_td.accrue_daily('RUN_TD_2026JAN', DATE '2026-01-01', DATE '2026-01-31', NULL);
END;
/
SELECT 3001 td_id, pkg_td.maturity_value(3001) as maturity_value FROM dual;