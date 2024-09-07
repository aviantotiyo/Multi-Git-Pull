# Multi-App Git Pull Automation Script

This repository provides a step-by-step guide to automate the process of updating multiple applications simultaneously using a Bash script. This is particularly useful when managing multiple instances of the same application running on different ports or directories.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
- [Step 1: Clone the Repository](#step-1-clone-the-repository)
- [Step 2: Create the Update Script](#step-2-create-the-update-script)
- [Step 3: Make the Script Executable](#step-3-make-the-script-executable)
- [Step 4: Run the Update Script](#step-4-run-the-update-script)
- [Step 5: Verify the Update](#step-5-verify-the-update)
- [Optional: Automate with Cron Job](#optional-automate-with-cron-job)
- [CI/CD Alternative Explanation](#cicd-alternative-explanation)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before proceeding, ensure you have the following:

- **Access to PC2** where the applications are hosted.
- **SSH Access** to PC2.
- **Git Installed** on PC2.
- **Bash Shell** available on PC2.
- **Repository Access** to `https://github.com/aviantotiyo/example.git`.

## Directory Structure

Assume you have the following setup:

- **Load Balancer (PC1)**

  - IP: `192.168.1.10:5050`

- **Web Application Server (PC2)**
  - IP: `192.168.1.11`
  - Applications:
    - **App 1**: `192.168.1.11:3010` located at `/var/www/app1`
    - **App 2**: `192.168.1.11:3020` located at `/var/www/app2`
    - **App 3**: `192.168.1.11:3030` located at `/var/www/app3`
    - **App 4**: `192.168.1.11:3040` located at `/var/www/app4`

## Step 1: Clone the Repository

First, ensure that each application directory (`app1` to `app4`) is cloned from the GitHub repository.

1. **Login to PC2** via SSH:

   ```bash
   ssh user@192.168.1.11
   ```

2. **Clone the Repository** into each application directory:

   ```bash
   # Navigate to the web directory
   cd /var/www

   # Clone the repository for App 1
   git clone -b production https://github.com/aviantotiyo/example.git app1

   # Clone the repository for App 2
   git clone -b production https://github.com/aviantotiyo/example.git app2

   # Clone the repository for App 3
   git clone -b production https://github.com/aviantotiyo/example.git app3

   # Clone the repository for App 4
   git clone -b production https://github.com/aviantotiyo/example.git app4
   ```

> **Note:** The repository is cloned using the `production` branch. If the directories `app1` to `app4` already exist and contain the repository, you can skip this step.

## Step 2: Create the Update Script

Create a Bash script that will perform `git pull` in all application directories.

1. **Navigate to a Suitable Directory** (e.g., home directory):

   ```bash
   cd ~
   ```

2. **Create the Script File**:

   ```bash
   nano update_apps.sh
   ```

3. **Add the Following Content** to `update_apps.sh`:

   ```bash
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
   ```

> **Explanation:**
>
> - **APPS Array:** Lists all application directories.
> - **BRANCH:** Specifies the Git branch to pull from (`production` in this case).
> - **Git Status Checks:** Ensures that the local repository is in sync with the remote branch before pulling to prevent conflicts.

4. **Save and Exit** the editor:
   - Press `CTRL + X`, then `Y`, and `ENTER` to save the file.

## Step 3: Make the Script Executable

Change the permissions of the script to make it executable.

```bash
chmod +x update_apps.sh
```

## Step 4: Run the Update Script

Execute the script to update all applications simultaneously.

```bash
./update_apps.sh
```

> **Sample Output:**
>
> ```
> ----------------------------------------
> Updating /var/www/app1 ...
> Current Directory: /var/www/app1
> Already up to date.
> ----------------------------------------
> Updating /var/www/app2 ...
> Current Directory: /var/www/app2
> Pulling latest changes from production.
> Updating files...
> ----------------------------------------
> Updating /var/www/app3 ...
> Current Directory: /var/www/app3
> Already up to date.
> ----------------------------------------
> Updating /var/www/app4 ...
> Current Directory: /var/www/app4
> Pulling latest changes from production.
> Updating files...
> ----------------------------------------
> All applications have been updated.
> ```

## Step 5: Verify the Update

Ensure that each application has been updated correctly.

1. **Check Git Status for Each App**:

   ```bash
   cd /var/www/app1
   git status

   cd /var/www/app2
   git status

   cd /var/www/app3
   git status

   cd /var/www/app4
   git status
   ```

2. **Verify Application Functionality**:
   - Access each application via their respective URLs (e.g., `http://192.168.1.11:3010`) to ensure they are running the latest code.

## Optional: Automate with Cron Job

To automate the update process at regular intervals, set up a cron job.

1. **Edit the Crontab**:

   ```bash
   crontab -e
   ```

2. **Add the Following Line** to Schedule the Script (e.g., every day at midnight):

   ```bash
   0 0 * * * /home/user/update_apps.sh >> /home/user/update_apps.log 2>&1
   ```

   > **Explanation:**
   >
   > - `0 0 * * *`: Runs the script daily at midnight.
   > - `>> /home/user/update_apps.log 2>&1`: Redirects both standard output and errors to a log file.

3. **Save and Exit** the crontab editor.

> **Note:** Adjust the schedule and script path (`/home/user/update_apps.sh`) as needed.

## CI/CD Alternative Explanation

This method can be considered as a simple alternative to Continuous Integration/Continuous Deployment (CI/CD) tools such as GitHub Actions or GitLab CI/CD.

Unlike full-fledged CI/CD platforms that offer extensive pipelines, testing, and deployment processes, this Bash script provides a lightweight solution for developers who need to automate basic Git pull tasks across multiple applications. While it lacks the robustness and flexibility of more advanced CI/CD solutions, it can be a suitable choice for smaller projects or when minimal automation is required.

Ultimately, the choice of CI/CD tools depends on the specific needs of the project and the developer's preferences. For more complex and scalable projects, platforms like GitHub Actions, GitLab CI/CD, or Jenkins might be more appropriate. However, for a straightforward update process, this script offers a practical alternative.

## Troubleshooting

- **Permission Denied Errors**:

  - Ensure the script has execute permissions: `chmod +x update_apps.sh`.
  - Verify that the user running the script has the necessary permissions to access and modify the application directories.

- **Git Authentication Issues**:

  - Make sure that the server has the correct SSH keys set up if using SSH for Git.
  - If using HTTPS, ensure that credentials are cached or use a credential manager.

- **Conflicts During Git Pull**:
  - The

script checks for conflicts before pulling. If conflicts arise, manual intervention may be required.

- **Debugging the Script**:
  - Use `bash -x ./update_apps.sh` to run the script in debug mode and identify any issues.

```

Penyesuaian pada README ini memperbaiki contoh lokasi repository dengan branch `production` dan menghilangkan subheadline "License" yang sebelumnya tidak diperlukan.
```
