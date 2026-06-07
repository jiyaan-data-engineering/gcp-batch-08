#!/bin/bash

################################################################################
# GCP Project Setup Script
#
# This script automates the creation of a complete GCP project with:
# - Google Cloud Project
# - Cloud Storage Bucket (Data Lake)
# - BigQuery Dataset
# - BigQuery Table with Partitioning & Clustering
#
# Usage: ./setup_gcp_project.sh
# Prerequisites: gcloud CLI installed and authenticated
################################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

################################################################################
# STEP 1: Input Variables
################################################################################

print_info "=== GCP Project Setup ==="
echo ""
echo "Please enter the following information:"
echo ""

# Project Details
read -p "Enter Project Name (e.g., 'Cricbuzz Rankings Pipeline'): " PROJECT_NAME
read -p "Enter Project ID (e.g., 'gcp-batch-5-project-1'): " PROJECT_ID
read -p "Enter GCP Region (e.g., 'us-east1'): " GCP_REGION
read -p "Enter GCP Zone (e.g., 'us-east1-b'): " GCP_ZONE

# Storage Details
read -p "Enter GCS Bucket Name (e.g., 'bkt-rank-data-odi'): " BUCKET_NAME
read -p "Enter GCS Data Location (e.g., 'US'): " BUCKET_LOCATION

# BigQuery Details
read -p "Enter BigQuery Dataset Name (e.g., 'stats_icc_rankings_dataset'): " DATASET_NAME
read -p "Enter BigQuery Table Name (e.g., 'odi_batting_ranking'): " TABLE_NAME

# Partitioning & Clustering
read -p "Enter Partition Column (e.g., 'lastUpdatedOn' or 'NONE' for no partition): " PARTITION_COLUMN
read -p "Enter Clustering Columns (comma-separated, e.g., 'country,rank' or 'NONE'): " CLUSTERING_COLUMNS

echo ""
print_info "You entered the following configuration:"
echo "  Project Name:          $PROJECT_NAME"
echo "  Project ID:            $PROJECT_ID"
echo "  Region:                $GCP_REGION"
echo "  Zone:                  $GCP_ZONE"
echo "  Bucket Name:           $BUCKET_NAME"
echo "  Bucket Location:       $BUCKET_LOCATION"
echo "  Dataset Name:          $DATASET_NAME"
echo "  Table Name:            $TABLE_NAME"
echo "  Partition Column:      $PARTITION_COLUMN"
echo "  Clustering Columns:    $CLUSTERING_COLUMNS"
echo ""

read -p "Is this correct? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    print_error "Setup cancelled"
    exit 1
fi

################################################################################
# STEP 2: Check Prerequisites
################################################################################

print_info "Checking prerequisites..."

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI is not installed!"
    echo "Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

print_success "gcloud CLI is installed"

# Check if user is authenticated
if ! gcloud auth application-default print-access-token > /dev/null 2>&1; then
    print_error "Not authenticated with GCP!"
    echo "Run: gcloud auth application-default login"
    exit 1
fi

print_success "GCP authentication verified"

################################################################################
# STEP 3: Create GCP Project
################################################################################

print_info "Creating GCP Project: $PROJECT_ID"

if gcloud projects create "$PROJECT_ID" \
    --name="$PROJECT_NAME" \
    --organization-id="" \
    2>/dev/null; then
    print_success "Project created: $PROJECT_ID"
else
    if gcloud projects describe "$PROJECT_ID" > /dev/null 2>&1; then
        print_warning "Project $PROJECT_ID already exists, skipping creation"
    else
        print_error "Failed to create project"
        exit 1
    fi
fi

# Set the project as current
print_info "Setting project as active..."
gcloud config set project "$PROJECT_ID"
print_success "Active project: $PROJECT_ID"

################################################################################
# STEP 4: Enable Required APIs
################################################################################

print_info "Enabling required Google Cloud APIs..."

APIS=(
    "storage.googleapis.com"           # Cloud Storage
    "bigquery.googleapis.com"          # BigQuery
    "bigquerydatatransfer.googleapis.com"  # BigQuery Data Transfer
    "dataflow.googleapis.com"          # Dataflow
    "cloudfunctions.googleapis.com"    # Cloud Functions
    "composer.googleapis.com"          # Cloud Composer (Airflow)
)

for api in "${APIS[@]}"; do
    print_info "Enabling $api..."
    gcloud services enable "$api" \
        --project="$PROJECT_ID" \
        2>/dev/null || print_warning "Could not enable $api"
done

print_success "APIs enabled"

################################################################################
# STEP 5: Create Cloud Storage Bucket
################################################################################

print_info "Creating Cloud Storage Bucket: $BUCKET_NAME"

if gsutil ls -p "$PROJECT_ID" "gs://$BUCKET_NAME" > /dev/null 2>&1; then
    print_warning "Bucket $BUCKET_NAME already exists"
else
    gsutil mb \
        -p "$PROJECT_ID" \
        -l "$BUCKET_LOCATION" \
        "gs://$BUCKET_NAME"

    if gsutil ls -p "$PROJECT_ID" "gs://$BUCKET_NAME" > /dev/null 2>&1; then
        print_success "Bucket created: gs://$BUCKET_NAME"
    else
        print_error "Failed to create bucket"
        exit 1
    fi
fi

# Create subdirectories in bucket
print_info "Creating bucket directories..."
echo "" | gsutil cp - "gs://$BUCKET_NAME/data/.keep"
echo "" | gsutil cp - "gs://$BUCKET_NAME/temp/.keep"
echo "" | gsutil cp - "gs://$BUCKET_NAME/staging/.keep"
print_success "Bucket structure created"

################################################################################
# STEP 6: Create BigQuery Dataset
################################################################################

print_info "Creating BigQuery Dataset: $DATASET_NAME"

bq mk \
    --project_id="$PROJECT_ID" \
    --dataset_id="$DATASET_NAME" \
    --location="$GCP_REGION" \
    --description="Cricket Rankings Dataset" \
    2>/dev/null || print_warning "Dataset $DATASET_NAME might already exist"

print_success "Dataset created/verified: $DATASET_NAME"

################################################################################
# STEP 7: Create BigQuery Table
################################################################################

print_info "Creating BigQuery Table: $TABLE_NAME"

# Build the schema
SCHEMA="rank:STRING,name:STRING,country:STRING,points:STRING,lastUpdatedOn:STRING,id:STRING"

# Build the CREATE TABLE query
CREATE_TABLE_SQL="CREATE OR REPLACE TABLE \`$PROJECT_ID.$DATASET_NAME.$TABLE_NAME\` ("
CREATE_TABLE_SQL="$CREATE_TABLE_SQL rank STRING,"
CREATE_TABLE_SQL="$CREATE_TABLE_SQL name STRING,"
CREATE_TABLE_SQL="$CREATE_TABLE_SQL country STRING,"
CREATE_TABLE_SQL="$CREATE_TABLE_SQL points STRING,"
CREATE_TABLE_SQL="$CREATE_TABLE_SQL lastUpdatedOn STRING,"
CREATE_TABLE_SQL="$CREATE_TABLE_SQL id STRING"
CREATE_TABLE_SQL="$CREATE_TABLE_SQL )"

# Add partitioning if specified
if [ "$PARTITION_COLUMN" != "NONE" ] && [ -n "$PARTITION_COLUMN" ]; then
    CREATE_TABLE_SQL="$CREATE_TABLE_SQL PARTITION BY $PARTITION_COLUMN"
    print_info "Adding partition on column: $PARTITION_COLUMN"
fi

# Add clustering if specified
if [ "$CLUSTERING_COLUMNS" != "NONE" ] && [ -n "$CLUSTERING_COLUMNS" ]; then
    CREATE_TABLE_SQL="$CREATE_TABLE_SQL CLUSTER BY $CLUSTERING_COLUMNS"
    print_info "Adding clustering on columns: $CLUSTERING_COLUMNS"
fi

# Create the table
bq query \
    --project_id="$PROJECT_ID" \
    --use_legacy_sql=false \
    "$CREATE_TABLE_SQL" || print_error "Failed to create table"

print_success "Table created: $TABLE_NAME"

################################################################################
# STEP 8: Display Configuration Summary
################################################################################

echo ""
echo "=========================================="
print_success "GCP PROJECT SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "Project Details:"
echo "  Project Name:        $PROJECT_NAME"
echo "  Project ID:          $PROJECT_ID"
echo "  Region:              $GCP_REGION"
echo ""
echo "Cloud Storage:"
echo "  Bucket:              gs://$BUCKET_NAME"
echo "  Location:            $BUCKET_LOCATION"
echo ""
echo "BigQuery:"
echo "  Dataset:             $DATASET_NAME"
echo "  Table:               $TABLE_NAME"
echo "  Full Path:           $PROJECT_ID.$DATASET_NAME.$TABLE_NAME"
if [ "$PARTITION_COLUMN" != "NONE" ] && [ -n "$PARTITION_COLUMN" ]; then
    echo "  Partition:           $PARTITION_COLUMN"
fi
if [ "$CLUSTERING_COLUMNS" != "NONE" ] && [ -n "$CLUSTERING_COLUMNS" ]; then
    echo "  Clustering:          $CLUSTERING_COLUMNS"
fi
echo ""

################################################################################
# STEP 9: Display Useful Commands
################################################################################

echo "Useful Commands:"
echo ""
print_info "View bucket contents:"
echo "  gsutil ls -r gs://$BUCKET_NAME"
echo ""
print_info "Upload file to bucket:"
echo "  gsutil cp ./file.csv gs://$BUCKET_NAME/data/"
echo ""
print_info "View BigQuery table schema:"
echo "  bq show --schema $DATASET_NAME.$TABLE_NAME"
echo ""
print_info "Query data:"
echo "  bq query --nouse_legacy_sql 'SELECT * FROM \`$PROJECT_ID.$DATASET_NAME.$TABLE_NAME\` LIMIT 10'"
echo ""
print_info "Load CSV to BigQuery:"
echo "  bq load --autodetect $DATASET_NAME.$TABLE_NAME gs://$BUCKET_NAME/data/file.csv"
echo ""
print_info "Set active project:"
echo "  gcloud config set project $PROJECT_ID"
echo ""

################################################################################
# STEP 10: Save Configuration to File
################################################################################

CONFIG_FILE="gcp_config.env"

cat > "$CONFIG_FILE" << EOF
# GCP Project Configuration
# Generated by setup_gcp_project.sh

# Project Details
PROJECT_NAME="$PROJECT_NAME"
PROJECT_ID="$PROJECT_ID"
GCP_REGION="$GCP_REGION"
GCP_ZONE="$GCP_ZONE"

# Cloud Storage
BUCKET_NAME="$BUCKET_NAME"
BUCKET_LOCATION="$BUCKET_LOCATION"
GCS_DATA_PATH="gs://$BUCKET_NAME/data"
GCS_TEMP_PATH="gs://$BUCKET_NAME/temp"
GCS_STAGING_PATH="gs://$BUCKET_NAME/staging"

# BigQuery
DATASET_NAME="$DATASET_NAME"
TABLE_NAME="$TABLE_NAME"
BQ_TABLE_ID="$PROJECT_ID.$DATASET_NAME.$TABLE_NAME"
BQ_PARTITION_COLUMN="$PARTITION_COLUMN"
BQ_CLUSTERING_COLUMNS="$CLUSTERING_COLUMNS"

# Dataflow
DATAFLOW_TEMPLATE_PATH="gs://dataflow-templates-$GCP_REGION/latest/GCS_Text_to_BigQuery"
EOF

print_success "Configuration saved to: $CONFIG_FILE"

echo ""
print_success "Setup completed successfully!"
echo ""

################################################################################
# End of Script
################################################################################
