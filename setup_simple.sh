#!/bin/bash

################################################################################
# SIMPLE GCP Setup Script
# Easy 3-step setup for beginners
################################################################################

echo "======================================"
echo "GCP Project Setup (Simple Version)"
echo "======================================"
echo ""

# Step 1: Get project information
echo "STEP 1: Enter Your Project Information"
echo "--------------------------------------"
read -p "Enter a PROJECT NAME (e.g., 'My Cricket Project'): " PROJECT_NAME
read -p "Enter a PROJECT ID (e.g., 'my-cricket-project'): " PROJECT_ID

echo ""
echo "You entered:"
echo "  Project Name: $PROJECT_NAME"
echo "  Project ID:   $PROJECT_ID"
echo ""

# Confirm
read -p "Is this correct? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled!"
    exit 1
fi

echo ""
echo "======================================"
echo "STEP 2: Enter Storage Information"
echo "--------------------------------------"
read -p "Enter BUCKET NAME (e.g., 'my-data-bucket'): " BUCKET_NAME
read -p "Enter DATASET NAME (e.g., 'my_dataset'): " DATASET_NAME
read -p "Enter TABLE NAME (e.g., 'my_table'): " TABLE_NAME

echo ""
echo "You entered:"
echo "  Bucket:  $BUCKET_NAME"
echo "  Dataset: $DATASET_NAME"
echo "  Table:   $TABLE_NAME"
echo ""

read -p "Is this correct? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled!"
    exit 1
fi

# Check if gcloud is installed
echo ""
echo "======================================"
echo "STEP 3: Checking Setup"
echo "--------------------------------------"
echo ""

if ! command -v gcloud &> /dev/null; then
    echo "ERROR: gcloud is not installed!"
    echo "Download from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi
echo "✓ gcloud is installed"

# Check if authenticated
if gcloud auth application-default print-access-token > /dev/null 2>&1; then
    echo "✓ You are logged in to GCP"
else
    echo "ERROR: You are not logged in!"
    echo "Run: gcloud auth application-default login"
    exit 1
fi

echo ""
echo "======================================"
echo "Creating GCP Resources..."
echo "======================================"
echo ""

# Create project
echo "1. Creating project '$PROJECT_ID'..."
if gcloud projects create "$PROJECT_ID" --name="$PROJECT_NAME" 2>/dev/null; then
    echo "   ✓ Project created"
else
    if gcloud projects describe "$PROJECT_ID" > /dev/null 2>&1; then
        echo "   ✓ Project already exists"
    else
        echo "   ERROR: Could not create project"
        exit 1
    fi
fi

gcloud config set project "$PROJECT_ID" 2>/dev/null

# Enable APIs
echo ""
echo "2. Enabling Google Cloud APIs..."
gcloud services enable storage.googleapis.com --project="$PROJECT_ID" 2>/dev/null
gcloud services enable bigquery.googleapis.com --project="$PROJECT_ID" 2>/dev/null
gcloud services enable dataflow.googleapis.com --project="$PROJECT_ID" 2>/dev/null
echo "   ✓ APIs enabled"

# Create bucket
echo ""
echo "3. Creating Cloud Storage bucket..."
if gsutil ls -p "$PROJECT_ID" "gs://$BUCKET_NAME" > /dev/null 2>&1; then
    echo "   ✓ Bucket already exists"
else
    gsutil mb -p "$PROJECT_ID" -l "US" "gs://$BUCKET_NAME" 2>/dev/null
    echo "   ✓ Bucket created: gs://$BUCKET_NAME"
fi

# Create directories in bucket
echo "   Creating folders..."
echo "" | gsutil cp - "gs://$BUCKET_NAME/data/.keep" 2>/dev/null
echo "   ✓ Folders created"

# Create dataset
echo ""
echo "4. Creating BigQuery dataset..."
bq mk --project_id="$PROJECT_ID" --dataset_id="$DATASET_NAME" 2>/dev/null || true
echo "   ✓ Dataset created: $DATASET_NAME"

# Create table
echo ""
echo "5. Creating BigQuery table..."

bq query --project_id="$PROJECT_ID" --use_legacy_sql=false << EOF
CREATE OR REPLACE TABLE \`$PROJECT_ID.$DATASET_NAME.$TABLE_NAME\` (
  rank STRING,
  name STRING,
  country STRING,
  points STRING,
  lastUpdatedOn STRING,
  id STRING
);
EOF

echo "   ✓ Table created: $TABLE_NAME"

echo ""
echo "======================================"
echo "SUCCESS! Setup Complete!"
echo "======================================"
echo ""
echo "Your resources:"
echo "  Project ID:    $PROJECT_ID"
echo "  Bucket:        gs://$BUCKET_NAME"
echo "  Dataset:       $DATASET_NAME"
echo "  Table:         $TABLE_NAME"
echo ""
echo "Next steps:"
echo "  1. Upload CSV file:"
echo "     gsutil cp file.csv gs://$BUCKET_NAME/data/"
echo ""
echo "  2. Load data to BigQuery:"
echo "     bq load $DATASET_NAME.$TABLE_NAME gs://$BUCKET_NAME/data/file.csv"
echo ""
echo "  3. Query your data:"
echo "     bq query 'SELECT * FROM \`$PROJECT_ID.$DATASET_NAME.$TABLE_NAME\` LIMIT 10'"
echo ""
