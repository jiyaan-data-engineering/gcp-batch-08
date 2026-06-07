# Cricbuzz ODI Ranking Data Batch Processing - Complete Project Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Technology Stack](#technology-stack)
4. [End-to-End Data Flow](#end-to-end-data-flow)
5. [Key Components](#key-components)
6. [Detailed Implementation Guide](#detailed-implementation-guide)
7. [Configuration Files Explained](#configuration-files-explained)
8. [Learning Objectives](#learning-objectives)

---

## Project Overview

### What is this project?

This is a **production-grade data engineering pipeline** that automatically extracts cricket rankings data from the Cricbuzz API, processes it, and stores it in Google Cloud's data warehouse (BigQuery). The pipeline runs daily and handles multiple cricket formats (ODI, Test, T20) and player categories (Batsmen, Bowlers, All-rounders, Teams).

### Business Problem It Solves

Cricket enthusiasts and analysts need up-to-date rankings for players and teams across different formats. This pipeline automates the daily collection of this data, ensuring that analytics dashboards (like Looker) always have the latest information without manual intervention.

### Key Metrics

- **Data Frequency**: Daily (scheduled at specific times)
- **Data Categories**: Batsmen, Bowlers, All-rounders, Teams
- **Cricket Formats**: ODI (One Day International), Test, T20 (Twenty20)
- **Data Volume**: ~300-500 records per category per format (varies)
- **Storage**: Google Cloud Storage (GCS) + BigQuery

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     CRICBUZZ API (External)                      │
│              https://cricbuzz-cricket.p.rapidapi.com             │
└────────────────────────────┬────────────────────────────────────┘
                             │
                      HTTP API Request
                             │
                ┌────────────▼──────────────┐
                │ Python Extraction Script   │
                │ (cricbuzz_api_data.py)     │
                │ (odi_extract_and_push...)  │
                └────────────┬───────────────┘
                             │
                    CSV Files (Rankings Data)
                             │
        ┌────────────────────▼──────────────────────┐
        │    Google Cloud Storage (GCS) Bucket       │
        │   (gs://bkt-rank-data-odi/)                │
        └────────────────────┬──────────────────────┘
                             │
                      CSV Input Files
                             │
        ┌────────────────────▼──────────────────────┐
        │  Google Cloud Dataflow Pipeline            │
        │  (Transforms & Loads to BigQuery)          │
        │  - JS UDF transforms CSV→JSON              │
        │  - Uses BigQuery Schema (bq.json)          │
        └────────────────────┬──────────────────────┘
                             │
                      Transformed Data
                             │
        ┌────────────────────▼──────────────────────┐
        │  Google BigQuery (Data Warehouse)          │
        │  (gcp-batch-5-project-1.                   │
        │   stats_icc_rankings_dataset)              │
        │  Tables: odi_batting_ranking, etc.         │
        └────────────────────┬──────────────────────┘
                             │
                      Query & Visualize
                             │
        ┌────────────────────▼──────────────────────┐
        │  Looker (BI & Analytics)                   │
        │  (Dashboards for Cricket Rankings)         │
        └─────────────────────────────────────────────┘

ORCHESTRATION LAYER:
┌─────────────────────────────────────────────────────────────────┐
│  Apache Airflow (Cloud Composer)                                │
│  DAG: fetch_cricket_stats                                       │
│  Schedule: Daily (@daily)                                       │
│  Task: Execute Python extraction scripts                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Cloud Platform
- **Google Cloud Platform (GCP)**
  - Cloud Storage (GCS) - Data Lake
  - Dataflow - ETL/Stream processing
  - BigQuery - Data Warehouse
  - Cloud Functions - Serverless compute
  - Cloud Composer - Managed Airflow

### Programming Languages & Frameworks
- **Python 3.x** - Main language for data extraction
- **JavaScript** - Data transformation (UDF in Dataflow)
- **Airflow** - Workflow orchestration
- **SQL** - BigQuery queries

### APIs & Libraries
- **RapidAPI** - Host for Cricbuzz API
- `requests` - HTTP library for API calls
- `csv` - CSV file handling
- `google-cloud-storage` - GCS client
- `google-api-python-client` - Google APIs client
- `functions-framework` - Cloud Functions framework

### Data Formats
- **CSV** - Intermediate format (API → GCS)
- **JSON** - Transformation format (UDF output)

---

## End-to-End Data Flow

### Step-by-Step Process

#### **Step 1: Scheduling & Triggering** ⏰
```
Time: Daily (default times)
Component: Cloud Composer (Apache Airflow)
Action: Triggers the DAG 'fetch_cricket_stats'
```

#### **Step 2: Data Extraction** 📥
```
Component: Python Script (cricbuzz_api_data.py or odi_extract_and_push_gcs.py)
Action:
  1. Read configuration from config.json
  2. For each cricket format (ODI, Test, T20) and category (Batsmen, Bowlers, etc.):
     - Make HTTP request to Cricbuzz API
     - Parse JSON response
     - Extract relevant fields (rank, name, country, points, etc.)
     - Write to CSV file locally
  3. Authenticate with GCS using service account
  4. Upload CSV file to GCS bucket
```

#### **Step 3: Data Storage in GCS** 💾
```
Location: gs://bkt-rank-data-odi/
Files stored:
  - odi_batsmen_rankings.csv
  - odi_bowlers_rankings.csv
  - odi_allrounders_rankings.csv
  - odi_teams_rankings.csv
  (Same for Test and T20 formats)
```

#### **Step 4: Dataflow Transformation** 🔄
```
Component: Google Dataflow
Trigger: Cloud Function (odi_function.py) or manual trigger
Process:
  1. Read CSV files from GCS
  2. Apply JavaScript UDF (udf.js) to transform data:
     - Parse CSV line
     - Extract fields (rank, name, country, etc.)
     - Convert to JSON format
  3. Validate against BigQuery schema (bq.json)
  4. Load transformed data into BigQuery
```

#### **Step 5: Data Storage in BigQuery** 🏢
```
Project: gcp-batch-5-project-1
Dataset: stats_icc_rankings_dataset
Tables:
  - odi_batting_ranking
  - odi_bowling_ranking
  - odi_allrounder_ranking
  - odi_team_ranking
  (Similar tables for Test and T20)

Schema:
  - rank (STRING)
  - name (STRING)
  - country (STRING)
  - [other fields as per API response]
```

#### **Step 6: Analytics & Reporting** 📊
```
Component: Looker (BI Tool)
Output: Dashboards and reports for:
  - Top batsmen by format
  - Top bowlers by format
  - Team rankings
  - Trending players
  - Historical comparisons
```

---

## Key Components

### 1. Configuration File (`config.json`)

**Purpose**: Define which data to extract

```json
[
  { "category": "batsmen", "formatType": "odi" },
  { "category": "bowlers", "formatType": "odi" },
  { "category": "allrounders", "formatType": "odi" },
  { "category": "teams", "formatType": "odi" },
  { "category": "batsmen", "formatType": "test" },
  { "category": "batsmen", "formatType": "t20" }
]
```

**What each field means**:
- `category`: Type of ranking (batsmen, bowlers, allrounders, teams)
- `formatType`: Cricket format (odi, test, t20)

---

### 2. Data Extraction Scripts

#### `cricbuzz_api_data.py` (Generic)
**Purpose**: Main extraction script that iterates through config.json

**Process**:
```python
1. Load config.json
2. For each config entry:
   - Build API URL: https://cricbuzz-cricket.p.rapidapi.com/stats/v1/rankings/{category}
   - Add format parameter: formatType={format}
   - Make HTTP request with API key
   - Parse JSON response
   - Write to CSV file
   - Create filename: {format}_{category}_rankings.csv
3. Handle different response structures (some have "rank", some have "teams")
4. Extract fields: rank, name, country, points, lastUpdatedOn, id
```

**Key Features**:
- Handles multiple API response formats
- Writes header row to CSV
- Creates files even if empty (error handling)
- Prints status messages for monitoring

---

#### `odi_extract_and_push_gcs.py` (Format-Specific)
**Purpose**: ODI-specific extraction with GCS upload

**Differences from generic script**:
- Extracts only ODI format
- Only extracts batsmen category
- Automatically uploads to GCS after extraction
- Uses Google Cloud Storage client

**GCS Upload Process**:
```python
1. Create storage client
2. Connect to bucket: bkt-rank-data-odi
3. Create blob (file reference) in bucket
4. Upload local CSV file
5. Confirm upload with print statement
```

---

#### `t20_extract_and_push_gcs.py` & `test_extract_and_push_gcs.py`
**Purpose**: Similar to ODI script but for T20 and Test formats

---

### 3. Cloud Function (`odi_function.py`)

**Purpose**: Triggered by GCS file upload to launch Dataflow job

**What it does**:
```python
1. Listen to Cloud Audit Log events (when CSV uploaded to GCS)
2. Create Dataflow job with:
   - Template: GCS_Text_to_BigQuery
   - Input: CSV file location in GCS
   - UDF: JavaScript transformation function
   - Schema: BigQuery schema mapping
   - Output: BigQuery table
3. Log job ID and status
```

**Key Parameters**:
- `TEMPLATE_GCS_PATH`: Location of Dataflow template
- `outputTable`: BigQuery destination table
- `inputFilePattern`: GCS source files
- `javascriptTextTransformGcsPath`: UDF location
- `JSONPath`: BigQuery schema location

---

### 4. BigQuery Schema (`bq.json`)

**Purpose**: Define target table structure in BigQuery

```json
{
  "BigQuery Schema": [
    { "name": "rank", "type": "STRING" },
    { "name": "name", "type": "STRING" },
    { "name": "country", "type": "STRING" }
  ]
}
```

**Types Available**:
- STRING - Text data
- INTEGER - Numbers without decimals
- FLOAT - Numbers with decimals
- DATE - Date (YYYY-MM-DD)
- TIMESTAMP - Date and time
- BOOLEAN - True/False

---

### 5. JavaScript UDF (`udf.js`)

**Purpose**: Transform CSV data to JSON format in Dataflow

**How it works**:
```javascript
function transform(line) {
  // Input: "1,Virat Kohli,India"
  var values = line.split(',');          // Split by comma
  var obj = new Object();                // Create JSON object
  obj.rank = values[0];                  // "1"
  obj.name = values[1];                  // "Virat Kohli"
  obj.country = values[2];               // "India"
  var jsonString = JSON.stringify(obj);  // Convert to string
  return jsonString;
  // Output: {"rank":"1","name":"Virat Kohli","country":"India"}
}
```

**Key Concepts**:
- Input: One line of CSV data (string)
- Processing: Parse and restructure
- Output: JSON string that BigQuery can ingest

---

### 6. Airflow DAG (`dag.py`)

**Purpose**: Schedule and orchestrate the daily data pipeline

```python
DAG Details:
- Name: fetch_cricket_stats
- Schedule: @daily (once per day)
- Owner: SATISH MUDDE
- Start Date: December 18, 2023
- Retries: 1 (if failed, retry once)
- Retry Delay: 5 minutes
- Email Notifications: On failure/retry
```

**Task Flow**:
```
Airflow Scheduler
    ↓
Check if schedule met (@daily)
    ↓
Execute BashOperator task
    ↓
Run: python /home/airflow/gcs/dags/scripts/extract_and_push_gcs.py
    ↓
Data extraction and upload completes
    ↓
Task marked as successful/failed
```

---

## Detailed Implementation Guide

### Phase 1: API Call & Data Extraction

**Code Walkthrough** (`cricbuzz_api_data.py`):

```python
# 1. Load configuration
import json
with open("config.json", "r") as file:
    configs = json.load(file)

# 2. Iterate through each config
for item in configs:
    category = item["category"]           # e.g., "batsmen"
    format_type = item["formatType"]      # e.g., "odi"
    
    # 3. Build API request
    url = f"https://cricbuzz-cricket.p.rapidapi.com/stats/v1/rankings/{category}"
    headers = {
        "x-rapidapi-key": "YOUR_API_KEY",
        "x-rapidapi-host": "cricbuzz-cricket.p.rapidapi.com"
    }
    params = {"formatType": format_type}
    
    # 4. Make HTTP request
    response = requests.get(url, headers=headers, params=params)
    
    # 5. Parse response
    if response.status_code == 200:
        json_data = response.json()
        # Different endpoints return different keys
        data = json_data.get("rank") or json_data.get("teams", [])
        
        # 6. Write to CSV
        filename = f"{format_type}_{category}_rankings.csv"
        with open(filename, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(
                f,
                fieldnames=["rank", "name", "country", "points", "lastUpdatedOn", "id"]
            )
            writer.writeheader()
            for entry in data:
                writer.writerow({
                    "rank": entry.get("rank"),
                    "name": entry.get("name"),
                    "country": entry.get("country"),
                    "points": entry.get("points"),
                    "lastUpdatedOn": entry.get("lastUpdatedOn"),
                    "id": entry.get("id")
                })
```

**Key Learning Points**:
- Different API endpoints may have different response structures
- Always validate response status code before processing
- Use proper field mapping to extract only needed data
- Handle missing fields gracefully with `.get()`

---

### Phase 2: GCS Upload

**Code Walkthrough** (`odi_extract_and_push_gcs.py`):

```python
from google.cloud import storage

# 1. Initialize GCS client
storage_client = storage.Client()

# 2. Reference bucket
bucket_name = 'bkt-rank-data-odi'
bucket = storage_client.bucket(bucket_name)

# 3. Create blob (file reference)
csv_filename = 'odi_batsmen_rankings.csv'
destination_blob_name = csv_filename
blob = bucket.blob(destination_blob_name)

# 4. Upload file
blob.upload_from_filename(csv_filename)
print(f"File {csv_filename} uploaded to {bucket_name}")
```

**Key Learning Points**:
- GCS uses bucket (similar to folders) and blob (similar to files)
- Client authenticates using service account credentials
- Upload can be done from local file or in-memory data
- Always verify upload completion

---

### Phase 3: Dataflow Transformation

**How Dataflow Works**:

```
CSV Input (GCS)
    ↓
Read as text (each line)
    ↓
Apply JavaScript UDF
    ↓
Transform to JSON
    ↓
Validate schema
    ↓
Load to BigQuery
```

**UDF Processing**:
```
Input Line: 1,Virat Kohli,India,1000,2024-01-15,12345
    ↓
Parse CSV: ["1", "Virat Kohli", "India", "1000", "2024-01-15", "12345"]
    ↓
Map to fields:
  rank → "1"
  name → "Virat Kohli"
  country → "India"
    ↓
Output JSON: {"rank":"1","name":"Virat Kohli","country":"India"}
```

---

### Phase 4: BigQuery Storage & Querying

**BigQuery Table Structure**:

```sql
-- View table schema
SELECT column_name, data_type
FROM `gcp-batch-5-project-1.stats_icc_rankings_dataset.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'odi_batting_ranking';

-- Query recent rankings
SELECT rank, name, country, points
FROM `gcp-batch-5-project-1.stats_icc_rankings_dataset.odi_batting_ranking`
WHERE CAST(rank AS INT64) <= 10
ORDER BY CAST(rank AS INT64);

-- Find player's ranking
SELECT * FROM `gcp-batch-5-project-1.stats_icc_rankings_dataset.odi_batting_ranking`
WHERE name LIKE '%Kohli%';
```

---

## Configuration Files Explained

### `config.json` - Data Categories & Formats

```json
[
  // ODI Rankings
  { "category": "bowlers", "formatType": "odi" },
  { "category": "batsmen", "formatType": "odi" },
  { "category": "allrounders", "formatType": "odi" },
  { "category": "teams", "formatType": "odi" },
  
  // Test Rankings
  { "category": "bowlers", "formatType": "test" },
  { "category": "batsmen", "formatType": "test" },
  
  // T20 Rankings
  { "category": "bowlers", "formatType": "t20" },
  { "category": "batsmen", "formatType": "t20" }
]
```

**How to extend**:
- Add more format-category combinations
- Supported categories: batsmen, bowlers, allrounders, teams
- Supported formats: odi, test, t20

---

### `bq.json` - BigQuery Schema

```json
{
  "BigQuery Schema": [
    {
      "name": "rank",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "name",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "country",
      "type": "STRING",
      "mode": "NULLABLE"
    }
  ]
}
```

**Schema Elements**:
- `name`: Column name (must match CSV header)
- `type`: Data type (STRING, INTEGER, FLOAT, BOOLEAN, DATE, TIMESTAMP)
- `mode`: NULLABLE (optional) or REQUIRED (mandatory)

---

## Learning Objectives

### By completing this project, you will learn:

#### **1. Data Engineering Fundamentals**
- [ ] ETL (Extract, Transform, Load) pipeline design
- [ ] Data validation and quality checks
- [ ] Error handling and retry logic
- [ ] Data lineage and tracking

#### **2. API Integration**
- [ ] Making HTTP requests with authentication
- [ ] Parsing JSON responses
- [ ] Handling rate limiting and errors
- [ ] API key management

#### **3. Cloud Technologies (GCP)**
- [ ] Cloud Storage (GCS) for data lakes
- [ ] Cloud Dataflow for ETL
- [ ] BigQuery for data warehousing
- [ ] Cloud Composer (Airflow) for orchestration
- [ ] Cloud Functions for serverless processing

#### **4. Data Transformation**
- [ ] CSV to JSON conversion
- [ ] Schema mapping and validation
- [ ] UDF (User Defined Functions) in data pipelines
- [ ] Field extraction and parsing

#### **5. Orchestration & Scheduling**
- [ ] Apache Airflow DAG creation
- [ ] Cron scheduling (@daily)
- [ ] Task dependencies
- [ ] Error notifications

#### **6. Best Practices**
- [ ] Configuration management (config.json)
- [ ] Credential management
- [ ] Logging and monitoring
- [ ] Idempotency (safe to re-run)

---

## Real-World Applications

This pattern is used in companies for:

1. **Sports Analytics**: Tracking player performance, rankings, statistics
2. **Financial Data**: Stock prices, market indices, forex rates
3. **Weather Data**: Temperature, precipitation, forecasts
4. **IoT Data**: Sensor readings, device metrics
5. **Social Media**: Trending topics, engagement metrics
6. **E-commerce**: Product reviews, pricing data

---

## Troubleshooting Guide

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| API returns 401 | Invalid API key | Check API key in code |
| CSV file empty | API returned no data | Check API response, add logging |
| BigQuery load fails | Schema mismatch | Verify field names match bq.json |
| Dataflow job hangs | UDF syntax error | Test UDF separately with sample data |
| DAG not triggering | Scheduler not running | Check Cloud Composer environment status |
| GCS upload fails | Permission denied | Verify service account permissions |

---

## Next Steps for Learning

1. **Set up locally**: Clone repo, install dependencies
2. **Run extraction script**: Execute `python cricbuzz_api_data.py`
3. **Check output**: Verify CSV files created
4. **Study UDF**: Modify `udf.js` to extract more fields
5. **Modify DAG**: Change schedule to test Airflow
6. **Expand scope**: Add women's cricket data (isWomen=1)
7. **Add monitoring**: Implement data quality checks
8. **Create dashboards**: Build Looker reports on BigQuery data

---

## Summary

This project demonstrates a complete, production-ready data pipeline that:
- ✅ Automatically fetches cricket data daily
- ✅ Transforms raw API data into structured format
- ✅ Stores data in scalable cloud warehouse
- ✅ Enables analytics and reporting
- ✅ Handles errors gracefully
- ✅ Maintains data quality

It's an excellent learning resource for understanding modern data engineering on cloud platforms.
