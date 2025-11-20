#!/bin/bash

# Configuration
PROJECT_ID="moonlit-shadow-469016-h0"
CLUSTER_NAME="my-gke-cluster"
ZONE="us-central1-a"
NUM_NODES=3
MACHINE_TYPE="e2-medium"

# Set project
gcloud config set project $PROJECT_ID

# Enable APIs
gcloud services enable container.googleapis.com

# Create cluster
gcloud container clusters create $CLUSTER_NAME \
    --zone $ZONE \
    --num-nodes $NUM_NODES \
    --machine-type $MACHINE_TYPE \
    --disk-size 30 \
    --enable-autoscaling \
    --min-nodes 1 \
    --max-nodes 5

# Get credentials
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

echo "Cluster created successfully!"
echo "You can now deploy your application with: kubectl apply -f deployment.yaml"
