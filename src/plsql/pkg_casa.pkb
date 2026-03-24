CREATE OR REPLACE PACKAGE BODY pkg_casa AS
  PROCEDURE accrue_daily(
   p_run_id     VARCHAR2,
   p_from_date  DATE,
   p_to_date    DATE,
   p_product_id NUMBER,
   p_acct_id    NUMBER
  ) IS
    v_basis VARCHAR2(20);
   BEGIN
   compute_casa_eod(p_from_date => p_from_date, p_to_date => p_to_date ,p_acct_id => p_acct_id);

   SELECT NVL((SELECT param_value FROM config_param WHERE param_name = 'CASA_DAY_COUNT'),'ACT/365_366') INTO v_basis  from dual;
   
   MERGE INTO casa_interest_accrual t 
   USING(
    SELECT e.acct_id,
	       e.as_of_date,
		   r.rate_pa,
		   e.eod_balance,
		   pkg_interest_util.day_count_denominator(e.as_of_date, v_basis) as denom
	FROM casa_eod_balance e join casa_account a  ON a.acct_id =  e.acct_id AND a.product_id = p_product_id	
	                        join casa_rate_tier r ON r.product_id = p_product_id
							AND r.pricing_model = 'TIERED'
							AND r.effective_from  <= e.as_of_date
							AND NVL(r.effective_to, DATE '9999-12-31') >= e.as_of_date
							AND e.eod_balance >= r.tier_min
							AND (r.tier_max IS NULL OR e.eod_balance < r.tier_max)
    WHERE e.as_of_date BETWEEN p_from_date and p_to_date
    AND (p_acct_id  IS NULL  OR e.acct_id = p_acct_id)	
   ) s
   ON (t.acct_id = s.acct_id  AND t.as_of_date = s.as_of_date)
   WHEN MATCHED THEN 
   UPDATE SET t.interest_amt  = (s.eod_balance * s.rate_pa) / s.denom,
              t.rate_pa       = s.rate_pa,
			  t.pricing_model = 'TIERED',
			  t.run_id        = p_run_id,
			  t.calc_basis    = v_basis
    WHEN NOT MATCHED THEN
	INSERT(acct_id, as_of_date, rate_pa, interest_amt, run_id, calc_basis, pricing_model)
	VALUES(s.acct_id,s.as_of_date, s.rate_pa, (s.eod_balance * s.rate_pa)/s.denom, p_run_id, v_basis, 'TIERED');
	
	MERGE INTO casa_interest_accrual t 
	USING (
	WITH slabs AS (
	SELECT e.acct_id, e.as_of_date, e.eod_balance,NVL(r.tier_min,0) as tier_min, NVL(r.tier_max,9e18) as tier_max,
	       r.rate_pa, pkg_interest_util.day_count_denominator(e.as_of_date, v_basis) as denom
	       FROM casa_eod_balance e
           join casa_account a ON a.acct_id = e.acct_id AND a.product_id  = p_product_id
           join casa_rate_tier r on r.product_id = p_product_id AND r.pricing_model = 'SLAB'
	       AND r.effective_from <= e.as_of_date and NVL(r.effective_to, DATE '9999-12-31') >= e.as_of_date
	WHERE e.as_of_date BETWEEN p_from_date and p_to_date
	and (p_acct_id IS NULL OR e.acct_id = p_acct_id)
	),
	slab_calc AS (
	SELECT acct_id, as_of_date, SUM(GREATEST( LEAST(eod_balance, tier_max) - tier_min, 0) * rate_pa / denom)  as daily_interest
	FROM slabs
	WHERE eod_balance > tier_min GROUP BY  acct_id, as_of_date
	)
	SELECT acct_id, as_of_date, daily_interest from slab_calc
	) x 
	ON (t.acct_id = x.acct_id and t.as_of_date = x.as_of_date)
	WHEN MATCHED THEN 
	UPDATE SET t.interest_amt  = x.daily_interest,
	           t.rate_pa       = 0,
			   t.pricing_model = 'SLAB',
			   t.run_id        = p_run_id,
			   t.calc_basis    = v_basis
	WHEN NOT MATCHED THEN
	INSERT (acct_id, as_of_date, rate_pa, interest_amt, run_id, calc_basis, pricing_model)
    VALUES (x.acct_id, x.as_of_date, 0, x.daily_interest, p_run_id, v_basis, 'SLAB');
	
	pkg_interest_util.log_msg(p_run_id, 'INFO',
	  'CASA ACCURAL COMPLETED FOR ' || TO_CHAR(p_from_date,'YYYY-MM-DD')||'..'||TO_CHAR(p_to_date,'YYYY-MM-DD'));
	  
  END accrue_daily;
  
  PROCEDURE post_monthly(
    p_run_id       VARCHAR2,
	p_period_end   DATE,
	p_product_id   NUMBER
  ) IS
   -- v_round NUMBER; 
    v_round NUMBER;
    --:= NVL(TO_NUMBER((SELECT param_value FROM config_param WHERE param_name = "CASA_POSTING_ROUND")),2);
  BEGIN
    SELECT NVL(TO_NUMBER(param_value),2) INTO v_round FROM config_param WHERE param_name = 'CASA_POSTING_ROUND';
    INSERT INTO casa_interest_posting(posting_id, acct_id, period_start, period_end, posted_on, interest_amt, run_id)
    
--    SELECT SEQ_POSTING_ID.NEXTVAL,
--            a.acct_id,
--			TRUNC(p_period_end, 'MM') as period_start,
--			p_period_end,
--            SYSDATE,
--            ROUND(SUM(ia.interest_amt), v_round) as interest_amt,
--            p_run_id
--    FROM casa_account a 
--    join casa_interest_accrual ia ON ia.acct_id = a.acct_id
--	WHERE a.product_id = p_product_id
--	AND ia.as_of_date BETWEEN TRUNC(p_period_end,'MM') and p_period_end
--	GROUP BY a.acct_id, TRUNC(p_period_end, 'MM'), p_period_end, SYSDATE, p_run_id;
--INSERT INTO casa_interest_posting
--(posting_id, acct_id, period_start, period_end, posted_on, interest_amt, run_id)

       SELECT 
         SEQ_POSTING_ID.NEXTVAL,
         x.acct_id,
         x.period_start,
         x.period_end,
         x.posted_on,
         x.interest_amt,
         x.run_id
       FROM (
       SELECT 
         a.acct_id,
         TRUNC(p_period_end, 'MM') AS period_start,
         p_period_end AS period_end,
         SYSDATE AS posted_on,
         ROUND(SUM(ia.interest_amt), v_round) AS interest_amt,
         p_run_id AS run_id
       FROM casa_account a
         JOIN casa_interest_accrual ia 
         ON ia.acct_id = a.acct_id
         WHERE a.product_id = p_product_id
         AND ia.as_of_date BETWEEN TRUNC(p_period_end,'MM') AND p_period_end
       GROUP BY 
        a.acct_id,
        TRUNC(p_period_end,'MM'),
        p_period_end,
        p_run_id
) x;
	
	pkg_interest_util.log_msg(p_run_id, 'INFO',
	    'CASA monthly posting completed for ' || TO_CHAR(p_period_end,'YYYY-MM-DD'));
  END post_monthly;
END pkg_casa;  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  