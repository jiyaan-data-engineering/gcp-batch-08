# Git for Beginners - Complete Guide with Project Examples

## Table of Contents
1. [What is Git?](#what-is-git)
2. [Why Do We Use Git?](#why-do-we-use-git)
3. [Basic Concepts](#basic-concepts)
4. [Installation & Setup](#installation--setup)
5. [Basic Git Commands](#basic-git-commands)
6. [Real Project Examples](#real-project-examples)
7. [Common Workflows](#common-workflows)
8. [Troubleshooting](#troubleshooting)

---

## What is Git?

### Simple Definition
**Git** is a tool that tracks changes to your code files over time. Think of it like:
- 📝 A notebook that records every change you make
- 📸 A camera that takes snapshots of your project
- 🔄 A system that lets multiple people work on the same project safely

### Real-Life Analogy
Imagine you're writing a book:
- **Without Git**: You save `book.txt`, then `book_v2.txt`, then `book_final.txt`, then `book_FINAL_REALLY.txt` 😫
- **With Git**: You have ONE `book.txt` and Git records every change, so you can see what changed and go back if needed ✅

---

## Why Do We Use Git?

### Problem It Solves

| Problem | Solution with Git |
|---------|------------------|
| Lost previous versions | Git keeps complete history |
| Unsure what changed | Git shows exact changes (diffs) |
| Multiple people editing same file | Git merges changes safely |
| Need to undo a change | Git lets you revert to any version |
| Want to experiment safely | Git branches let you try things without affecting main code |
| No backup | Git is backed up on remote server (GitHub) |

### Our Project Example
In your Cricbuzz project:
- **June 7**: Initial commit with 25 files
- **June 7**: Add comprehensive documentation (2 new files)
- **June 7**: Fix emoji characters in Python script
- **June 7**: Remove duplicate files

Git keeps ALL these versions and shows exactly what changed at each step! 📊

---

## Basic Concepts

### 1. **Repository (Repo)**
A folder that Git tracks. It contains:
- Your project files
- A `.git` folder (hidden) that stores all the version history
- Configuration files

### 2. **Local vs Remote**

```
Your Computer (LOCAL)           GitHub.com (REMOTE)
┌──────────────────┐            ┌──────────────────┐
│   Your Project   │            │   GitHub Cloud   │
│   .git folder    │ ←→ push/pull │   Backup Copy    │
└──────────────────┘            └──────────────────┘
```

- **Local**: Repository on your computer
- **Remote**: Repository on GitHub (or other servers)

### 3. **Commit**
A "snapshot" of your code at a specific point in time with:
- Changes you made
- A message explaining what you did
- A unique ID (hash)
- Timestamp and author name

### 4. **Branch**
A separate line of development. Default branch is `master` (or `main`).

```
master branch:  o──o──o──o (main development)
                   │
feature branch:    └──o──o (experimental work)
```

### 5. **Staging Area**
A temporary holding area where you prepare files before committing.

```
Modified Files → Staging Area → Commit → History
(git add)       (git commit)
```

---

## Installation & Setup

### Step 1: Install Git

#### Windows
1. Go to https://git-scm.com/download/win
2. Download and run the installer
3. Use default settings (click Next)

#### Mac
```bash
brew install git
```

#### Linux
```bash
sudo apt-get install git
```

### Step 2: Configure Git (First Time Only)

Tell Git who you are:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@gmail.com"
```

**In our project, we used**:
```bash
git config user.name "jiyaan-data-engineering"
git config user.email "jiyaan.institute@gmail.com"
```

### Step 3: Verify Installation

```bash
git --version
# Output: git version 2.45.0 (or similar)

git config --list
# Shows your name and email
```

---

## Basic Git Commands

### 1. **Initialize a Repository**

```bash
git init
```

**What it does**: Creates a new `.git` folder in your project directory

**In our project**: We ran this to start tracking the Cricbuzz project
```bash
git init
# Output: Initialized empty Git repository in C:/satishMudde/claude/cricbuzz-odi-ranking-data-batch-08/.git/
```

---

### 2. **Check Status**

```bash
git status
```

**What it does**: Shows which files changed, which are staged, which are untracked

**Example output from our project**:
```
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update)
  deleted:    extract_and_push_gcs copy.py
  
Untracked files:
  (use "git add <file>..." to include in what will be committed)
  PROJECT_DOCUMENTATION.md

no changes added to commit
```

**What it means**:
- `master` = current branch
- `deleted` = you deleted this file
- `Untracked` = new file Git doesn't know about yet

---

### 3. **Add Files to Staging Area**

```bash
# Add specific file
git add filename.py

# Add all changes
git add -A

# Add all Python files
git add *.py
```

**What it does**: Prepares files for commit (like putting items in a box before shipping)

**In our project**:
```bash
git add cricbuzz_api_data.py config.json
# Now these files are ready to commit
```

**Visual process**:
```
Modified file → git add → Staging Area → git commit → Committed History
```

---

### 4. **Commit Changes**

```bash
git commit -m "Your commit message"
```

**What it does**: Creates a snapshot with a description

**In our project**:
```bash
git commit -m "fix: Remove emoji characters for Windows compatibility"
```

**Good commit messages**:
- ✅ `"Add data extraction script"`
- ✅ `"Fix: Unicode encoding error"`
- ✅ `"Update BigQuery schema"`
- ❌ `"fix stuff"`
- ❌ `"changes"`
- ❌ `"asdfgh"`

**Commit message format** (conventional):
```
<type>: <subject>

<body (optional)>

<footer (optional)>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

### 5. **View Commit History**

```bash
git log
```

**What it does**: Shows all commits with details

**Example output**:
```
commit 02bffcd (HEAD -> master)
Author: Claude Haiku 4.5
Date: Sat Jun 7 20:44:00 2026

    fix: Remove emoji characters for Windows compatibility
    
    - Replace emoji with ASCII text equivalents
    - Simplify config for testing

commit 5b927c9
Author: Claude Haiku 4.5
Date: Sat Jun 7 20:35:00 2026

    docs: Add comprehensive project documentation
    
    - Create PROJECT_DOCUMENTATION.md
    - Update README.md
```

**To see compact version**:
```bash
git log --oneline
```

**Output**:
```
02bffcd fix: Remove emoji characters for Windows compatibility
5b927c9 docs: Add comprehensive project documentation
3943244 Initial commit: Cricbuzz ODI ranking data batch processing
```

---

### 6. **See What Changed**

```bash
# See changes not yet staged
git diff

# See changes in a specific file
git diff filename.py

# See changes in staged files
git diff --staged
```

**Example**:
```bash
git diff cricbuzz_api_data.py
```

**Output** (shows additions and deletions):
```diff
 # Handle different response structures
-# 🔥 Handle different response structures
+# Handle different response structures
```

---

### 7. **Connect to Remote Repository**

```bash
git remote add origin https://github.com/username/repository.git
```

**What it does**: Links your local folder to GitHub

**In our project**:
```bash
git remote add origin https://github.com/jiyaan-data-engineering/gcp-batch-08.git
```

**To verify**:
```bash
git remote -v
# Output:
# origin    https://github.com/jiyaan-data-engineering/gcp-batch-08.git (fetch)
# origin    https://github.com/jiyaan-data-engineering/gcp-batch-08.git (push)
```

---

### 8. **Push to GitHub**

```bash
git push -u origin master
```

**What it does**: Uploads commits to GitHub

**In our project**:
```bash
git push -u origin master
# Output: [new branch] master -> master
```

**After first time**:
```bash
git push  # Just this, shorter version
```

**What `-u` means**: Set upstream (remember this branch for future pushes)

---

### 9. **Clone a Repository**

```bash
git clone https://github.com/username/repository.git
```

**What it does**: Downloads a repository from GitHub to your computer

**Example**:
```bash
git clone https://github.com/jiyaan-data-engineering/gcp-batch-08.git
cd gcp-batch-08
```

**This creates**:
```
gcp-batch-08/          ← New folder
├── README.md
├── config.json
├── cricbuzz_api_data.py
├── .git/              ← Git history
└── ... (other files)
```

---

### 10. **Pull Changes**

```bash
git pull
```

**What it does**: Downloads latest changes from GitHub to your computer

**When to use**: Someone else made changes and pushed them

**Process**:
```
Remote (GitHub)          Local (Your Computer)
    o--o--o              o--o
        │                   │
        └─────git pull──────┘
               (download latest)
```

---

## Real Project Examples

### Example 1: Starting the Project (First Time)

**Scenario**: You have a new project folder and want to track it with Git

```bash
# Step 1: Go to your project folder
cd /path/to/cricbuzz-odi-ranking-data-batch-08

# Step 2: Initialize Git
git init
# Output: Initialized empty Git repository

# Step 3: Configure your identity
git config user.name "Your Name"
git config user.email "your@email.com"

# Step 4: Add all files
git add -A

# Step 5: Create first commit
git commit -m "Initial commit: Add Cricbuzz data extraction pipeline"

# Step 6: Add remote connection
git remote add origin https://github.com/jiyaan-data-engineering/gcp-batch-08.git

# Step 7: Push to GitHub
git push -u origin master

# Result: Your project is now on GitHub! ✅
```

---

### Example 2: Making Changes (What We Did)

**Scenario**: You modify a file and want to save changes

```bash
# Step 1: Check what changed
git status
# Output shows: modified: cricbuzz_api_data.py

# Step 2: View the changes
git diff cricbuzz_api_data.py
# Shows line-by-line changes

# Step 3: Stage the changes
git add cricbuzz_api_data.py

# Step 4: Verify it's staged
git status
# Output shows: Changes to be committed: cricbuzz_api_data.py

# Step 5: Commit with message
git commit -m "fix: Remove emoji characters for Windows compatibility"

# Step 6: Push to GitHub
git push

# Result: Changes saved both locally and on GitHub ✅
```

---

### Example 3: Adding Documentation (What We Did)

**Scenario**: You create new documentation files

```bash
# Step 1: Create new files
# (You edit in your IDE and save them)
# New files: PROJECT_DOCUMENTATION.md, updated README.md

# Step 2: Check status
git status
# Output: Untracked files: PROJECT_DOCUMENTATION.md
#         modified: README.md

# Step 3: Add all new/modified files
git add -A

# Step 4: Commit
git commit -m "docs: Add comprehensive project documentation for teaching

- Create PROJECT_DOCUMENTATION.md with detailed explanations
- Update README.md with getting started guide"

# Step 5: Push
git push

# Result: Documentation now available on GitHub for others ✅
```

---

### Example 4: Deleting Files

**Scenario**: You have duplicate/unused files to remove

```bash
# Step 1: Check what's tracked
git status

# Step 2: Remove files (git tracks the deletion)
git add -A  # This includes file deletions

# Step 3: Commit the deletion
git commit -m "chore: Remove duplicate files

- Delete extract_and_push_gcs copy.py (duplicate)
- Remove odi_function.py (unused)"

# Step 4: Push
git push

# Result: Files removed from project and history ✅
```

---

## Common Workflows

### Workflow 1: Daily Development

```
Morning: git pull (get latest from team)
         ↓
During Day: Work on files
            ↓
            Every few hours: git add -A
                             git commit -m "..."
                             ↓
End of Day: git push (backup to GitHub)
```

### Workflow 2: Feature Development (Branching)

```bash
# Create new branch for a feature
git branch feature/new-data-source
git checkout feature/new-data-source

# Or do both at once:
git checkout -b feature/new-data-source

# Make changes
# ... edit files ...

# Commit changes
git add -A
git commit -m "feat: Add new data source for women's cricket"

# Push to GitHub
git push -u origin feature/new-data-source

# Later: Merge back to master
git checkout master
git merge feature/new-data-source
```

### Workflow 3: Fixing a Mistake

```bash
# Option 1: Undo last commit (keep changes)
git reset --soft HEAD~1

# Option 2: Undo last commit (lose changes)
git reset --hard HEAD~1

# Option 3: View what was lost
git reflog  # Shows all commits, even deleted ones

# Option 4: Revert a specific commit
git revert commit-hash
```

---

## Troubleshooting

### Problem 1: "fatal: not a git repository"

**Cause**: You're not in a Git project folder

**Solution**:
```bash
# Check if .git folder exists
ls -la  # (Mac/Linux) or dir (Windows)

# If no .git folder:
git init
```

---

### Problem 2: "Permission denied (publickey)"

**Cause**: GitHub doesn't recognize your computer

**Solution**: Set up SSH key
```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -C "your@email.com"

# Add to GitHub:
# 1. Go to GitHub Settings → SSH Keys
# 2. Add the public key (cat ~/.ssh/id_rsa.pub)
```

---

### Problem 3: "Your branch is ahead of origin/master by X commits"

**Cause**: You made local commits but haven't pushed

**Solution**:
```bash
git push
# Now local and remote are in sync
```

---

### Problem 4: "everything up-to-date" but changes aren't on GitHub

**Cause**: You didn't commit, just modified files

**Solution**:
```bash
git status  # Check current state

git add -A  # Stage changes

git commit -m "Your message"  # Create commit

git push  # Now push
```

---

### Problem 5: "merge conflict"

**Cause**: You and someone else edited the same line

**Solution**:
```bash
# Edit the conflicted file manually
# Look for:
# <<<<<<< HEAD
# your code
# =======
# their code
# >>>>>>>

# Delete markers and keep what you want
git add filename.py
git commit -m "Resolved merge conflict"
```

---

## Git Commands Cheat Sheet

| Task | Command |
|------|---------|
| Start tracking | `git init` |
| Check status | `git status` |
| See changes | `git diff` |
| Stage changes | `git add filename.py` or `git add -A` |
| Commit | `git commit -m "message"` |
| View history | `git log` or `git log --oneline` |
| Connect to GitHub | `git remote add origin URL` |
| Push to GitHub | `git push` |
| Pull from GitHub | `git pull` |
| Download repo | `git clone URL` |
| Create branch | `git checkout -b branch-name` |
| Switch branch | `git checkout branch-name` |
| Merge branches | `git merge branch-name` |
| Delete branch | `git branch -d branch-name` |
| Undo changes | `git reset --hard HEAD~1` |

---

## Step-by-Step: Your First Project

If you're starting fresh:

### 1️⃣ **Clone This Project**
```bash
git clone https://github.com/jiyaan-data-engineering/gcp-batch-08.git
cd gcp-batch-08
```

### 2️⃣ **Explore the Repository**
```bash
# See all commits
git log --oneline

# See current branch
git branch

# See remote connections
git remote -v
```

### 3️⃣ **Make Your First Change**
```bash
# Edit a file in your IDE
# Example: Modify README.md with your notes

# Check what changed
git status
git diff README.md

# Stage the change
git add README.md

# Commit
git commit -m "docs: Add my learning notes"

# Push
git push
```

### 4️⃣ **Create a Feature Branch**
```bash
# Create new branch
git checkout -b feature/my-experiment

# Make changes
# ... edit files ...

# Commit
git add -A
git commit -m "feat: Add my new feature"

# Push
git push -u origin feature/my-experiment

# On GitHub, create a Pull Request to merge back to master
```

---

## Remember!

### The Three Most Important Commands:
1. `git add -A` - Prepare files
2. `git commit -m "message"` - Save locally
3. `git push` - Backup to GitHub

### The Git Workflow:
```
CREATE/EDIT → ADD → COMMIT → PUSH
```

### Think of It As:
- **Edit**: Make changes to your files
- **Add**: Put changes in a box
- **Commit**: Label the box with a description
- **Push**: Send the box to GitHub (backup)

---

## Key Takeaways

✅ Git tracks changes to your code  
✅ Commits are snapshots with descriptions  
✅ Always push to backup on GitHub  
✅ Use clear commit messages  
✅ Pull before starting work  
✅ Branches let you work safely  
✅ History helps you understand what happened  

---

## Helpful Resources

- **Official Git Book**: https://git-scm.com/book/en/v2
- **Interactive Tutorial**: https://learngitbranching.js.org/
- **GitHub Guides**: https://guides.github.com/
- **Git Cheat Sheet**: https://education.github.com/git-cheat-sheet-education.pdf

---

## Practice Exercises

### Exercise 1: Clone & Explore
```bash
git clone https://github.com/jiyaan-data-engineering/gcp-batch-08.git
cd gcp-batch-08
git log --oneline
git show commit-hash  # View a specific commit
```

### Exercise 2: Make Changes & Commit
```bash
# Edit README.md
git add README.md
git commit -m "docs: Add my notes"
git log --oneline  # See your new commit
```

### Exercise 3: Create a Branch
```bash
git checkout -b practice/learning
# Make some changes
git add -A
git commit -m "feat: Practice commit"
git log --oneline
```

---

**Congratulations! You now understand Git! 🎉**

Keep practicing and you'll become a Git expert in no time!
