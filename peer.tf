resource "null_resource" "peer_with_customer" {
  count = var.peer_vpc_id == "" ? 0 : 1

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = "python3 files/peer_vpc.py ${var.peer_account_id} ${var.peer_vpc_id} ${local.region} ${module.vpc.vpc_id} ${join(" ", local.private_subnets)} >> ${path.root}/peering.log"
  }
}
