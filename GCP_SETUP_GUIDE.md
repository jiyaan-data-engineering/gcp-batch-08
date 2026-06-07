# GCP Project Setup Guide - Shell Script

## Overview

The `setup_gcp_project.sh` script automates the entire process of setting up a Google Cloud Platform project with:
- ✅ GCP Project creation
- ✅ Cloud Storage bucket
- ✅ BigQuery dataset
- ✅ BigQuery table with partitioning and clustering

This guide explains how to use it.

---

## Prerequisites

### 1. Install Google Cloud SDK

#### Windows (PowerShell)
```powershell
# Download from:
# https://cloud.google.com/sdk/docs/install-sdk#windows

# Or use Chocolatey:
choco install google-cloud-sdk
```

#### Mac (Homebrew)
```bash
brew install google-cloud-sdk
```

#### Linux
```bash
# Ubuntu/Debian
sudo apt-get install google-cloud-sdk

# Or use official instructions:
# https://cloud.google.com/sdk/docs/install-sdk#linux
```

### 2. Authenticate with GCP

```bash
# Method 1: Interactive login
gcloud auth application-default login

# Method 2: Using service account JSON
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

### 3. Verify Installation

```bash
gcloud --version
gcloud auth list
gcloud config list
```

---

## Script Overview

### What the Script Does

```
1. INPUT
   └─ Asks for project name, project ID, bucket name, dataset, table, etc.

2. VALIDATION
   └─ Checks if gcloud is installed and authenticated

3. CREATE PROJECT
   └─ Creates new GCP project with specified ID

4. ENABLE APIs
   └─ Enables required APIs (Storage, BigQuery, Dataflow, etc.)

5. CREATE BUCKET
   └─ Creates Cloud Storage bucket
   └─ Creates directory structure (data/, temp/, staging/)

6. CREATE DATASET
   └─ Creates BigQuery dataset

7. CREATE TABLE
   └─ Creates BigQuery table with:
      ├─ Schema (rank, name, country, points, etc.)
      ├─ Partitioning (if specified)
      └─ Clustering (if specified)

8. SAVE CONFIG
   └─ Saves all settings to gcp_config.env file
```

---

## How to Run the Script

### Step 1: Make Script Executable

#### On Mac/Linux
```bash
chmod +x setup_gcp_project.sh
```

#### On Windows (PowerShell)
```powershell
# No special permissions needed, just run with bash:
bash setup_gcp_project.sh
```

### Step 2: Run the Script

```bash
./setup_gcp_project.sh
```

Or with bash explicitly:
```bash
bash setup_gcp_project.sh
```

### Step 3: Follow the Prompts

The script will ask you to enter:

```
Please enter the following information:

Enter Project Name (e.g., 'Cricbuzz Rankings Pipeline'): Cricbuzz ODI Rankings
Enter Project ID (e.g., 'gcp-batch-5-project-1'): cricbuzz-odi-batch-08
Enter GCP Region (e.g., 'us-east1'): us-east1
Enter GCP Zone (e.g., 'us-east1-b'): us-east1-b
Enter GCS Bucket Name (e.g., 'bkt-rank-data-odi'): bkt-cricbuzz-odi-data
Enter GCS Data Location (e.g., 'US'): US
Enter BigQuery Dataset Name (e.g., 'stats_icc_rankings_dataset'): cricket_rankings_dataset
Enter BigQuery Table Name (e.g., 'odi_batting_ranking'): odi_batsmen_rankings
Enter Partition Column (e.g., 'lastUpdatedOn' or 'NONE' for no partition): lastUpdatedOn
Enter Clustering Columns (comma-separated, e.g., 'country,rank' or 'NONE'): country,rank

Is this correct? (yes/no): yes
```

### Step 4: Review Results

The script will display:

```
[SUCCESS] GCP PROJECT SETUP COMPLETE!

Project Details:
  Project Name:        Cricbuzz ODI Rankings
  Project ID:          cricbuzz-odi-batch-08
  Region:              us-east1

Cloud Storage:
  Bucket:              gs://bkt-cricbuzz-odi-data
  Location:            US

BigQuery:
  Dataset:             cricket_rankings_dataset
  Table:               odi_batsmen_rankings
  Full Path:           cricbuzz-odi-batch-08.cricket_rankings_dataset.odi_batsmen_rankings
  Partition:           lastUpdatedOn
  Clustering:          country,rank

[INFO] Useful Commands:
  gsutil ls -r gs://bkt-cricbuzz-odi-data
  ...
```

---

## Example Usage Scenarios

### Scenario 1: Simple Setup (No Partitioning/Clustering)

```bash
bash setup_gcp_project.sh

# When prompted:
Project Name: My Cricket Project
Project ID: my-cricket-project
Region: us-west1
Zone: us-west1-a
Bucket Name: my-cricket-data
Location: US
Dataset Name: cricket_data
Table Name: players
Partition: NONE
Clustering: NONE
```

**Result**: Simple table without optimization

### Scenario 2: Optimized Setup (With Partitioning & Clustering)

```bash
bash setup_gcp_project.sh

# When prompted:
Project Name: Cricbuzz Analytics
Project ID: cricbuzz-analytics-prod
Region: us-east1
Zone: us-east1-b
Bucket Name: cricbuzz-prod-data
Location: US
Dataset Name: icc_rankings
Table Name: all_rankings
Partition: lastUpdatedOn
Clustering: country,rank,format
```

**Result**: Optimized table that:
- Partitions by date (faster queries on date ranges)
- Clusters by country, rank, format (faster filtering)
- Better query performance
- Lower query costs

### Scenario 3: Multi-Format Setup

```bash
# Run script multiple times for different formats

# First run (ODI)
bash setup_gcp_project.sh
# Project ID: cricbuzz-odi-batch
# Table Name: odi_rankings

# Second run (Test)
bash setup_gcp_project.sh
# Project ID: cricbuzz-test-batch
# Table Name: test_rankings

# Third run (T20)
bash setup_gcp_project.sh
# Project ID: cricbuzz-t20-batch
# Table Name: t20_rankings
```

---

## Understanding Input Parameters

### Project Details

| Parameter | Example | Explanation |
|-----------|---------|-------------|
| Project Name | "Cricbuzz Rankings Pipeline" | Human-readable project name |
| Project ID | "gcp-batch-5-project-1" | Unique ID (must be globally unique) |
| Region | "us-east1" | GCP region (affects pricing) |
| Zone | "us-east1-b" | Specific availability zone |

**Region Options**:
- `us-east1` - South Carolina (cheapest in US)
- `us-west1` - Oregon
- `us-central1` - Iowa
- `europe-west1` - Belgium
- `asia-east1` - Taiwan

### Storage Details

| Parameter | Example | Explanation |
|-----------|---------|-------------|
| Bucket Name | "bkt-rank-data-odi" | GCS bucket name (must be globally unique) |
| Location | "US", "EU", "ASIA" | Data storage location |

### BigQuery Details

| Parameter | Example | Explanation |
|-----------|---------|-------------|
| Dataset Name | "stats_icc_rankings_dataset" | Container for tables |
| Table Name | "odi_batting_ranking" | Actual data table |

### Partitioning & Clustering

#### Partitioning

**What it does**: Divides table into smaller chunks based on a column

**When to use**: When you query by date/time ranges

```sql
-- Without partition: scans entire table (slow)
SELECT * FROM table WHERE date BETWEEN '2024-01-01' AND '2024-01-31'

-- With partition: scans only January data (fast)
SELECT * FROM table WHERE lastUpdatedOn BETWEEN '2024-01-01' AND '2024-01-31'
```

**Common Partition Columns**:
- `lastUpdatedOn` - Most common for rankings
- `created_date` - For time-series data
- `year`, `month`, `day` - For granular partitioning

**Ingestion Time Partitioning**: `_PARTITIONTIME` (automatic)

#### Clustering

**What it does**: Physically sorts data by specified columns

**When to use**: When you filter by multiple columns

```sql
-- Clustering on country,rank makes this fast:
SELECT * FROM table WHERE country = 'India' AND rank <= 10
```

**Common Clustering Columns**:
- `country` - For geographic filtering
- `rank` - For top N queries
- `format` - For format-specific queries
- `category` - For player/team filtering

**Benefits**:
- ✅ Faster queries
- ✅ Lower cost (scan less data)
- ✅ Better compression

---

## Configuration File (gcp_config.env)

The script automatically creates `gcp_config.env` with all your settings:

```bash
# GCP Project Configuration
# Generated by setup_gcp_project.sh

PROJECT_NAME="Cricbuzz ODI Rankings"
PROJECT_ID="cricbuzz-odi-batch-08"
GCP_REGION="us-east1"
GCP_ZONE="us-east1-b"

BUCKET_NAME="bkt-cricbuzz-odi-data"
BUCKET_LOCATION="US"
GCS_DATA_PATH="gs://bkt-cricbuzz-odi-data/data"
GCS_TEMP_PATH="gs://bkt-cricbuzz-odi-data/temp"
GCS_STAGING_PATH="gs://bkt-cricbuzz-odi-data/staging"

DATASET_NAME="cricket_rankings_dataset"
TABLE_NAME="odi_batsmen_rankings"
BQ_TABLE_ID="cricbuzz-odi-batch-08.cricket_rankings_dataset.odi_batsmen_rankings"
BQ_PARTITION_COLUMN="lastUpdatedOn"
BQ_CLUSTERING_COLUMNS="country,rank"

DATAFLOW_TEMPLATE_PATH="gs://dataflow-templates-us-east1/latest/GCS_Text_to_BigQuery"
```

### How to Use Config File

Load it in your scripts:

```bash
# In another script
source gcp_config.env

# Now you can use variables:
echo "Uploading to: $GCS_DATA_PATH"
bq query --dataset_id=$DATASET_NAME

# In Python
import os
os.environ['PROJECT_ID'] = "..."

# In Docker
docker run -e PROJECT_ID=$PROJECT_ID ...
```

---

## Useful Commands After Setup

### Cloud Storage Commands

```bash
# List bucket contents
gsutil ls -r gs://bkt-cricbuzz-odi-data/

# Upload file
gsutil cp ./odi_batsmen_rankings.csv gs://bkt-cricbuzz-odi-data/data/

# Download file
gsutil cp gs://bkt-cricbuzz-odi-data/data/file.csv ./

# Set public access
gsutil acl ch -u AllUsers:R gs://bkt-cricbuzz-odi-data/file.csv

# Check bucket size
gsutil du -s gs://bkt-cricbuzz-odi-data/
```

### BigQuery Commands

```bash
# View table schema
bq show --schema cricket_rankings_dataset.odi_batsmen_rankings

# View table details
bq show cricket_rankings_dataset.odi_batsmen_rankings

# Query data
bq query --nouse_legacy_sql 'SELECT * FROM `cricbuzz-odi-batch-08.cricket_rankings_dataset.odi_batsmen_rankings` LIMIT 10'

# Load CSV to table
bq load --autodetect cricket_rankings_dataset.odi_batsmen_rankings gs://bkt-cricbuzz-odi-data/data/file.csv

# Export table to CSV
bq extract cricket_rankings_dataset.odi_batsmen_rankings gs://bkt-cricbuzz-odi-data/export/data.csv

# Check table size
bq show --format=prettyjson cricket_rankings_dataset.odi_batsmen_rankings | grep 'numBytes'
```

### GCP Project Commands

```bash
# Set active project
gcloud config set project cricbuzz-odi-batch-08

# List all projects
gcloud projects list

# View project details
gcloud projects describe cricbuzz-odi-batch-08

# Enable additional APIs
gcloud services enable cloudfunctions.googleapis.com --project=cricbuzz-odi-batch-08

# List enabled APIs
gcloud services list --project=cricbuzz-odi-batch-08
```

---

## Troubleshooting

### Error: "gcloud: command not found"

**Solution**: Install Google Cloud SDK
```bash
# See Prerequisites section
```

### Error: "Permission denied"

**Solution**: Authenticate with GCP
```bash
gcloud auth application-default login
```

### Error: "Project creation failed"

**Possible causes**:
- Project ID already exists (must be globally unique)
- No billing account enabled
- Insufficient permissions

**Solution**:
```bash
# Check if project exists
gcloud projects list

# Create with different ID
# Re-run script with unique project ID
```

### Error: "Bucket already exists"

**Solution**: Use unique bucket name (must be globally unique)
```bash
# Try adding timestamp
bkt-cricbuzz-odi-data-20240607
```

### Error: "Quota exceeded"

**Solution**: Check GCP quotas and limits
```bash
# View quotas
gcloud compute project-info describe --project=YOUR_PROJECT

# Request quota increase in GCP Console
```

---

## Integration with Your Project

### Using with extract_and_push_gcs.py

```python
# Load configuration from env file
import os
from dotenv import load_dotenv

load_dotenv('gcp_config.env')

PROJECT_ID = os.getenv('PROJECT_ID')
BUCKET_NAME = os.getenv('BUCKET_NAME')
DATASET_NAME = os.getenv('DATASET_NAME')
TABLE_NAME = os.getenv('TABLE_NAME')

# Use in your script
bucket = storage_client.bucket(BUCKET_NAME)
blob = bucket.blob(f"{GCS_DATA_PATH}/odi_batsmen_rankings.csv")
```

### Using with Airflow DAG

```python
# In your DAG
from dotenv import load_dotenv
import os

load_dotenv('gcp_config.env')

GCP_REGION = os.getenv('GCP_REGION')
GCS_DATA_PATH = os.getenv('GCS_DATA_PATH')
DATASET_NAME = os.getenv('DATASET_NAME')
TABLE_NAME = os.getenv('TABLE_NAME')

default_args = {
    'project_id': os.getenv('PROJECT_ID'),
    'gcp_region': GCP_REGION,
}
```

### Using with Dataflow Job

```python
DF_PARAMS = {
    "inputFilePattern": f"{os.getenv('GCS_DATA_PATH')}/odi_batsmen_rankings.csv",
    "outputTable": f"{os.getenv('PROJECT_ID')}.{os.getenv('DATASET_NAME')}.{os.getenv('TABLE_NAME')}",
    "bigQueryLoadingTemporaryDirectory": f"{os.getenv('GCS_TEMP_PATH')}/",
}
```

---

## Costs Estimation

### Pricing (as of June 2024)

| Service | Cost | Notes |
|---------|------|-------|
| Cloud Storage | $0.020/GB/month | First 1GB free |
| BigQuery Storage | $0.06/GB/month | First 10GB free |
| BigQuery Queries | $6.25/TB scanned | First 1TB free |
| Dataflow | Variable | Per vCPU-hour |

### Example Monthly Cost

For the Cricbuzz project:
- **Storage**: 1GB data = $0.02
- **BigQuery**: 10 GB stored = $0.60
- **Queries**: 50 queries × 1GB = $312.50
- **Total**: ~$313/month

**Cost optimization**:
- ✅ Use partitioning (reduce data scanned)
- ✅ Use clustering (faster, cheaper queries)
- ✅ Archive old data
- ✅ Schedule queries in off-peak hours

---

## Next Steps

1. ✅ Run the setup script
2. ✅ Verify resources created in GCP Console
3. ✅ Load sample data to BigQuery
4. ✅ Test queries
5. ✅ Set up data pipeline
6. ✅ Create Looker dashboards
7. ✅ Monitor costs

---

## Script Parameters Summary

| Flag/Option | Default | Example | Notes |
|------------|---------|---------|-------|
| Project Name | - | "Cricbuzz Rankings" | Display name |
| Project ID | - | "cricbuzz-odi-batch" | Must be unique |
| Region | - | "us-east1" | Affects pricing |
| Zone | - | "us-east1-b" | For compute resources |
| Bucket | - | "bkt-cricbuzz-data" | Must be unique |
| Location | - | "US" or "EU" | Data location |
| Dataset | - | "cricket_rankings" | BQ container |
| Table | - | "odi_rankings" | BQ table |
| Partition | Optional | "lastUpdatedOn" | Or "NONE" |
| Clustering | Optional | "country,rank" | Or "NONE" |

---

## Support

If you encounter issues:

1. Check error messages in script output
2. Verify gcloud authentication
3. Check GCP Console for resource creation
4. Review script logs
5. Ensure billing is enabled

---

Happy GCP setup! 🚀
