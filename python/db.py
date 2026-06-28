from sqlalchemy import create_engine, text
from pathlib import Path
import os
from dotenv import load_dotenv
from urllib.parse import quote_plus

env_path = Path(__file__).resolve().parent.parent / 'config' / '.env'
load_dotenv(env_path)



def get_engine():
    server = os.getenv('AZURE_SQL_SERVER')
    database = os.getenv('AZURE_SQL_DATABASE')
    user = os.getenv('AZURE_SQL_USER')
    password = os.getenv('AZURE_SQL_PASSWORD')
    password_encoded = quote_plus(password)

    engine = create_engine(
        f"mssql+pyodbc://{user}:{password_encoded}@{server}/{database}?driver=ODBC+Driver+18+for+SQL+Server&Encrypt=yes&TrustServerCertificate=no")


    return engine

engine = get_engine()

with engine.connect() as conn:
    result = conn.execute(text("SELECT 1 AS test"))
    print(result.fetchone())