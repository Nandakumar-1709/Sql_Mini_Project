/* 
To load Data into created tables in the sql_course Database.

1. Open pgAdmin
2. In Object Explorer (left-hand pane), navigate to `sql_course` database
3. Right-click `sql_course`(Database) and select `PSQL Tool`
    - This opens a terminal window to write the following code
4. Get the absolute file path of the csv files

5. Paste the following into `PSQL Tool`, (with the CORRECT file path)

\copy company_dim FROM 'D:\NANDA ANALYSIS\SQL\Data\csv_files\company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM 'D:\NANDA ANALYSIS\SQL\Data\csv_files\skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM 'D:\NANDA ANALYSIS\SQL\Data\csv_files\job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM 'D:\NANDA ANALYSIS\SQL\Data\csv_files\skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

*/

COPY company_dim
FROM 'D:\NANDA ANALYSIS\SQL\Data\csv_files\company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_dim
FROM 'D:\NANDA ANALYSIS\SQL\Data\csv_files\skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY job_postings_fact
FROM 'D:\NANDA ANALYSIS\SQL\Data\csv_files\job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_job_dim
FROM 'C:\Program Files\PostgreSQL\18\data\Datasets\sql_course\skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
