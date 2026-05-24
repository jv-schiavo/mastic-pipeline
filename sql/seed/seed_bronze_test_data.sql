-- Purpose: Seed bronze.raw_jobs with realistic test data

INSERT INTO bronze.raw_jobs (
    job_date,
    client_name,
    location,
    operative_name,
    material_name,
    manufacturer,
    quantity_used,
    days_worked,
    amount_charged,
    job_status
)
VALUES
('2026-05-01', 'ABC Developments', 'Wembley Site A', 'John Smith', 'White silicone', 'Everbuild', 5, 2, 450.00, 'completed'),
('2026-05-01', 'ABC Developments', 'Wembley Site A', 'Mike Brown', 'Cleaner', 'Soudal', 1, 2, 450.00, 'completed'),
('2026-05-03', 'ABC Developments', 'Wembley Site A', 'John Smith', 'White silicone', 'Everbuild', 3, 1, 280.00, 'completed'),
('2026-05-08', 'London Homes Ltd', 'Barnet Flat 12', 'Carlos Silva', 'Expanding foam', 'Soudal', 2, NULL, 320.00, 'booked'),
('2026-05-06', 'Prime Contractors', 'Camden Block B', 'Mike Brown', 'Grey silicone', 'Dow', 8, 2, 900.00, 'in progress'),
('2026-05-06', 'Prime Contractors', 'Camden Block B', 'Carlos Silva', 'Primer', 'Everbuild', 2, 2, 900.00, 'in progress'),
('2026-05-04', 'Northside Properties', 'Finchley House', 'John Smith', 'Clear silicone', 'Everbuild', 2, 1, 220.00, 'completed'),
('2026-05-05', 'ABC Developments', 'Wembley Site B', 'David Green', 'White silicone', 'Everbuild', 4, 1, 350.00, 'completed'),
('2026-05-09', 'Prime Contractors', 'Camden Block B', NULL, 'Fire-rated sealant', 'Soudal', 10, NULL, 1200.00, 'requested'),
('2026-05-07', 'London Homes Ltd', 'Barnet Flat 15', 'Carlos Silva', 'Clear silicone', 'Everbuild', 3, 1, 300.00, 'completed'),
('2026-05-10', 'Northside Properties', 'Finchley House', 'David Green', 'Grey silicone', 'Dow', 6, NULL, 600.00, 'booked'),
('2026-05-10', 'Northside Properties', 'Finchley House', 'John Smith', 'Primer', 'Everbuild', 1, NULL, 600.00, 'booked'),
('2026-05-02', 'Metro Build Ltd', 'Ealing Apartments', 'Mike Brown', 'Weatherproof silicone', 'Dow', 12, 3, 1500.00, 'completed'),
('2026-05-02', 'Metro Build Ltd', 'Ealing Apartments', 'Mike Brown', 'Cleaner', 'Soudal', 2, 3, 1500.00, 'completed');