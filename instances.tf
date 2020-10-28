
#Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region-master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Get Linux AMI ID using SSM Parameter endpoint in us-west-2
data "aws_ssm_parameter" "linuxAmiWorker" {
  provider = aws.region-worker
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "master-key" {
  provider   = aws.region-master
  key_name   = "jenkins"
  public_key = file("/var/tmp/aws_id_rsa.pub")
}

#Create key-pair for logging into EC2 in us-west-2
resource "aws_key_pair" "worker-key" {
  provider   = aws.region-worker
  key_name   = "jenkins"
  public_key = file("/var/tmp/aws_id_rsa.pub")
}

#Create and bootstrap EC2 in us-east-1
resource "aws_instance" "jenkins-master" {
  provider                    = aws.region-master
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ansible_templates/inventory"
  }
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ansible_templates/inventory
${self.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=/var/tmp/aws_id_rsa
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-master} --instance-ids ${self.id} && ansible-playbook -i ansible_templates/inventory ansible_templates/jenkins-master.yml"
  }
  tags = {
    Name = "jenkins-master"
  }
}

#Create EC2 in us-west-2
resource "aws_instance" "jenkins-worker" {
  provider                    = aws.region-worker
  count                       = var.workers-count
  ami                         = data.aws_ssm_parameter.linuxAmiWorker.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.worker-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg-worker.id]
  subnet_id                   = aws_subnet.subnet_1_worker.id
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ansible_templates/inventory_worker
${self.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=/var/tmp/aws_id_rsa
EOF
EOD
  }
  provisioner "local-exec" {
    when = destroy
    command = "sed -i '/${self.public_ip}/d' ansible_templates/inventory_worker &> /dev/null || echo"
  }
  provisioner "local-exec" {
    command = "aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-worker} --instance-ids ${self.id} && ansible-playbook --extra-vars 'master_ip=${aws_instance.jenkins-master.private_ip} worker_priv_ip=${self.private_ip}' -i ansible_templates/inventory_worker -l ${self.public_ip} ansible_templates/jenkins-worker.yml"
  }
  tags = {
    Name = join("-", ["jenkins-worker", count.index + 1])
  }
}
