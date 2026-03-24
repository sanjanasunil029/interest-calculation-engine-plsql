CREATE OR REPLACE PROCEDURE compute_casa_eod(
 p_from_date  DATE,
 p_to_date    DATE, 
 p_acct_id    NUMBER DEFAULT NULL
) IS

BEGIN 
  MERGE INTO casa_eod_balance t 
  USING (
    WITH acct_scope AS(
	SELECT DISTINCT a.acct_id FROM
	casa_account a left join txn tx on a.acct_id = tx.acct_id
	WHERE a.open_date <= p_to_date
	AND (p_acct_id IS NULL OR a.acct_id = p_acct_id)
	),
	opening AS(
	SELECT s.acct_id, NVL(SUM(tx.amount),0) opening_bal FROM
    acct_scope s left join txn tx on tx.acct_id = s.acct_id
	and tx.value_date < p_from_date
    group by s.acct_id
	),
	days AS(
	SELECT p_from_date + LEVEL - 1 as dday from dual
	CONNECT BY LEVEL <= (p_to_date - p_from_date + 1)
	),
	daily_sums AS(
	SELECT tx.acct_id, tx.value_date, SUM(tx.amount) amt from txn tx
	WHERE tx.value_date BETWEEN p_from_date AND p_to_date
	AND (p_acct_id IS NULL OR tx.acct_id = p_acct_id)
	GROUP BY tx.acct_id, tx.value_date
	),
	grid as(
	SELECT s.acct_id, d.dday, NVL(ds.amt,0) daily_amt, o.opening_bal
	from acct_scope s cross join days d left join daily_sums ds 
	ON ds.acct_id = s.acct_id AND ds.value_date = d.dday
	join opening o ON o.acct_id = s.acct_id
	),
	eod AS(
	select acct_id, dday as as_of_date, 
	opening_bal + sum(daily_amt) over (partition by acct_id order by dday
	rows between unbounded preceding and current row) as eod_balance
	from grid
	)
	select acct_id,as_of_date, eod_balance from eod
  ) s 
  on (t.acct_id =  s.acct_id and t.as_of_date = s.as_of_date)
  WHEN matched then update set t.eod_balance = s.eod_balance
  WHEN not matched then INSERT (acct_id, as_of_date, eod_balance)
                         values (s.acct_id, s.as_of_date, s.eod_balance);  
END;  

