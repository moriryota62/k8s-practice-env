resource "aws_security_group" "k8s-node-sg" {
  name        = "${local.base_name}-k8s-node-sg"
  description = "for k8s instances"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    {
      "Name" = "${local.base_name}-k8s-node-sg"
    },
    local.tags
  )

}

resource "aws_security_group_rule" "ssh" {
  count = length(local.allow_ssh_cidrs) != 0 ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s-node-sg.id
  cidr_blocks       = local.allow_ssh_cidrs
  description       = "allow ssh"
}

resource "aws_security_group_rule" "kube-api" {
  count = length(local.allow_k8s_api_cidrs) != 0 ? 1 : 0

  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s-node-sg.id
  cidr_blocks       = local.allow_k8s_api_cidrs
  description       = "allow inbound K8s API"
}

resource "aws_security_group_rule" "node-port" {
  count = length(local.allow_node_port_cidrs) != 0 ? 1 : 0

  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s-node-sg.id
  cidr_blocks       = local.allow_node_port_cidrs
  description       = "allow inbound K8s API"
}

resource "aws_security_group_rule" "self-6443" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s-node-sg.id
  self              = true
  description       = "K8s API"
}

resource "aws_security_group_rule" "self-2379-2380" {
  type              = "ingress"
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s-node-sg.id
  self              = true
  description       = "etcd server client API"
}

resource "aws_security_group_rule" "self-10250-10252" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10252
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s-node-sg.id
  self              = true
  description       = "Kubelet API,kube-scheduler,kube-controller-manager"
}

resource "aws_security_group_rule" "self-30000-32767" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s-node-sg.id
  self              = true
  description       = "node port"
}