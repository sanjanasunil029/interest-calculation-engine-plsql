CREATE OR REPLACE PACKAGE BODY pkg_interest_util AS

 FUNCTION is_leap_year(p_date DATE) return BOOLEAN DETERMINISTIC IS
  y PLS_INTEGER := TO_NUMBER(to_char(p_date,'yyyy'));
 BEGIN
  RETURN MOD(y,400) = 0 OR (MOD(y,4) = 0 AND MOD(y,400)<>0);  
 END;

 FUNCTION  day_count_denominator(p_date DATE, p_basis VARCHAR2) RETURN NUMBER DETERMINISTIC IS
  BEGIN
   IF p_basis = 'ACT/365_366' THEN
      RETURN CASE WHEN is_leap_year(p_date) THEN 366 ELSE 365  END;
   ELSIF p_basis = 'ACT/365' THEN
      RETURN 365;
   ELSE 
      RETURN 365;
   END IF;
 END;

 PROCEDURE log_msg(p_run_id VARCHAR2, p_level VARCHAR2, p_msg VARCHAR2) IS 
  BEGIN
   INSERT INTO run_log(run_log_id, run_id, run_level, msg, log_time)
   VALUES (seq_run_log.NEXTVAL, p_run_id, p_level, p_msg, SYSDATE);
  END;
END pkg_interest_util;  