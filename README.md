The terrform code launch Redmine application by Azure container instance
steps to launch this
step 1 - clone the repo 
step 2 - run terraform config for folder Azure-ACR  first to create container registory 
step 3 - add the docker image to that registory (as of in this code  the registory having redmine image )
step 4  run terrform code for folder Azure-ACI  it will create container for redmine
step 5 run terrform code for folder Nginx-Vm it will create vm for nginx 
step 6 ssh to vm and add give config file in the folder edit the config file with desired changes in place of server add your server name and in place of proxy pass add ip address of ACI public ip 
