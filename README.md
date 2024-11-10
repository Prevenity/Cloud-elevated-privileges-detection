Cloud Elevated Privileges Detection

A collection of scripts designed to identify accounts (user/group/service) with elevated privileges in Azure and Google Cloud Platform (GCP). These scripts also provide a visualization of the relationships between accounts and cloud resources, offering insights into privilege assignments and access structures.
Example of visulization in neo4j is presented below:

![image](https://github.com/user-attachments/assets/eb55f53f-c19e-4e6d-8463-c56d7e1f3cb4)

Description of cases

Case 1: (GCP) Impersonation of Kubernetes Service accounts (KSA) and Google Kubernetes Engine Service Accounts (GKESA)

Analyzing and mapping relationships between Google Kubernetes Engine (GKE) Service Accounts (SAs), Kubernetes Service Accounts (KSAs), Kubernetes namespaces, and pods to provide a comprehensive view of access patterns and resource interactions within Kubernetes environments.

Key elements:

1. Collecting basic information from kubernetes with use of kubectl (k8s\_collector.sh)  
   1. information about kubernetes service accounts  
   2. information about GCP service accounts connected to kubernetes service accounts  
   3. information about namespaces  
   4. information about pods  
2. Executing parser which formats information from K8S(k8s\_case\_parser.sh).   
3. Preparing input data for neo4j  
   1. neo4j\_preparation\_nodes.sh  
   2. neo4j\_preparation\_relations.sh

We need to create two types of files. Files with nodes and files with source, target relationships. In this case, nodes are: kubernetes service accounts, GKE service accounts, pods and namespaces. Transactions occur between kubernetes service accounts and GKE service accounts (there can be 1:1 ksa \- gkesa relationship), kubernetes service accounts and namespaces (kubernetes service accounts are assigned to namespaces) and pods and namespaces (pods belong to namespaces).

$sh neo4j\_preparation\_nodes.sh 01\_ksa\_nodes.txt ksa\_nodes.csv  
$sh neo4j\_preparation\_nodes.sh 01\_gkesa\_nodes.txt gkesa\_nodes.csv  
$sh neo4j\_preparation\_nodes.sh 01\_namespace\_nodes.txt namespaces\_nodes.csv  
$sh neo4j\_preparation\_nodes.sh 01\_pod\_nodes.txt pods\_nodes.csv  
$sh neo4j\_preparation\_relations.sh 00\_KSA\_TO\_GKESA.txt ksa\_to\_gkesa.csv  
$sh neo4j\_preparation\_relations.sh 00\_KSA\_TO\_NAMESPACE.txt ksa\_to\_namespaces.csv  
$sh neo4j\_preparation\_relations.sh 00\_POD\_TO\_NAMESPACE.txt pod\_to\_namespaces.csv

4. Importing data to neo4j

List of csv files to import:

* Nodes:  
  * gkesa\_nodes.csv  
  * ksa\_nodes.csv  
  * amespaces\_nodes.csv  
  * pods\_nodes.csv  
* Relationships:  
  * ksa\_to\_gkesa.csv	  
  * ksa\_to\_namespaces.csv  
  * pod\_to\_namespaces.csv	

Step 1: importing all nodes and relationship files.

<img width="359" alt="image3" src="https://github.com/user-attachments/assets/b1d3a0ad-a06c-4eff-b08e-535b39cd0b6a">

Step 2: creation of model

Step 2a: definition of first node \- GKESA  

![image6](https://github.com/user-attachments/assets/57e6a2c0-6984-45d5-8249-a5aa5ec554bb)

Step 2b: example of defined nodes

![image7](https://github.com/user-attachments/assets/3fce8351-d3c6-4ee5-bfdc-932b3d5c7b76)

Step 2c: defining first relation: POD \-\> Namespace

![image9](https://github.com/user-attachments/assets/aaeac5de-91d7-4278-8f2a-6f69536261ec)

Step 2d: example of defined relations

<img width="495" alt="image2" src="https://github.com/user-attachments/assets/9244a449-cd11-4cc7-8e8f-b3050ca3003d">

Step 3: import of data

3a. view in preview mode:

<img width="782" alt="image5" src="https://github.com/user-attachments/assets/7dd91913-ac6c-4b1a-9b12-ec137b34f47f">

Case 2: (GCP) Service Account Impersonation

Identifying all users and service accounts with the ability to impersonate other service accounts in Google Cloud Platform (GCP). Mapping and analyzing impersonation relationships between users, service accounts, and GCP resources to uncover potential access pathways and security risks.

GCP scripts:

* 01\_collect\_default\_roles\_with\_high\_privileges.sh  
* 02\_find\_default\_roles\_in\_projects\_direct\_SA.sh  
* 03\_find\_custom\_roles\_in\_proj.sh  
* 04\_find\_custom\_roles\_at\_org\_level.sh  
* 05\_find\_custom\_roles\_in\_folders.sh  
* 06\_find\_custom\_org\_roles\_at\_direct\_projects.sh  
* 07\_find\_custom\_org\_roles\_at\_projects.sh  
* 07a\_find\_custom\_roles\_at\_projects.sh  
* 08\_find\_default\_roles\_in\_org\_folders\_projects.sh

* permissions\_list.txt \- list of permissions  
* gcp\_parser.sh \- main script  
* temp\_file\_with\_default\_roles\_containing\_high\_priveleges.txt \- list of default roles with permissions from permissions\_list.txt.

Step 1: Creation of nodes

![image1](https://github.com/user-attachments/assets/87369392-7417-446a-9fed-ec207fbdfd18)

Step 2: Creation of simple relation

![image4](https://github.com/user-attachments/assets/c0e51418-98bb-4b07-81e0-e7f2f81c97bd)

Case 3: (Azure) Admin access

Identifying all users, groups, and service accounts with elevated privileges in Azure. Mapping and analyzing relationships associated with administrative roles to uncover connections between users, groups, service accounts, and Azure resources, providing a detailed view of privilege distribution and access control.

Azure scripts:

- Azure SDK commands (AzureAD)  
  - 01\_EnumUsersRolesPermissions-AzureAD\_v1.ps1  
  - 01\_EnumUsersRolesScopes-AzureAD.ps1  
  - 02\_EnumServicePrincipalsRolesPermissions-AzureAD\_v1.ps1  
  - 03\_EnumServicePrincipals-AzureAD\_v2.ps1  
  - 04\_EnumGroupsMembers-AzureAD.ps1  
  - 04\_EnumRolesInGroups-AzureAD.ps1  
  - 05\_EnumUsersADroles-AzureAD\_v2.ps1  
  - 06\_HighPermissionsUsers-AzureAD.ps1  
- Microsoft Graph commands (MG)  
 - 07\_Search\_all\_high\_priv\_permissions-MG.ps1  
 - 07\_Search\_all\_high\_priv\_permissions-MG\_v2.ps1  
 - 08\_EnumAllAppsConsents-MG.ps1  
 - 08\_EnumAllPrincipalsConsents-MG.ps1  
 - 08\_EnumAllUsersConsents-MG.ps1

- Roles.txt \- list of roles with high privileges

In example below the following scripts where used:

- 03\_EnumServicePrincipals-AzureAD\_v2.ps1 \- script for identifying Service Principals and roles  
- 04\_EnumRolesInGroups-AzureAD.ps1 \- enumeration of roles for AD groups  
- 04\_EnumGroupsMembers-AzureAD.ps1 \- enumerate all members of AD groups  
- 01\_EnumUsersRolesPermissions-AzureAD\_v1.ps1 \- script for identifying Users and roles

Parsers:  
 - Azure\_case\_parser.sh \- main script
 - GroupMembers\_csv\_parser.py  
 - GroupRolesPermissions\_csv\_parser.py  
 - ServicePrincipal\_Permissions\_csv\_parser.py  
 - UserRolesPermissions\_csv\_parser.py  
 - concatGR.py  
 - concatGRMEM.py  
 - concatSP.py  
 - concatUser.py

Azure relations in Neo4j:
 
<img width="460" alt="image8" src="https://github.com/user-attachments/assets/7e36f69a-28fd-4cda-8730-8a2bd1e7cbad">

