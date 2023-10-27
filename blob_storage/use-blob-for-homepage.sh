az storage account create --name tech254prismikastorage --resource-group tech254 --location uksouth --sku Standard_ZRS


az storage container create\
 --account-name tech254prismikastorage \
 --name testcontainer\
 --auth-mode login

curl -o cat.jpg https://cat-world.com/wp-content/uploads/2022/05/brown-kitten.jpg


mv cat.jpg cutecat.jpg


az storage blob upload \
   --container-name testcontainer \
   --name newcat.jpg \
   --file cutecat.jpg \
   --account-name tech254prismikastorage \
   --auth-mode login

az storage container set-permission --name testcontainer --public-access blob --account-name tech254prismikastorage --auth-mode login


cd/AWS_and_Cloud_Computing/app/app

sed -i 's|</h2> \n|<img src="https://tech254prismikastorage.blob.core.windows.net/testcontainer/newcat.jpg">|' views/index.ejs

pm2 kill

pm2 start app.js