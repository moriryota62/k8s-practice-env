locals {
  default_init_script_previous = <<SHELLSCRIPT
#!/bin/bash
apt update
apt-get remove docker docker-engine docker.io containerd runc

## install Docker
curl -sSL https://get.docker.com/ | sh

## start docker
# systemctl daemon-reload
systemctl enable docker
systemctl restart docker

## install ssm agent
# ubuntu has already installed ssm agent

## k8s Premise
# cat <<EOF > /etc/sysctl.d/k8s.conf
# net.bridge.bridge-nf-call-ip6tables = 1
# net.bridge.bridge-nf-call-iptables = 1
# EOF
# sysctl --system

apt-get install -y iptables arptables ebtables
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
update-alternatives --set arptables /usr/sbin/arptables-legacy
update-alternatives --set ebtables /usr/sbin/ebtables-legacy

## install k8s tools
apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

## kubeadm
## hint: https://docs.projectcalico.org/getting-started/kubernetes/quickstart
# sudo kubeadm init --pod-network-cidr=192.168.0.0/16
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
# kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
# kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml

SHELLSCRIPT
}

resource "aws_instance" "k8s_nodes" {
  for_each = toset(local.nodes)

  ami                         = data.aws_ami.ubuntu-2004.image_id
  instance_type               = local.instance_type
  iam_instance_profile        = aws_iam_instance_profile.k8snode.name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.pub-sub.id
  vpc_security_group_ids      = [aws_security_group.k8s-node-sg.id]
  user_data_base64            = base64encode(local.default_init_script_previous)
  key_name                    = local.key_name

  tags = merge(
    {
      "Name" = "${local.base_name}-${each.value}"
    },
    local.tags
  )

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}
