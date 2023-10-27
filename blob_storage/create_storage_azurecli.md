# Creating Blob storage through Azure CLI

1) Log in Azure cli 

```bash
az login 
```

2) Authorise azure cli with GitBash 

2) C****reate a storage account****

```bash
az storage account create --name tech254prismikastorage --resource-group tech254 --location uksouth --sku Standard_ZRS
```

![Alt text](images/Untitled.png)

1) ****Create a container****

```bash

az storage container create\
 --account-name tech254prismikastorage \
 --name testcontainer\
 --auth-mode login
```

***You need to have the right permission/ role to containers and blob storage otherwise you will not be able to access it.*** 

![Alt text](images/2.png)

**4) Create a file and Upload a blob**

```bash
touch test.txt
ls
sudo nano test.txt
```
![Alt text](images/3.png)

```bash
az storage blob upload \
   --account-name tech254prismikastorage \
   --container-name testcontainer \
   --name newtest.txt \
   --file test.txt \
   --auth-mode login #doesnt need backlash as there is not a line after this
```

![Alt text](images/4.png)

1) Access your container 

![Untitled](Blob%20storage%20445197cdda724b249420e0391ceb533c/Untitled%204.png)

![Untitled](Blob%20storage%20445197cdda724b249420e0391ceb533c/Untitled%205.png)

![Untitled](Blob%20storage%20445197cdda724b249420e0391ceb533c/Untitled%206.png)

**6) Change access level** 

![Untitled](Blob%20storage%20445197cdda724b249420e0391ceb533c/Untitled%207.png)

![Untitled](Blob%20storage%20445197cdda724b249420e0391ceb533c/Untitled%208.png)

**Download a Cat Picture using Curl:**

```bash
curl -o cat.jpg [https://cat-world.com/wp-content/uploads/2022/05/brown-kitten.jpg](https://cat-world.com/wp-content/uploads/2022/05/brown-kitten.jpg)
```

![Untitled](Blob%20storage%20445197cdda724b249420e0391ceb533c/Untitled%209.png)

**Rename the Cat Picture:**

```bash
mv cat.jpg cutecat.jpg
```

![Untitled](Blob%20storage%20445197cdda724b249420e0391ceb533c/Untitled%2010.png)

**Upload Blob:**

```bash
az storage blob upload \
   --container-name testcontainer \
   --name newcat.jpg \
   --file cutecat.jpg \
   --account-name tech254prismikastorage \
   --auth-mode login
```

![Untitled](Blob%20storage%20445197cdda724b249420e0391ceb533c/Untitled%2011.png)

![Untitled](Blob%20storage%20445197cdda724b249420e0391ceb533c/Untitled%2012.png)

**Make Blob Public:**

**Modify Homepage File (index.ejs):**

```bash
sed -i 's|</h2>\n|<img src="[https://tech254prismikastorage.blob.core.windows.net/testcontainer/newcat.jpg](https://tech254prismikastorage.blob.core.windows.net/testcontainer/newcat.jpg)">|' views/index.ejs
```

![Alt text](images/cat.png)