# Simple GCP Setup - 5 Minutes ⚡

## What Does This Do?

This script creates a complete GCP setup in **5 minutes** with just **3 pieces of information**:

1. Project Name (any name you like)
2. Project ID (unique ID)
3. Bucket and Dataset names

That's it! ✨

---

## Prerequisites (2 minutes)

### 1. Install Google Cloud SDK

Go to: https://cloud.google.com/sdk/docs/install

- **Windows**: Download and run installer
- **Mac**: `brew install google-cloud-sdk`
- **Linux**: `sudo apt-get install google-cloud-sdk`

### 2. Login to Google Cloud

```bash
gcloud auth application-default login
```

A browser window will open. Click "Allow". Done! ✓

---

## Run the Script

### Step 1: Make it executable
```bash
chmod +x setup_simple.sh
```

### Step 2: Run it
```bash
./setup_simple.sh
```

### Step 3: Answer 6 simple questions

```
STEP 1: Enter Your Project Information
Enter a PROJECT NAME: My Cricket Project
Enter a PROJECT ID: my-cricket-project-123

STEP 2: Enter Storage Information
Enter BUCKET NAME: my-data-bucket
Enter DATASET NAME: cricket_data
Enter TABLE NAME: rankings

Is this correct? (yes/no): yes
```

### Step 4: Watch it create everything! 🎉

```
====================================
Creating GCP Resources...
====================================

1. Creating project 'my-cricket-project-123'...
   ✓ Project created

2. Enabling Google Cloud APIs...
   ✓ APIs enabled

3. Creating Cloud Storage bucket...
   ✓ Bucket created: gs://my-data-bucket

4. Creating BigQuery dataset...
   ✓ Dataset created: cricket_data

5. Creating BigQuery table...
   ✓ Table created: rankings

====================================
SUCCESS! Setup Complete!
====================================
```

---

## What Gets Created?

```
My Cricket Project
└── Project ID: my-cricket-project-123
    │
    ├── Cloud Storage Bucket: gs://my-data-bucket/
    │   └── Folder: data/
    │
    └── BigQuery
        └── Dataset: cricket_data
            └── Table: rankings
                ├── rank
                ├── name
                ├── country
                ├── points
                ├── lastUpdatedOn
                └── id
```

---

## Next Steps (Copy & Paste)

### Upload your CSV file
```bash
gsutil cp your_file.csv gs://my-data-bucket/data/
```

### Load data to BigQuery
```bash
bq load cricket_data.rankings gs://my-data-bucket/data/your_file.csv
```

### Query your data
```bash
bq query 'SELECT * FROM `my-cricket-project-123.cricket_data.rankings` LIMIT 10'
```

---

## Example Values

### Option 1: Cricket Rankings
```
Project Name:  Cricbuzz Rankings
Project ID:    cricbuzz-rankings-2024
Bucket:        cricbuzz-data
Dataset:       icc_rankings
Table:         batsmen_rankings
```

### Option 2: Test Project
```
Project Name:  Learning GCP
Project ID:    learning-gcp-test
Bucket:        test-data
Dataset:       test_db
Table:         test_table
```

### Option 3: Production Setup
```
Project Name:  Cricket Analytics Production
Project ID:    cricket-analytics-prod
Bucket:        prod-cricket-data
Dataset:       prod_analytics
Table:         daily_rankings
```

---

## Troubleshooting

### "gcloud: command not found"
**Solution**: Install Google Cloud SDK (see Prerequisites)

### "You are not logged in"
**Solution**: Run `gcloud auth application-default login`

### "Project already exists"
**Solution**: Use a different Project ID (add a number, like `my-project-123`)

### "Bucket already exists"
**Solution**: Bucket names are unique. Use a different name (add a number or date)

---

## Key Points

✅ **Easy**: Only 6 questions to answer  
✅ **Fast**: Takes about 5 minutes  
✅ **Safe**: Confirms your input before creating  
✅ **Complete**: Creates everything you need  
✅ **Next Steps**: Shows you what to do next  

---

## Common Questions

**Q: What if I make a mistake?**  
A: The script asks you to confirm before creating. If wrong, type "no" and run again.

**Q: Can I use different names?**  
A: Yes! Project ID must be unique globally (use a number). Bucket must be unique too.

**Q: What's the difference between Project ID and Project Name?**  
A: Project Name is just for display (can have spaces). Project ID is technical (use hyphens).

**Q: Do I need to pay?**  
A: First $300 credit is free! After that, costs are low (usually $10-50/month for small projects).

**Q: Can I delete everything?**  
A: Yes! In GCP Console, delete the project and all resources disappear.

---

## File Structure After Setup

```
Your Computer:
└── setup_simple.sh  (this file)

On Google Cloud:
├── Project
│   ├── Cloud Storage
│   │   └── Bucket with data/ folder
│   └── BigQuery
│       ├── Dataset
│       └── Table
```

---

## That's It! 🚀

You now have a complete GCP setup ready to use!

Next step: Upload your CSV file and start analyzing data.

---

## Need Help?

Check the detailed guides:
- `README.md` - Full project guide
- `GCP_SETUP_GUIDE.md` - Detailed GCP setup guide
- `GIT_BEGINNERS_GUIDE.md` - Git tutorial
