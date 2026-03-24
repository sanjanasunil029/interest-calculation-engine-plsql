DECLARE
v_product_id NUMBER;
begin
 select product_id into v_product_id from product where product_code = 'CASA';
pkg_casa.accrue_daily('RUN_LEAP_FEB2028', DATE '2028-02-01', DATE '2028-02-29',
             v_product_id, NULL);
end;
