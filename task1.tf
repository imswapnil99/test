provider "aws" {
  region     = "ap-south-1"
  profile    = "mansi"
}

// --------creating Security Group------------

resource "aws_security_group" "sgrp" {
  name        = "task1sg"
 
  ingress {
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  
  }
}

resource "aws_security_group_rule" "sgrule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sgrp.id}"
  self              = true
}

resource "aws_security_group_rule" "sgrule2" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sgrp.id}"
  self              = true
}

// ------------Instance----------

resource "aws_instance" "taskinstance" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "task1Key"
  security_groups = [ "task1sg" ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("E:/DOWNLOADS/task1Key.pem")
    host     = aws_instance.taskinstance.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "taskos"
  }

}

//  -------------EBS volume---------------
resource "aws_ebs_volume" "taskvol" {
 availability_zone = "${aws_instance.taskinstance.availability_zone}"
 size              = 1

  tags = {
    Name = "task1Volume"
  }
}

resource "aws_volume_attachment" "mount" {
  device_name = "/dev/xvdh"
  volume_id   = "${aws_ebs_volume.taskvol.id}"
  instance_id = "${aws_instance.taskinstance.id}"
  force_detach = true
}

resource "null_resource" "sshConnect"  {

depends_on = [
    aws_volume_attachment.mount,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("E:/DOWNLOADS/task1Key.pem")
    host     = aws_instance.taskinstance.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/mansi-dadheech/hybrid_task1.git /var/www/html/"
    ]
  }
}

// ----------S3 Bucket -----------------

resource "aws_s3_bucket" "taskbucket" {
  bucket = "mybucket2224"
  acl    = "public-read"
 
  versioning {
    enabled = true
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}



resource "null_resource" "localcopy"  {

	provisioner "local-exec" {
                     command = "git clone https://github.com/mansi-dadheech/hybrid_task1_image.git  E:/terraformWorkspace/task1/photos"
	    
  	}
}

resource "aws_s3_bucket_public_access_block" "permission" {
  bucket = "${aws_s3_bucket.taskbucket.id}"

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_object" "object" {
  bucket = "mybucket2224"
  key    = "terraform.png"
  source = "E:/terraformWorkspace/task1/photos/terraform.png"
  content_type = "image/png"
  acl = "public-read"
  content_disposition = "inline"
  content_encoding = "base64"
  
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.taskbucket.bucket_regional_domain_name}"
    origin_id   = "S3-mybucket2224"

    
    custom_origin_config {
            http_port = 80
            https_port = 80
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
     }
    
}

  enabled             = true
  default_root_object = "terraform.png"

default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-mybucket2224"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
     }
  }
  tags = {
    Environment = "production"
  }
viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "task 1"
}

output "out" {
    value = aws_cloudfront_distribution.s3_distribution.domain_name
}

resource "null_resource" "local"  {

depends_on = [
       null_resource.sshConnect,
   
  ]

	provisioner "local-exec" {
	    
            command = "start firefox  ${aws_instance.taskinstance.public_ip}"
  	}
}



