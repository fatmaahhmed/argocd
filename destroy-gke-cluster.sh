#!/bin/bash

# Configuration
PROJECT_ID="moonlit-shadow-469016-h0"
CLUSTER_NAME="my-gke-cluster"
ZONE="us-central1-a"

# Set project
gcloud config set project $PROJECT_ID

echo "WARNING: This will delete the cluster '$CLUSTER_NAME' in zone '$ZONE'"
echo "This action cannot be undone!"
read -p "Are you sure you want to continue? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Cluster deletion cancelled."
    exit 0
fi

echo "Deleting cluster..."
gcloud container clusters delete $CLUSTER_NAME \
    --zone $ZONE \
    --quiet

echo "Cluster deleted successfully!"
