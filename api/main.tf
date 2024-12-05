provider "aws" {
  region = "us-west-2" # Change to your region
}

# S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "your-s3-bucket-name"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = "MyS3Bucket"
  }
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowEC2Access",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:*",
        Resource  = [
          "arn:aws:s3:::${aws_s3_bucket.my_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.my_bucket.id}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_iam_instance_profile.ec2_profile.arn
          }
        }
      }
    ]
  })
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for S3 Access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "ec2-s3-access-policy"
  description = "Policy to allow EC2 to access S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "s3:*",
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.my_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.my_bucket.id}/*"
        ]
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2-sg-"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "express_server" {
  ami           = "ami-0c02fb55956c7d316" # Change to your region's AMI
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  security_groups      = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "ExpressAPI"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nodejs npm",
      "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash",
      "nvm install node",
      "git clone https://your-repo-url.git /home/ubuntu/express-app",
      "cd /home/ubuntu/express-app",
      "npm install",
      "npm start"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/your-key.pem")
    host        = self.public_ip
  }
}
