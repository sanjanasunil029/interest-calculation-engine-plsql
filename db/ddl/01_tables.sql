CREATE TABLE cust (
    cust_id NUMBER PRIMARY KEY,
    full_name VARCHAR2(100),
    created_on date default sysdate
);

CREATE TABLE product(
    product_id number primary key,
    product_code varchar2(30) unique not null,
    product_name varchar2(100) not nuLL
);

CREATE TABLE casa_account (
    acct_id NUMBER PRIMARY KEY,
    cust_id NUMBER NOT NULL REFERENCES cust(cust_id),
    product_id NUMBER NOT NULL REFERENCES product(product_id),
    open_date DATE NOT NULL,
    status_code VARCHAR2(10) DEFAULT 'ACTIVE'
);

CREATE TABLE txn (
    txn_id NUMBER PRIMARY KEY,
    acct_id NUMBER NOT NULL REFERENCES casa_account(acct_id),
    posting_date DATE NOT NULL,
    value_date DATE NOT NULL,
    amount NUMBER(18,12) NOT NULL,
    txn_type VARCHAR2(30),
    narrative VARCHAR2(200)
);

CREATE TABLE casa_eod_balance (
    acct_id NUMBER,
    as_of_date DATE,
    eod_balance NUMBER(18,2),
    CONSTRAINT pk_casa_eod PRIMARY KEY(acct_id,as_of_date)
);

CREATE TABLE casa_rate_tier (
    rate_id NUMBER PRIMARY KEY,
    product_id NUMBER NOT NULL REFERENCES product(product_id),
    effective_from DATE NOT NULL,
    effective_to DATE,
    pricing_model VARCHAR2(10) NOT NULL CHECK (pricing_model IN ('TIERED', 'SLAB')),
    tier_min NUMBER(18,2) NOT NULL, -- inclusive
    tier_max NUMBER(18,2), -- exclusive (NULL = infinity)
    rate_pa NUMBER(9,6) NOT NULL -- e.g., 0.035 m 3.5% p.a.
);

CREATE TABLE casa_interest_accrual (
    acct_id  NUMBER NOT NULL, 
	as_of_date DATE NOT NULL, 
	rate_pa NUMBER(9,6) NOT NULL, 
	interest_amt NUMBER(18,6) NOT NULL, -- precision kept high; round at posting 
	run_id VARCHAR2(40) NOT NULL, calc_basis VARCHAR2(20) NOT NULL, -- 'ACT/365' or 'ACT/366" 
	pricing_model VARCHAR2(10) NOT NULL, 
	created_on DATE DEFAULT SYSDATE, CONSTRAINT 
	pk_casa_accrual PRIMARY KEY (acct_id, as_of_date) 
);


CREATE TABLE casa_interest_posting (
    posting_id NUMBER PRIMARY KEY,
	acct_id NUMBER NOT NULL, 
	period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    posted_on DATE NOT NULL,
    interest_amt NUMBER(18,2) NOT NULL,
    run_id VARCHAR2(40) NOT NULL

);
-- 3) TD (Term Deposit)
CREATE TABLE td_account (
    td_id NUMBER PRIMARY KEY,
    cust_id NUMBER NOT NULL REFERENCES cust(cust_id), 
	product_id NUMBER NOT NULL REFERENCES product(product_id),
	principal_amt NUMBER(18,2) NOT NULL,
	open_date DATE NOT NULL,
	maturity_date DATE NOT NULL,
    nominal_rate NUMBER(9,6) NOT NULL, -- annual nominal rate
	comp_freq VARCHAR2(10) NOT NULL CHECK (comp_freq IN ('MONTHLY', 'QUARTERLY' , 'ANNUAL')),
	status_code VARCHAR2(20) DEFAULT 'ACTIVE'
);

CREATE TABLE td_accrual (
    td_id NUMBER NOT NULL, 
	as_of_date DATE NOT NULL, 
	interest_amt NUMBER(18,6) NOT NULL,
	run_id VARCHAR2(40) NOT NULL, 
	calc_basis VARCHAR2(20) NOT NULL,
	CONSTRAINT pk_td_accrual PRIMARY KEY (td_id, as_of_date)
);


CREATE TABLE td_closure(
    closure_id NUMBER PRIMARY KEY, 
	td_id NUMBER NOT NULL REFERENCES td_account(td_id),
	closure_date DATE NOT NULL, 
	closure_type VARCHAR2(20) CHECK (closure_type IN ('PARTIAL','FULL','PRECLOSE')), 
	amount NUMBER(18,2) NOT NULL, 
	penalty_bps NUMBER(9,6), -- e.g., 0.0050 = 50 bps
	note VARCHAR2(200), 
	created_on DATE DEFAULT SYSDATE
);
	
CREATE TABLE run_control( 
    run_id VARCHAR2(40) PRIMARY KEY, 
	process_name VARCHAR2(50) NOT NULL, -- "CASA_ACCRUAL', "TD_ACCRUAL', "RECOMPUTE', "EOM_POSTING 
	from_date DATE, 
	to_date DATE, 
	scope_product VARCHAR2(10), -- 'CASA'/'TD'/NULL 
	scope_acct_id NUMBER, 
	created_on DATE DEFAULT SYSDATE, 
	created_by VARCHAR2(100) 
);

CREATE TABLE run_log ( 
    run_log_id NUMBER PRIMARY KEY, 
	run_id VARCHAR2(49) NOT NULL, 
	run_level VARCHAR2(10) CHECK (run_level IN ('INFO', 'WARN', 'ERROR')), 
	msg VARCHAR2(4000),
	log_time DATE DEFAULT SYSDATE
);

CREATE TABLE config_param ( 
    param_nane VARCHAR2(100) PRIMARY KEY, 
	param_value VARCHAR2(400)
);