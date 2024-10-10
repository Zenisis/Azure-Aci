Launching the Redmine Application using Azure Container Instance
Steps to Launch:
Clone the Repository
Clone the repository containing the Terraform code.

Run Terraform Configuration for Azure-ACR
Navigate to the Azure-ACR folder and run the Terraform configuration to create the Azure Container Registry.

Add the Docker Image to the Registry
Ensure that the Docker image (in this case, the Redmine image) is added to the Azure Container Registry.

Run Terraform Code for Azure-ACI
Navigate to the Azure-ACI folder and run the Terraform code. This will create the container for Redmine.

Run Terraform Code for Nginx-VM
Navigate to the Nginx-VM folder and run the Terraform code to create a Virtual Machine for Nginx.

SSH to the VM
SSH into the newly created VM and add your Nginx configuration file to the appropriate folder.

Edit the configuration file:
Replace server_name with your desired server name.
Replace proxy_pass with the public IP address of the Azure Container Instance (ACI).


Configure the Domain Name in AWS
The domain name is configured in AWS. Go to Route 53, select the required hosted zone, then select the desired record. Edit the record to add the IP address of the Nginx VM.
