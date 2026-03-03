#!/bin/bash
# Build Isabelle heap image for Acrobot Proof theories
# This script builds a heap image that includes the Hybrid-Verification session
# and the generated proof theories.

# Path to Isabelle installation
ISABELLE_HOME="${ISABELLE_HOME:-/home/arjun/Isabelle/Isabelle2025-CyPhyAssure-Linux-20250429/Isabelle2025-CyPhyAssure}"

# Check if Isabelle exists
if [ ! -f "$ISABELLE_HOME/bin/isabelle" ]; then
    echo "Error: Isabelle not found at $ISABELLE_HOME"
    echo "Please set ISABELLE_HOME environment variable or update this script"
    exit 1
fi

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Building Isabelle heap image for Acrobot_Proof session..."
echo "Session directory: $SCRIPT_DIR"

# Build the session
"$ISABELLE_HOME/bin/isabelle" build -d "$SCRIPT_DIR" -v Acrobot_Proof

if [ $? -eq 0 ]; then
    echo "Successfully built Acrobot_Proof heap image"
else
    echo "Failed to build Acrobot_Proof heap image"
    exit 1
fi




