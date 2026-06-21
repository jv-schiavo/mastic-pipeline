import random
from datetime import datetime, timedelta
from pathlib import Path

random.seed(42)

output_path = Path("sql/seed/seed_bronze_raw_jobs.sql")
output_path.parent.mkdir(parents=True, exist_ok=True)

clients = [
    ("Bright Homes Ltd", "accounts@brighthomes.co.uk", "12 Market Street, London", "02071234567"),
    ("Urban Build Contractors", "finance@urbanbuild.co.uk", "88 Station Road, London", "02079876543"),
    ("Northline Developments", "admin@northline.co.uk", "45 High Road, Barnet", "02075551234"),
    ("Prime Estates", "office@prime.co.uk", "5 Oxford Street, London", "02070001111"),
    ("London Living", "contact@living.co.uk", "19 Baker Street, London", "02074445555"),
]

sites = [
    "Wembley Park Apartments",
    "Camden Office Fitout",
    "Barnet Residential Block",
    "Chelsea Apartments",
    "Islington Block",
    "Canary Wharf Tower",
]

workers = [
    ("Carlos Mendes", "carlos@email.com", "07111111111", "1988-04-12"),
    ("Joao Silva", "joao@email.com", "07222222222", "1992-09-21"),
    ("Marcos Oliveira", "marcos@email.com", "07333333333", "1990-02-10"),
    ("Pedro Costa", "pedro@email.com", "07444444444", "1995-07-18"),
    ("Lucas Santos", "lucas@email.com", "07555555555", "1991-11-03"),
]

materials = [
    ("White Silicone", "Soudal", "Tube", 4.50),
    ("Grey Silicone", "Everbuild", "Tube", 5.25),
    ("Sanitary Silicone", "Mapei", "Tube", 5.95),
    ("External Sealant", "Dow", "Tube", 6.75),
    ("Fire Seal", "Hilti", "Tube", 8.90),
]

job_descriptions = [
    "Bathroom silicone replacement",
    "Kitchen sealant replacement",
    "Expansion joint sealing",
    "External window frame sealing",
    "Sink and sanitary sealant application",
    "Balcony joint sealing",
    "Fire stop joint sealing",
    "Lift lobby mastic works",
]

payment_methods = ["Bank Transfer", "Card", "Cash"]

def sql_value(value):
    if value is None:
        return "NULL"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"

rows = []

start_base = datetime(2026, 6, 1, 8, 0)

for i in range(1, 101):
    client = random.choice(clients)
    site_location = random.choice(sites)
    worker = random.choice(workers)
    material = random.choice(materials)

    job_start = start_base + timedelta(days=random.randint(0, 60), hours=random.randint(0, 2))
    job_end = job_start + timedelta(hours=random.randint(4, 9))
    quantity = random.randint(2, 14)
    unit_cost = material[3]
    job_amount = random.choice([240, 320, 380, 450, 600, 690, 760, 820, 910])

    job_status = random.choices(
        ["Completed", "In Progress", "Scheduled"],
        weights=[75, 15, 10]
    )[0]

    if job_status == "Completed":
        invoice_status = random.choice(["Issued", "Paid", "Overdue"])
        invoice_date = job_end + timedelta(days=1)
        invoice_total = job_amount

        if invoice_status == "Paid":
            payment_date = invoice_date + timedelta(days=random.randint(1, 10))
            payment_amount = invoice_total
            payment_method = random.choice(payment_methods)
            payment_reference = f"PAY-{i:03}"
        else:
            payment_date = None
            payment_amount = None
            payment_method = None
            payment_reference = None
    else:
        invoice_status = None
        invoice_date = None
        invoice_total = None
        job_amount = None
        payment_date = None
        payment_amount = None
        payment_method = None
        payment_reference = None

    row = [
        f"APP-{i:03}",
        client[0], client[1], client[2], client[3],
        site_location, "Active",
        random.choice(job_descriptions),
        job_start.strftime("%Y-%m-%d %H:%M:%S"),
        job_end.strftime("%Y-%m-%d %H:%M:%S"),
        job_status,
        worker[0], worker[1], worker[2], worker[3],
        job_start.strftime("%Y-%m-%d"),
        "Work recorded from mobile job form.",
        material[0], material[1], material[2],
        unit_cost, quantity, unit_cost,
        invoice_date.strftime("%Y-%m-%d %H:%M:%S") if invoice_date else None,
        invoice_total,
        invoice_status,
        job_amount,
        payment_date.strftime("%Y-%m-%d %H:%M:%S") if payment_date else None,
        payment_amount,
        payment_method,
        payment_reference,
    ]

    rows.append("(" + ", ".join(sql_value(v) for v in row) + ")")

sql = """TRUNCATE TABLE bronze.raw_jobs;

INSERT INTO bronze.raw_jobs (
    source_record_id,
    client_name, client_email, client_address, client_phone,
    site_location, site_status,
    job_description, start_date, end_date, job_status,
    worker_name, worker_email, worker_phone, worker_dob,
    work_date, work_notes,
    material_name, material_manufacturer, material_unit,
    material_unit_cost, quantity_used, unit_cost_at_time,
    invoice_date, invoice_total_amount, invoice_status,
    invoice_job_amount,
    payment_date, payment_amount, payment_method, payment_reference
)
VALUES
""" + ",\n".join(rows) + ";\n"

output_path.write_text(sql, encoding="utf-8")

print(f"Generated {len(rows)} rows at {output_path}")