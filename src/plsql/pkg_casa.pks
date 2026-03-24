CREATE OR REPLACE PACKAGE pkg_casa AS
  PROCEDURE accrue_daily(
   p_run_id         VARCHAR2,
   p_from_date      DATE,
   p_to_date        DATE,
   p_product_id     NUMBER,
   p_acct_id        NUMBER  DEFAULT NULL
  );
  PROCEDURE post_monthly(
  p_run_id       VARCHAR2,
  p_period_end   DATE,
  p_product_id   NUMBER
  );
end pkg_casa;  