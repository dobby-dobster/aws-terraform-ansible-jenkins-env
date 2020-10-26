#Initiate Peering connection request from master vpc
resource "aws_vpc_peering_connection" "useast1-uswest2" {
  provider    = aws.region-master
  peer_vpc_id = aws_vpc.vpc_master_worker.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.region-worker
  tags = {
    Name = "master-worker-peering"
  }

}

#Accept VPC peering request in worker vpc from master vpc
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  auto_accept               = true
  tags = {
    Name = "worker-master-peering"
  }
}
