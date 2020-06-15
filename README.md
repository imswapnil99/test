This is the first task given by Vimal Daga sir under Hybrid Multi Cloud Training of creating a complete automated architecture consisting of AWS Instances, AWS Storage(EBS and S3) through terraform.
Architecture:

![Untitled Diagram(4)](https://user-images.githubusercontent.com/48363834/84638224-4fb9ba00-af14-11ea-9759-bb90dfa48406.jpg)


Task Description:
1. Create the key and security group which allow the port 80.
2. Launch EC2 instance.
3. In this Ec2 instance use the key and security group which we have created in step 1.
4. Launch one Volume (EBS) and mount that volume into /var/www/html
5. Developer have uploded the code into github repo also the repo has some images.
6. Copy the github repo code into /var/www/html
7. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.
8 Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to  update in code in /var/www/html

To create this setup:
First we have to write providers- here AWS

![Screenshot (239)](https://user-images.githubusercontent.com/48363834/84639307-d15e1780-af15-11ea-82a5-6e9b4fbd7040.png)

Then create Security Group:

![Screenshot (238)](https://user-images.githubusercontent.com/48363834/84639401-f3579a00-af15-11ea-9696-a46d43f5f7a1.png)


Now we have to add security rules so that instance allow port no. 80 and 22.

![Screenshot (243)](https://user-images.githubusercontent.com/48363834/84639791-81338500-af16-11ea-93c6-26f0b68dcea1.png)


Now, we can launch an instance named “taskinstance” and setting up ssh connection to ec2-user of newly launched instance.
Then, by using remote-exec installing git,httpd and php and also starting service of httpd.

![Screenshot (244)](https://user-images.githubusercontent.com/48363834/84640284-1767ab00-af17-11ea-818a-73a6c49480dd.png)

Creating an ebs volume in the same availability zone of ec2 instance. And then attach it to ec2 instance .

![Screenshot (243)](https://user-images.githubusercontent.com/48363834/84640698-abd20d80-af17-11ea-85ad-ab37fd016387.png)

As we attached volume to ec2 now we to use this volume we have to format and mount this. For this we have to do ssh login.

![Screenshot (244)](https://user-images.githubusercontent.com/48363834/84641029-1f741a80-af18-11ea-9376-ab7f6eb1940f.png)

Now, We create a S3 bucket to store our files permanently.

![Screenshot (246)](https://user-images.githubusercontent.com/48363834/84641519-c3f65c80-af18-11ea-926d-43be71a82de5.png)

After creating bucket we have to place images in this so we will clone github repo in a folder at local system and then upload it.

![Screenshot (247)](https://user-images.githubusercontent.com/48363834/84641547-ca84d400-af18-11ea-9578-da5774062cad.png)


To upload object in S3 bucket we have to first add some permissions and then we can upload objects.

![Screenshot (249)](https://user-images.githubusercontent.com/48363834/84641828-454def00-af19-11ea-9580-619b3fa16b47.png)


Creating Cloud Front distributions and adding cache behaviours,restrictions and some policies.

![Screenshot (250)](https://user-images.githubusercontent.com/48363834/84642151-ad043a00-af19-11ea-949d-631601febaf9.png)
![Screenshot (251)](https://user-images.githubusercontent.com/48363834/84642417-0f5d3a80-af1a-11ea-8c0e-8231e449cd5f.png)

And then finally displaying webpage using instance ip

![Screenshot (252)](https://user-images.githubusercontent.com/48363834/84642612-59462080-af1a-11ea-9416-fb650eee24ab.png)
