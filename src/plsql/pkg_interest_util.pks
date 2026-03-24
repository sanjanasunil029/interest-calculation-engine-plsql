CREATE OR REPLACE PACKAGE pkg_interest_util AS
  FUNCTION is_leap_year(p_date DATE)  RETURN BOOLEAN deterministic;
  FUNCTION day_count_denominator(p_date DATE, p_basis VARCHAR2) RETURN NUMBER deterministic;
  PROCEDURE log_msg(p_run_id VARCHAR2, p_level VARCHAR2, p_msg VARCHAR2);
END pkg_interest_util;  