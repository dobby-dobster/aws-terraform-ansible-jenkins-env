resource "aws_iam_instance_profile" "jenkins_profile" {
  name     = "jenkins_ec2_iam_profile"
  provider = aws.region-master
  role     = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name     = "jenkins_ec_role"
  provider = aws.region-master
  path     = "/"
  tags = {
    Name      = "jenkins_ec_role"
    CreatedBy = "terraform"
  }

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "policy" {
  name     = "jenkins_policy"
  provider = aws.region-master
  role     = aws_iam_role.role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
