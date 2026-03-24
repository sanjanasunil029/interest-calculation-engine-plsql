# Interest Calculation Engine (PL/SQL) — CASA & Term Deposit

A portfolio-ready **Interest Calculation Engine** implemented in Oracle PL/SQL covering:

- **CASA (Savings/Current):**
  - Daily accrual on **EOD value-dated balance**
  - **Tiered/slab pricing**
  - **Backdated rate changes**
  - **Leap-year handling**

- **TD (Term Deposit):**
  - Daily accrual
  - Maturity value calculation
  - Configurable **compounding frequency** (monthly/quarterly/annual)
  - Partial closures

- **Controls:**
  - Idempotent recompute by date range
  - Audit logs
  - Tolerance checks
  - EOM posting
  - Error handling

- **Performance:**
  - Set-based SQL
  - MERGE upserts
  - Partition-ready tables
  - Minimal PL/SQL context switching

---

## Compatibility

- Tested on Oracle **21c**
- No external dependencies

---

## Quick Start

### 1. Create schema objects & seed data

Run in SQL*Plus / SQLcl / SQL Developer:

```sql
@scripts/run_all.sql
```

---

### 2. Run sample month (CASA & TD)

```sql
@scripts/run_casa_jan.sql
@scripts/run_td_jan.sql
```

---

### 3. Backdated rate change + recompute

```sql
@scripts/run_recompute_jan.sql
```

---

## Repo Layout

```
interest-engine-plsql/
│
├── README.md
│
├── db/
│   ├── ddl/
│   │   ├── 01_tables.sql
│   │   ├── 02_indexes.sql
│   │   └── 03_sequences.sql
│   │
│   └── dml/
│       ├── 01_seed_products_customers.sql
│       ├── 02_seed_rates.sql
│       └── 03_sample_txns.sql
│
├── src/
│   ├── plsql/
│   │   ├── pkg_interest_util.pks
│   │   ├── pkg_interest_util.pkb
│   │   ├── pkg_casa.pks
│   │   ├── pkg_casa.pkb
│   │   ├── pkg_td.pks
│   │   └── pkg_td.pkb
│   │
│   └── procedures/
│       └── recompute_interest.sql
│
├── scripts/
│   ├── run_all.sql
│   ├── run_casa_jan.sql
│   ├── run_td_jan.sql
│   └── run_recompute_jan.sql
│
└── tests/
    ├── t01_casa_slab_vs_tier.sql
    ├── t02_backdated_rate.sql
    └── t03_leap_year.sql
```

---

## How to Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit: Interest Calculation Engine (CASA & TD)"
git branch -M main
git remote add origin https://github.com/sanjanasunil029/interest-calculation-engine-plsql.git
git push -u origin main
```

---

## Notes

- Uses **set-based SQL**, actual tables are **idempotent** (MERGE on PKs).
- Rounding applied only at posting (configurable).

---

## License

MIT License
