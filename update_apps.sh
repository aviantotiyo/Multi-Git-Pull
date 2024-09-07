#!/bin/bash

# List of application directories
APPS=(
    "/var/www/app1"
    "/var/www/app2"
    "/var/www/app3"
    "/var/www/app4"
)

# Git branch to pull from
BRANCH="production"  # Using the 'production' branch

# Loop through each application directory and perform git pull
for APP in "${APPS[@]}"
do
    echo "----------------------------------------"
    echo "Updating $APP ..."
    if [ -d "$APP" ]; then
        cd "$APP" || { echo "Failed to navigate to $APP"; exit 1; }
        echo "Current Directory: $(pwd)"
        git fetch origin "$BRANCH"
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse "@{u}")
        BASE=$(git merge-base @ "@{u}")

        if [ "$LOCAL" = "$REMOTE" ]; then
            echo "Already up to date."
        elif [ "$LOCAL" = "$BASE" ]; then
            echo "Pulling latest changes from $BRANCH."
            git pull origin "$BRANCH"
        else
            echo "Local repository is ahead or has diverged. Manual intervention required."
        fi
    else
        echo "Directory $APP does not exist."
    fi
done

echo "----------------------------------------"
echo "All applications have been updated."