-- Products
INSERT INTO product(product_id, product_code, product_name) VALUES (1, 'CASA', 'Savings Account'); 
INSERT INTO product(product_id, product_code, product_name) VALUES (2, 'TD', 'Term Deposit');
-- Config
INSERT INTO config_param(param_name, param_value) VALUES ('CASA_DAY_COUNT', 'ACT/365_366'); 
INSERT INTO config_param(param_name, param_value) VALUES ('TO_DAY_COUNT', 'ACT/365'); 
INSERT INTO config_param(param_name, param_value) VALUES ('TOLERANCE_PAISE','0.01'); 
INSERT INTO config_param(param_name, param_value) VALUES ('CASA_POSTING_ROUND', '2');
-- Customers
INSERT INTO cust(cust_id, full_name) VALUES (1001, 'Sanjana');