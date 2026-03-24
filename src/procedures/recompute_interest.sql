CREATE OR REPLACE PROCEDURE recompute_interest(
   p_run_id      VARCHAR2,
   p_from_date   DATE,
   p_to_date     DATE,
   p_scope       VARCHAR2
) IS
   v_tol NUMBER;
   v_product_id NUMBER;
BEGIN
   SELECT product_id into v_product_id from product WHERE product_code = 'CASA';
   SELECT TO_NUMBER(param_value) INTO v_tol FROM config_param WHERE param_name = 'TOLERANCE_PAISE';
   pkg_interest_util.log_msg(p_run_id, 'INFO', 'Recompute started');
   
    IF p_scope IN ('CASA' , 'ALL') THEN
      DELETE FROM casa_interest_accrual WHERE as_of_date  BETWEEN p_from_date AND p_to_date;
	  pkg_casa.accrue_daily(p_run_id, p_from_date, p_to_date, v_product_id, NULL);
   	END IF;

    IF p_scope IN ('TD' , 'ALL') THEN
      DELETE FROM td_accrual WHERE as_of_date BETWEEN p_from_date AND p_to_date;
      pkg_td.accrue_daily(p_run_id, p_from_date, p_to_date, NULL);
    END IF;

    pkg_interest_util.log_msg(p_run_id, 'INFO', 'Recompute completed with tol='||v_tol);
END;	