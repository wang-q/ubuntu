
```powershell
# Pull the Ubuntu 24.04 image from Docker Hub
docker pull ubuntu:24.04

# Run a temporary Ubuntu 24.04 container and execute 'ls /' to list the root directory contents
docker run -t ubuntu:24.04 ls /

# Get the container ID that contains "ubuntu"
# Use docker container ls -a to list all containers
# Use Select-String to filter lines containing "ubuntu"
# Use ForEach-Object to extract the first field (container ID) from each line
# Use Trim() to remove any extra spaces
$dockerContainerID = (docker container ls -a | Select-String -Pattern "ubuntu" | ForEach-Object { $_.ToString().Split(' ')[0] }).Trim()

# Create a directory to store the exported container file
mkdir -p $HOME\VM

# Export the specified container and save it as a tar file
docker export $dockerContainerID > $HOME\VM\noble.tar

# Import the exported container tar file into WSL, creating a WSL instance named noble
wsl --import noble $HOME\VM\noble $HOME\VM\noble.tar

# List all WSL instances and their version information
wsl -l -v

# Start the WSL instance named noble
wsl -d noble

# To refresh the wsl.conf configuration file (if needed)
# Terminate the noble instance to achieve this
# wsl --terminate noble

```
