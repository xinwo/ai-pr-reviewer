#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <event_type> <test_file> [<log_file>]"
    echo "event_type should be one of: pull_request, issue_comment, pull_request_review_comment"
    echo "test_file should be an existing file under __tests__"
    exit 1
}

# Check if at least 2 parameters are provided
if [ $# -lt 2 ]; then
    echo "Error: At least 2 parameters are required."
    usage
fi

# Check if the first parameter is a valid event type
VALID_EVENTS=("pull_request" "issue_comment" "pull_request_review_comment")
EVENT_TYPE=$1
if [[ ! " ${VALID_EVENTS[@]} " =~ " ${EVENT_TYPE} " ]]; then
    echo "Error: Invalid event type."
    usage
fi

# Check if the second parameter is an existing file under __tests__
TEST_FILE="__tests__/$2"
if [ ! -f "$TEST_FILE" ]; then
    echo "Error: Test file '$TEST_FILE' does not exist."
    usage
fi

# Run npm build and package
npm run build
npm run package

# Handle the third parameter for log file
if [ $# -ge 3 ]; then
    LOG_FILE="logs/$3"
    if [ -f "$LOG_FILE" ]; then
        read -p "Log file '$LOG_FILE' already exists. Overwrite? (y/n): " OVERWRITE
        if [ "$OVERWRITE" != "y" ]; then
            echo "Aborting due to existing log file."
            exit 1
        fi
    fi
    act --env-file .env "$EVENT_TYPE" -e "$TEST_FILE" | tee "$LOG_FILE"
else
    act --env-file .env "$EVENT_TYPE" -e "$TEST_FILE"
fi