# Setting up a 2-Tier Architecture with Azure 


 <img src="images/VM_AZURE.png" width="400"/>


### Step 1: Create a virtual machine on Azure 
1) Log into Azure portal and select the resource group [tech254], followed by create on top left.
   
    ![Alt text](images/select_tech254.png)

    ![Alt text](images/create.png)

2) Search for "Ubuntu pro 18.04 lts" followed by pressing create. 
   
   ![Alt text](images/ubuntu.png)

3) Now, we need to select our resource group, a name for your vm as below. 
   
   ![Alt text](images/vm.png)

4) Select Standard B1s size followed by selecting your SSH key that we have stored in our azure. Then finally add an inbound port for HTTP. 
   
    ![Alt text](images/ssh_keys.png)

5) On OS disk type, I have selected standard SSD followed by ticking delete with VM. 

    ![Alt text](images/stander_os_disk.png)

6) For the virtual network, I have selected the virtual network which I have created, followed by assigning my app virtual machine to public subnet and then assigning public IP. 
   
   ![Alt text](images/networking.png)


7) Finally, for the tags, I have selected owner followed by name and selected review and create.
   
    ![Alt text](images/tags.png)

    ![Alt text](images/deployment_in_progress.png)

### Step 2: SSH into VM ( First test- Deploying app through script)

1) After your VM has been created, select connect on the top of the bar. 

    ![Alt text](images/connect.png)

2) Select Native SSH. 
   
   ![Alt text](images/native_ssh.png)

3) You will see a SSH connect bar on the right hand side, copy the command and paste on your gitbash terminal. 

    ![Alt text](images/ssh.png)
   
   
 4) We will SSH into our VM. 

    ![Alt text](images/ssh_into_vm.png)

5) I want to create a provision file in order to execute my script so I can test it out before implementing this on the user data on Azure. So we need to run `sudo nano provision.sh` 
   
   ![Alt text](images/provision_sh.png)

6) In the provision.sh file, we will write the following script in order to install all dependencies and start our app. 

    ```bash
    #!/bin/bash

    # update & upgrade
    sudo apt update -y
    sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

    # install nginx
    sudo apt install nginx -y

    # setup nginx reverse proxy
    sudo apt install sed
    # $ and / characters must be escaped by putting a backslash before them
    sudo sed -i "s/try_files \$uri \$uri\/ =404;/proxy_pass http:\/\/localhost:3000\/;/" /etc/nginx/sites-available/default

    # restart nginx 
    sudo systemctl restart nginx

    # enable nginx 
    sudo systemctl enable nginx

    # install nodejs 12.x
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install nodejs -y

    # install pm2 (only necessary later)
    sudo npm install pm2 -g

    # get git if not present 
    sudo apt install git -y

    # clone repo with app folder into folder called 'repo' - only needed if don't have the app folder already
    git clone https://github.com/Pxxmie/AWS_and_Cloud_Computing.git

    # install the app (must be after db vm is finished provisioning)
    cd AWS_and_Cloud_Computing/app/app
    npm install

    # start the app (could also use 'npm start')
    pm2 start app.js
    
    ```
    ![Alt text](images/provision_sh_filee.png)
7) Save and exit our provision.sh file, and change the permission of it so we can execute the file. Then run the file after. 
   
   ```bash
   sudo chmod +x provision.sh
   sudo ./provision.sh 
   ```
   ![Alt text](images/sudo_chmod_provision.png)

8) It will take a couple of minutes, for your script to execute and finally at the end you should see this screen showing that your app has been deployed. 
   
    ![Alt text](<images/successfully_installed .png>)

9) Copy your public ip address from your vm in azure onto a browser and you should successfully see your app running. 
    
    ![Alt text](images/sparta_test_app.png)

### Step 3: Deploy app through user data on Azure

1) Now that we have successfully tested our commands manually and through a script, we are ready to implement this on our user data. 

2) We are going to delete our old vm that we tested and create a new one for our app deployment. After filling out all the fields, we are going to add the following script onto our user data. 

    ![Alt text](images/user_data_add.png)

3) It will take around 5-6 minutes to execute the user data. Copy and paste your IP address from your vm onto the browser. You should see your Sparta test app deployed. 

     ![Alt text](images/sparta_test_app_user_data.png)


### Step 4: Create a virtual machine for Database

Now that we have successfully deployed our app virtual machine. Lets create a vm for our database on the private subnet. 

1) Fill in the required fields and give it a name to specify its a database vm. 
   
    ![Alt text](images/db_vm.png)

2) Under network settings, we are going to select **private subnet** , select none for public IP, followed by advanced as we want to add port 27017 for mongodb.
    
    ![Alt text](images/db_network.png)

    ![Alt text](images/db_network_security.png)

3) On the user data, we are going to add the following script in order automate the configurations. 

    ```bash
    #!/bin/bash

    # update and upgrade with user input bypass
    sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

    # Install the version of MongoDB (3.2) required using the following command:
    wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -

    echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

    # Do sudo apt update again.
    sudo apt update

    # Specify the components of MongoDB to be installed using the following command:
    sudo apt-get install -y mongodb-org=3.2.20 mongodb-org-server=3.2.20 mongodb-org-shell=3.2.20 mongodb-org-mongos=3.2.20 mongodb-org-tools=3.2.20

    # Input the following command to alter the IP address for who can connect in the mongodb config:
    sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

    echo "Modified MongoDB configuration to allow all connections."

    sudo systemctl start mongod

    sudo systemctl enable mongod

    ```

    ![Alt text](images/db_userdata.png)

### Step 5: Create an App vm to export DB 

1) Create an app vm and complete the following fields. 
   
   ![Alt text](images/app_and_db.png)

2) Fill in the required fields for network, such as allowing port 80 (HTTP), selecting public subnet. 

3) On the user data, copy the following script; in the user data we want to set an envrionment variable for our mongodb database, we need to copy our private ip address from our db vm into this. 

   In this case, the MongoDB server is located at 10.0.3.4 and the database name is posts. Finally we also added a command to run the node.js  script located in seed.js file. 

    ```bash
    #!/bin/bash

    # update & upgrade
    sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

    # install nginx
    sudo apt install nginx -y

    # setup nginx reverse proxy
    sudo apt install sed

    # $ and / characters must be escaped by putting a backslash before them
    sudo sed -i "s/try_files \$uri \$uri\/ =404;/proxy_pass http:\/\/localhost:3000\/;/" /etc/nginx/sites-available/default

    # restart nginx 
    sudo systemctl restart nginx

    # enable nginx 
    sudo systemctl enable nginx

    # install nodejs 12.x
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -

    sudo apt-get install nodejs -y

    export DB_HOST=mongodb://10.0.3.4/posts

    # install pm2 (only necessary later)
    sudo npm install pm2 -g

    # get git if not present 
    sudo apt install git -y

    # clone app folderm from github
    git clone https://github.com/Pxxmie/AWS_and_Cloud_Computing.git

    # install the app (must be after db vm is finished provisioning)
    cd AWS_and_Cloud_Computing/app/app

    sudo systemctl restart nginx

    npm install

    node seeds/seed.js

    pm2 kill

    # start the app (could also use 'npm start')
    pm2 start app.js

    # restart the app
    pm2 restart app.js
    ```
    ![Alt text](images/app_db_user_data.png)

4) Finally, copy and paste your app ip address into the browser URL. 
   You should successfully see your sparta test page, enter **/posts** after your IP address to see the database. 

   ![Alt text](images/posts_page.png)