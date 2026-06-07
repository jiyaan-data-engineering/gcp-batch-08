# Cricbuzz ODI Ranking Data Batch Processing Pipeline

A production-grade **data engineering pipeline** that automatically extracts cricket player and team rankings from the Cricbuzz API, processes them in Google Cloud Platform, and makes them available for analytics and reporting.

## 🎯 Project Overview

This project demonstrates a complete **Extract-Transform-Load (ETL)** pipeline built on Google Cloud Platform for cricket statistics. It fetches daily rankings for:
- 👥 **Batsmen** (across ODI, Test, T20 formats)
- 🎯 **Bowlers** (across ODI, Test, T20 formats)
- 🤝 **All-rounders** (across ODI, Test, T20 formats)
- 🏆 **Teams** (across ODI, Test, T20 formats)

The data is automatically transformed, validated, and loaded into BigQuery for analytics and visualization.

## 🏗️ Architecture

```
Cricbuzz API
    ↓
Python Extraction Scripts (cricbuzz_api_data.py)
    ↓
Google Cloud Storage (GCS) - Data Lake
    ↓
Google Cloud Dataflow - Transformation
    ↓
BigQuery - Data Warehouse
    ↓
Looker - Analytics & Dashboards
```

### Key Components

| Component | Purpose | Technology |
|-----------|---------|-----------|
| **Data Extraction** | Fetch rankings from Cricbuzz API | Python + requests |
| **Data Storage** | Store raw CSV files | Google Cloud Storage |
| **Data Transformation** | Convert CSV to structured format | Dataflow + JavaScript UDF |
| **Data Warehouse** | Store processed data | BigQuery |
| **Orchestration** | Schedule daily runs | Apache Airflow (Cloud Composer) |
| **Analytics** | Visualize rankings | Looker |

## 📋 Prerequisites

### Required Software
- Python 3.7+
- Google Cloud SDK
- Git

### Required Google Cloud Services
- Google Cloud Storage (GCS)
- Google Cloud Dataflow
- BigQuery
- Cloud Composer (Apache Airflow)
- Cloud Functions (optional)

### Required Credentials
- GCP Service Account with permissions:
  - Storage: `storage.buckets.get`, `storage.objects.*`
  - Dataflow: `dataflow.jobs.create`, `dataflow.jobs.list`
  - BigQuery: `bigquery.datasets.*, bigquery.tables.*`
- Cricbuzz API Key (from RapidAPI)

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/jiyaan-data-engineering/gcp-batch-08.git
cd gcp-batch-08
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Configure Credentials
```bash
# Set up Google Cloud credentials
gcloud auth application-default login

# Or use service account JSON
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

### 4. Update Configuration

Edit `config.json` to specify which data to extract:
```json
[
  { "category": "batsmen", "formatType": "odi" },
  { "category": "bowlers", "formatType": "odi" },
  { "category": "allrounders", "formatType": "odi" },
  { "category": "teams", "formatType": "odi" }
]
```

### 5. Add API Key
Update the API key in `cricbuzz_api_data.py`:
```python
API_KEY = "your_rapidapi_key_here"
```

### 6. Run Extraction
```bash
python cricbuzz_api_data.py
```

This will:
- Fetch rankings for all configured categories and formats
- Create CSV files locally
- Display statistics for each download

### 7. Upload to GCS (Optional)
```bash
python odi_extract_and_push_gcs.py
```

## 📁 Project Structure

```
.
├── README.md                          # This file
├── PROJECT_DOCUMENTATION.md           # Detailed teaching documentation
├── config.json                        # Configuration for data extraction
├── requirements.txt                   # Python dependencies
├── bq.json                           # BigQuery schema definition
├── udf.js                            # JavaScript UDF for transformation
│
├── Data Extraction Scripts:
│   ├── cricbuzz_api_data.py          # Main extraction script (all formats)
│   ├── odi_extract_and_push_gcs.py   # ODI-specific + GCS upload
│   ├── t20_extract_and_push_gcs.py   # T20-specific + GCS upload
│   └── test_extract_and_push_gcs.py  # Test-specific + GCS upload
│
├── Cloud Functions:
│   ├── odi_function.py               # Triggers Dataflow job
│   └── trigger_df_job.py             # Dataflow job launcher
│
├── Orchestration:
│   ├── dag.py                        # Main Airflow DAG (daily scheduling)
│   └── dag_odi_test_t20.py           # Experimental DAG (ODI, Test, T20)
│
├── Testing:
│   ├── test_extract_and_push_gcs.py  # Test script
│   └── test_function.py              # Cloud Function tests
│
├── Configuration:
│   └── bq.json                       # BigQuery table schema
│
├── Documentation:
│   ├── Architecture.png              # Visual architecture diagram
│   └── Looker.png                    # Looker dashboard screenshot
│
└── Data:
    ├── batsmen_rankings.csv          # Sample output
    ├── batsmen_rankings.json         # Sample JSON format
    └── logscript                     # Logging configuration
```

## 📊 Data Flow Explanation

### Step 1: Extraction (Python Scripts)
**What happens**: Python fetches cricket rankings from Cricbuzz API

**Files involved**: `cricbuzz_api_data.py`, `config.json`

```python
# Example extraction
URL: https://cricbuzz-cricket.p.rapidapi.com/stats/v1/rankings/batsmen?formatType=odi
Response: { "rank": [{"rank":"1", "name":"Virat Kohli", "country":"India"}, ...] }
Output: odi_batsmen_rankings.csv
```

### Step 2: Storage in GCS
**What happens**: CSV files uploaded to Google Cloud Storage

**Location**: `gs://bkt-rank-data-odi/`

**Files stored**:
- `odi_batsmen_rankings.csv`
- `odi_bowlers_rankings.csv`
- `odi_allrounders_rankings.csv`
- `odi_teams_rankings.csv`

### Step 3: Transformation with Dataflow
**What happens**: CSV converted to JSON and validated

**JavaScript UDF** (`udf.js`):
```javascript
// Input: 1,Virat Kohli,India
// Process: Parse CSV and create JSON object
// Output: {"rank":"1","name":"Virat Kohli","country":"India"}
```

### Step 4: Loading to BigQuery
**What happens**: Transformed data loaded into BigQuery tables

**BigQuery Table Structure**:
```
Table: odi_batting_ranking
├── rank (STRING)
├── name (STRING)
├── country (STRING)
├── points (STRING)
├── lastUpdatedOn (STRING)
└── id (STRING)
```

### Step 5: Analytics with Looker
**What happens**: Dashboards and reports created on top of BigQuery data

**Example Queries**:
```sql
-- Top 10 batsmen
SELECT rank, name, country, points
FROM `gcp-batch-5-project-1.stats_icc_rankings_dataset.odi_batting_ranking`
WHERE CAST(rank AS INT64) <= 10
ORDER BY CAST(rank AS INT64);

-- Find specific player
SELECT * FROM `gcp-batch-5-project-1.stats_icc_rankings_dataset.odi_batting_ranking`
WHERE name LIKE '%Kohli%';
```

## 🔧 Configuration Guide

### `config.json` - What Data to Extract

Add or remove entries to control data collection:

```json
[
  { "category": "batsmen", "formatType": "odi" },      // ODI batsmen rankings
  { "category": "bowlers", "formatType": "odi" },      // ODI bowlers rankings
  { "category": "allrounders", "formatType": "odi" },  // ODI all-rounders
  { "category": "teams", "formatType": "odi" },        // ODI team rankings
  { "category": "batsmen", "formatType": "test" },     // Test batsmen rankings
  { "category": "batsmen", "formatType": "t20" }       // T20 batsmen rankings
]
```

**Supported Values**:
- **category**: `batsmen`, `bowlers`, `allrounders`, `teams`
- **formatType**: `odi`, `test`, `t20`

### `bq.json` - BigQuery Schema

Define the structure of data in BigQuery:

```json
{
  "BigQuery Schema": [
    { "name": "rank", "type": "STRING" },
    { "name": "name", "type": "STRING" },
    { "name": "country", "type": "STRING" }
  ]
}
```

**To add new fields**:
1. Update API to extract the field (in Python script)
2. Update CSV writer fieldnames (in Python script)
3. Update `bq.json` to include new schema
4. Update `udf.js` to map CSV column to JSON field

### `udf.js` - Data Transformation

JavaScript function that transforms CSV to JSON:

```javascript
function transform(line) {
  var values = line.split(',');
  var obj = new Object();
  obj.rank = values[0];
  obj.name = values[1];
  obj.country = values[2];
  // Add more fields if needed
  // obj.points = values[3];
  // obj.lastUpdatedOn = values[4];
  return JSON.stringify(obj);
}
```

### `dag.py` - Airflow Scheduling

Configure daily execution:

```python
default_args = {
    'owner': 'SATISH MUDDE',
    'start_date': datetime(2023, 12, 18),
    'schedule_interval': '@daily',  # Change to other patterns: @hourly, @weekly, etc.
    'retries': 1,                   # Number of retries on failure
    'retry_delay': timedelta(minutes=5)  # Wait 5 min before retry
}
```

**Schedule Patterns**:
- `@daily` - Once per day (default)
- `@hourly` - Every hour
- `@weekly` - Once per week
- `0 9 * * *` - Custom cron (9 AM daily)

## 📈 Monitoring & Logging

### Check Extraction Progress
```bash
# Run script and view output
python cricbuzz_api_data.py

# Expected output:
# Processing batsmen - odi
# ✅ Created odi_batsmen_rankings.csv | Records: 251
# Processing bowlers - odi
# ✅ Created odi_bowlers_rankings.csv | Records: 248
```

### Check GCS Upload
```bash
# List files in bucket
gsutil ls gs://bkt-rank-data-odi/

# Download file to verify
gsutil cp gs://bkt-rank-data-odi/odi_batsmen_rankings.csv ./
```

### Check Dataflow Jobs
```bash
# List recent jobs
gcloud dataflow jobs list --region=us-east1

# View job details
gcloud dataflow jobs describe JOB_ID --region=us-east1
```

### Check BigQuery Data
```bash
# Query loaded data
bq query --nouse_legacy_sql 'SELECT COUNT(*) FROM `gcp-batch-5-project-1.stats_icc_rankings_dataset.odi_batting_ranking`'

# View table schema
bq show --schema gcp-batch-5-project-1.stats_icc_rankings_dataset.odi_batting_ranking
```

### Monitor Airflow DAG
```
Cloud Composer → Environment → Open Airflow UI → DAGs → fetch_cricket_stats
```

## 🐛 Troubleshooting

### Issue: API Returns 401 (Unauthorized)
**Cause**: Invalid API key
```
Solution: Check API_KEY variable matches your RapidAPI key
```

### Issue: GCS Upload Fails (Permission Denied)
**Cause**: Service account lacks permissions
```
Solution: Grant storage.objects.create permission to service account
gsutil iam ch serviceaccount:SA_EMAIL:roles/storage.objectCreator gs://bucket-name
```

### Issue: BigQuery Load Fails (Schema Mismatch)
**Cause**: CSV field count doesn't match schema
```
Solution: Verify fieldnames in CSV match bq.json schema
```

### Issue: Dataflow Job Hangs
**Cause**: UDF syntax error or infinite loop
```
Solution: Test udf.js separately with sample CSV data
```

### Issue: DAG Never Triggers
**Cause**: Cloud Composer scheduler not running
```
Solution: Check Cloud Composer environment status in GCP Console
```

## 📚 Learning Resources

### Included Documentation
- **PROJECT_DOCUMENTATION.md** - Comprehensive teaching guide with examples
- **Architecture.png** - Visual system architecture
- **Looker.png** - Dashboard screenshots

### External Resources
- [Google Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Cloud Dataflow Documentation](https://cloud.google.com/dataflow/docs)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Apache Airflow Documentation](https://airflow.apache.org/)
- [Cricbuzz API Documentation](https://rapidapi.com/apidojo/api/cricbuzz-cricket)

## 🔐 Security Best Practices

### 🚨 DO NOT commit sensitive data:
```bash
# Never commit API keys or credentials
# Use environment variables or secret managers instead

# Good:
export CRICBUZZ_API_KEY="your_key_here"
api_key = os.environ.get('CRICBUZZ_API_KEY')

# Bad (DO NOT DO THIS):
API_KEY = "expose_key_in_git"  # ❌ Dangerous!
```

### Credential Management:
1. Use GCP Service Accounts (don't use personal accounts)
2. Store API keys in GCP Secret Manager
3. Use IAM roles with least privilege
4. Rotate credentials regularly
5. Monitor audit logs for suspicious activity

## 🚀 Deployment

### Local Development
```bash
python cricbuzz_api_data.py  # Test locally
```

### Cloud Composer (Production)
1. Upload scripts to Cloud Composer environment
2. Create DAG in `/home/airflow/gcs/dags/`
3. Place scripts in `/home/airflow/gcs/dags/scripts/`
4. Airflow automatically detects and schedules DAG

### Cloud Functions (Triggering)
Deploy `odi_function.py` as Cloud Function triggered by GCS events

## 📊 Expected Data Volume

| Component | Volume | Frequency |
|-----------|--------|-----------|
| Records per extract | 200-350 per category | Daily |
| File size | ~20-50 KB per format | Daily |
| BigQuery table rows | 1,000-2,000 per table | Daily accumulation |
| Monthly data volume | ~2-3 MB | Cumulative |

## 🎓 Learning Outcomes

After completing this project, you'll understand:

✅ **Data Engineering**: ETL pipeline design and implementation  
✅ **APIs**: Authentication, error handling, rate limiting  
✅ **Cloud Platforms**: GCP services (Storage, Dataflow, BigQuery)  
✅ **Data Transformation**: CSV to JSON, schema mapping, UDFs  
✅ **Orchestration**: Apache Airflow, scheduling, monitoring  
✅ **SQL**: BigQuery queries, data analysis  
✅ **DevOps**: Deployment, logging, troubleshooting  

## 👨‍💼 About This Project

**Created by**: Satish Mudde  
**Purpose**: Educational + Production  
**Status**: Active  
**Last Updated**: June 2024  

## 📞 Support & Contributions

For questions or improvements:
1. Check [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md) for detailed explanations
2. Review code comments and inline documentation
3. Check GCP logs and monitoring dashboards
4. Contact project maintainer

## 📝 License

This project is provided as-is for educational and commercial use.

## 🎯 Next Steps

1. **Set up locally**: Clone and install dependencies
2. **Test extraction**: Run `python cricbuzz_api_data.py`
3. **Study architecture**: Review PROJECT_DOCUMENTATION.md
4. **Deploy to GCP**: Set up Cloud Composer DAG
5. **Build dashboards**: Create Looker reports
6. **Extend project**: Add women's cricket, historical data, etc.

---

**Happy Data Engineering! 🚀📊**
