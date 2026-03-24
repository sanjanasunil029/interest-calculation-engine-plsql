CREATE  OR REPLACE PACKAGE pkg_td AS
  PROCEDURE accrue_daily(
    p_run_id         VARCHAR2,
	p_from_date    DATE,
	p_to_date      DATE,
	p_td_id        NUMBER DEFAULT NULL
  );

  FUNCTION maturity_value(
    p_td_id NUMBER
  ) RETURN NUMBER;

  PROCEDURE apply_closure(
    p_run_id	   VARCHAR2,
	p_td_id        NUMBER,
	p_closure_dt   DATE,
	p_amount       NUMBER,
	p_type         VARCHAR2,
	p_penalty_bps  NUMBER DEFAULT NULL
  );
END pkg_td;
	