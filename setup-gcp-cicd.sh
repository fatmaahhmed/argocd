#!/bin/bash
set -e

echo "🚀 Starting GCP + GitHub CI/CD Setup..."

# Check dependencies
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud is not installed."
    exit 1
fi
if ! command -v gh &> /dev/null; then
    echo "❌ gh (GitHub CLI) is not installed."
    exit 1
fi

# Inputs
read -p "Enter your Google Cloud Project ID: " PROJECT_ID
read -p "Enter your desired Region (default: us-central1): " REGION
REGION=${REGION:-us-central1}
read -p "Enter your desired Repository Name (default: my-repo): " REPO_NAME
REPO_NAME=${REPO_NAME:-my-repo}

echo "----------------------------------------"
echo "Configuration:"
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Repository: $REPO_NAME"
echo "----------------------------------------"

# Confirm
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# GCP Setup
echo "🔹 Setting project..."
gcloud config set project "$PROJECT_ID"

echo "🔹 Enabling Artifact Registry API..."
gcloud services enable artifactregistry.googleapis.com

echo "🔹 Creating Artifact Registry Repository..."
if ! gcloud artifacts repositories describe $REPO_NAME --location=$REGION &> /dev/null; then
    gcloud artifacts repositories create $REPO_NAME --repository-format=docker --location=$REGION --description="Docker repository"
else
    echo "⚠️  Repository $REPO_NAME already exists, skipping creation."
fi

echo "🔹 Creating Service Account..."
SA_NAME="github-actions-sa"
if ! gcloud iam service-accounts describe $SA_NAME@$PROJECT_ID.iam.gserviceaccount.com &> /dev/null; then
    gcloud iam service-accounts create $SA_NAME --display-name="GitHub Actions SA"
else
    echo "⚠️  Service Account $SA_NAME already exists, using existing."
fi

echo "🔹 Granting Permissions..."
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/artifactregistry.writer"

echo "🔹 Generating Key..."
gcloud iam service-accounts keys create key.json --iam-account=$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com

# GitHub Secrets
echo "🔹 Setting GitHub Secrets..."
gh secret set GCP_PROJECT_ID --body "$PROJECT_ID"
gh secret set GCP_CREDENTIALS < key.json

# File Updates
echo "🔹 Updating Configuration Files..."
# Update deploy.yaml
sed -i '' "s/YOUR_PROJECT_ID/$PROJECT_ID/g" .github/workflows/deploy.yaml
sed -i '' "s/my-repo/$REPO_NAME/g" .github/workflows/deploy.yaml
sed -i '' "s/us-central1/$REGION/g" .github/workflows/deploy.yaml

# Update manifests
sed -i '' "s/YOUR_PROJECT_ID/$PROJECT_ID/g" argoFiles/api.yaml argoFiles/client.yaml
sed -i '' "s/my-repo/$REPO_NAME/g" argoFiles/api.yaml argoFiles/client.yaml
sed -i '' "s/us-central1/$REGION/g" argoFiles/api.yaml argoFiles/client.yaml

# Cleanup
rm key.json

echo "✅ Setup Complete! You can now push to main to trigger the deployment."
