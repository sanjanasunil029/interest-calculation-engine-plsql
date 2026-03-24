CREATE or REPLACE PACKAGE BODY pkg_td AS
    PROCEDURE accrue_daily(p_run_id VARCHAR2, p_from_date DATE, p_to_date DATE, p_td_id NUMBER) IS  
      v_basis VARCHAR2(20);
      --:= NVL((SELECT  param_value from config_param where param_namme = 'TO_DAY_COUNT'), 'ACT/365');
    BEGIN
      SELECT NVL(param_value, 'ACT/365') INTO v_basis FROM config_param WHERE param_name = 'TO_DAY_COUNT';
	  MERGE INTO  td_accrual t USING (
	  WITH scope_td AS (
	    SELECT td_id, principal_amt, nominal_rate, open_date, maturity_date from td_account
		WHERE (p_td_id IS NULL  OR td_id = p_td_id)
	  ),
	  days AS (
	  SELECT p_from_date + LEVEL - 1 AS dday FROM dual
	  CONNECT BY LEVEL <= (p_to_date - p_from_date + 1)
	  )
	  SELECT s.td_id, d.dday as as_of_date,
	  (s.principal_amt * s.nominal_rate) / pkg_interest_util.day_count_denominator(d.dday, v_basis) AS  interest_amt
	  FROM scope_td s join days d 
	  on d.dday BETWEEN GREATEST(s.open_date, p_from_date) AND LEAST(s.maturity_date, p_to_date)
	  ) s 
	  on (t.td_id = s.td_id AND t.as_of_date = s.as_of_date)
	  WHEN MATCHED THEN 
	  UPDATE SET t.interest_amt = s.interest_amt,
	             t.run_id = p_run_id,
				 t.calc_basis = v_basis
	  WHEN NOT MATCHED THEN
	  INSERT (td_id, as_of_date, interest_amt, run_id, calc_basis)
	  VALUES (s.td_id, s.as_of_date, s.interest_amt, p_run_id, v_basis);
	  
	  pkg_interest_util.log_msg(p_run_id, 'INFO', 'TD ACCURAL COMPLETED FOR' || TO_CHAR(p_from_date, 'YYYY-MM-DD')||'..'||TO_CHAR(p_to_date,'YYYY-MM-DD'));
    END;
	
	FUNCTION  maturity_value(p_td_id NUMBER) RETURN NUMBER IS
	v_principal   NUMBER;
	v_rate        NUMBER;
	v_open        DATE;
	v_maturity    DATE;
	v_comp        VARCHAR2(10);
	v_n           NUMBER;
	v_m           NUMBER;
	v_years       NUMBER;
	BEGIN
	  SELECT principal_amt, nominal_rate, open_date, maturity_date, comp_freq
	  INTO v_principal,v_rate, v_open, v_maturity, v_comp from td_account where td_id = p_td_id;
	  
	  v_m := case v_comp WHEN 'MONTHLY' THEN 12 WHEN  'QUATERLY' THEN 4 ELSE 1 END;
	  v_years :=  MONTHS_BETWEEN(v_maturity,v_open)/12;
	  v_n := v_m * v_years;
	   RETURN v_principal * POWER(1 + v_rate/v_m, v_n);
	END;

    PROCEDURE apply_closure(
      p_run_id      VARCHAR2,
      p_td_id       NUMBER,	  
      p_closure_dt  DATE,
      p_amount      NUMBER,
      p_type        VARCHAR2,
      p_penalty_bps NUMBER	  
	) IS
      v_principal   NUMBER;
      v_rate        NUMBER;
      v_open        DATE;
      v_comp        VARCHAR2(10);
      v_penalty     NUMBER := NVL(p_penalty_bps, 0);
    BEGIN
      SELECT principal_amt, nominal_rate, open_date, comp_freq
      INTO v_principal,  v_rate, v_open, v_comp
      FROM td_account WHERE td_id = p_td_id FOR UPDATE;

      IF p_type = 'PRECLOSE' THEN
        UPDATE td_account SET nominal_rate = GREATEST(v_rate - v_penalty,0), maturity_date = p_closure_dt, status_code = 'CLOSED'
        WHERE td_id = p_td_id;
      ELSIF p_type = 'PARTIAL' THEN
        UPDATE td_account SET principal_amt =  v_principal - p_amount 
        WHERE td_id = p_td_id;
      ELSIF p_type = 'FULL' THEN
        UPDATE td_account SET maturity_date = p_closure_dt, status_code = 'CLOSED'
        WHERE td_id = p_td_id;
      END IF;

      INSERT INTO td_closure(closure_id, td_id, closure_date, closure_type, amount, penalty_bps, note)
      VALUES (seq_td_closure_id.NEXTVAL, p_td_id, p_closure_dt, p_type, p_amount, v_penalty, 'Applied by run '||p_run_id);
    END;
END pkg_td;	