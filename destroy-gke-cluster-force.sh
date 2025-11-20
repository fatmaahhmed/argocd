#!/bin/bash

# Configuration
PROJECT_ID="moonlit-shadow-469016-h0"
CLUSTER_NAME="my-gke-cluster"
ZONE="us-central1-a"

# Set project
gcloud config set project $PROJECT_ID

echo "Deleting cluster '$CLUSTER_NAME'..."
gcloud container clusters delete $CLUSTER_NAME \
    --zone $ZONE \
    --quiet

echo "Cluster deleted successfully!"
