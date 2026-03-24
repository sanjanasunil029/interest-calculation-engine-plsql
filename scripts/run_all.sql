SET ECHO ON 
SET SERVEROUTPUT ON

PROMPT Creating tables... 
@db/ddl/0l tables.sql

PROMPT Creating indexes....
@db/dd1/02_indexes.sql

PROMPT Creating sequences...
@db/ddl/03_sequences.sql

--PROMPT Creating (optional) partitions (commented).. 
--@db/ddl/04_partitions_optional.sql

PROMPT Seeding products & customers...
@db/dml/01_seed_products_customers.sql 

PROMPT Seeding rates...
@db/dm1/02_seed_rates.sql

PROMPT Seeding sample transactions & TD accounts... 
@db/dm1/03_sample_txns.sql

PROMPT Compiling utility package...
@src/plsql/pkg_interest_util.pks 
@src/plsql/pkg_interest_util.pkb

PROMPT Creating compute_casa_eod procedure...
@src/plsql/compute_casa_eod.sql

PROMPT Compiling CASA package...
@src/plsql/pkg_casa.pks 
@src/plsql/pkg_casa.pkb

PROMPT Compiling TD package... 
@src/plsql/pkg_td.pks 
@src/plsql/pkg_td.pkb

PROMPT Creating recompute procedure... 
@src/procedures/recompute_interest.sql 

PROMPT Setup complete.