import pandas as pd
import os 
from pathlib import Path

REQUIRED_COLUMNS = {
    "client_name",
    "client_email",
    "client_address",
    "client_phone",
    "site_location",
    "site_status",
    "job_description",
    "start_date",
    "job_status",
    "worker_name",
    "worker_email",
    "worker_phone",
    "worker_dob",
    "work_date",
    "work_notes",
    "material_name",
    "material_manufacturer",
    "material_unit",
    "material_unit_cost",
    "quantity_used",
    "unit_cost_at_time",
}

ALLOWED_JOB_STATUSES     = {"Completed", "In Progress", "Scheduled"}
ALLOWED_INVOICE_STATUSES  = {"Issued", "Paid", "Overdue"}
ALLOWED_PAYMENT_METHODS   = {"Bank Transfer", "Card", "Cash"}

def validate_bronze(df: pd.DataFrame) -> pd.DataFrame:
    
    # Check 1 - not empty
    if df.empty:
        raise ValueError("DataFrame is empty, nothing to load")
    
    # Check 2 - required columns
    missing_cols = REQUIRED_COLUMNS - set(df.columns)
    if missing_cols:
        raise ValueError(f"Required columns are missing: {missing_cols}")
    
    # Failures list
    failures = []

    # Check 3 - nulls or required columns
    for col in REQUIRED_COLUMNS:
        n = df[col].isna().sum()
        if n > 0:
            failures.append(f" x {n} null values in '{col}' ")

    # Check 4 - quantity and cost > 0
    bad_qty = (df['quantity_used'] <= 0).sum()
    if bad_qty > 0:
        failures.append(f" x {bad_qty} rows with quantity_used <= 0 ")
    
    bad_cost = (df['material_unit_cost'] <= 0).sum()
    if bad_cost > 0:
        failures.append(f" x {bad_cost} rows with material_unit_cost <= 0")
    
    # Check 5 - end date > start date
    if 'end_date' in df.columns:
        has_end_date = df['end_date'].notna()
        invalid_dates = (df.loc[has_end_date, 'end_date'] <= df.loc[has_end_date, 'start_date']).sum()
        if invalid_dates > 0:
            failures.append(f"  x {invalid_dates} rows where end_date is not after start_date")
    
    # Check 6 - job status allowed
    invalid_job_status = (~df['job_status'].isin(ALLOWED_JOB_STATUSES)).sum()
    if invalid_job_status > 0:
        failures.append(f" x {invalid_job_status} rows where job_status invalid")
    
    # Check 7 - invoice status allowed
    if 'invoice_status' in df.columns:
        has_invoice_status = df['invoice_status'].notna()
        invalid_invoice_status = (~df.loc[has_invoice_status, 'invoice_status'].isin(ALLOWED_INVOICE_STATUSES)).sum()
        if invalid_invoice_status > 0:
            failures.append(f" x {invalid_invoice_status} rows where invoice_status invalid")
    
    # Check 8 - payment status allowed
    if 'payment_method' in df.columns:
        has_payment_method = df['payment_method'].notna()
        invalid_payment_method = (~df.loc[has_payment_method, 'payment_method'].isin(ALLOWED_PAYMENT_METHODS)).sum()
        if invalid_payment_method > 0:
            failures.append(f" x {invalid_payment_method} rows where payment_method invalid")

    # Check 9 - total amount positive numbers
    if 'invoice_total_amount' in df.columns:
        has_amount = (df['invoice_total_amount'].notna())
        bad_amount = (df.loc[has_amount, 'invoice_total_amount'] <= 0).sum()
        if bad_amount > 0:
            failures.append(f" x {bad_amount} rows where total invoice amount <= 0")

    if failures:
        raise ValueError("Validation failed: \n" + "\n".join(failures))
    
    print(f"Validation passed ({len(df):,} rows)")
    return df

    
