#!/bin/bash
set -e

# Define markers
START_MARKER="<!-- START TECHNOLOGIES -->"
END_MARKER="<!-- END TECHNOLOGIES -->"

# Create temporary files
TECH_SECTION=$(mktemp)
README_TEMP=$(mktemp)

# Get the technologies section
echo "" > $TECH_SECTION  # Start with a blank line

# Process the technologies.json file
# This will output each badge on its own line
jq -r 'to_entries | sort_by(.value.id) | .[] | .value.icon' technologies.json | while read -r ICON; do
  echo "$ICON" >> $TECH_SECTION
done

# Create the new README

# 1. Extract the part before the START_MARKER (including the marker)
sed -n "1,/$START_MARKER/p" README.md > $README_TEMP

# 2. Add the technology section
cat $TECH_SECTION >> $README_TEMP

# 3. Add the END_MARKER and everything after it
sed -n "/$END_MARKER/,\$p" README.md >> $README_TEMP

# Replace the old README with the new one
mv $README_TEMP README.md

# Clean up
rm $TECH_SECTION

echo "✅ README.md updated successfully"