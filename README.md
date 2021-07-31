# 概要

K8s検証用の環境を構築するTerraformです。大まかに以下のものを作成します。

- VPC
- subnet(public)
- EC2
- SG
- Cloudwatch Events

値は`local_values.tf`で指定してください。指定する値についての説明は`local_values.tf`のコメントに書いています。

# 使い方

- terraformコマンドを端末にインストールします。

- 端末でAWS CLIが使える様に設定します。

- 本レポジトリをgit clone等で作業端末にコピーします。

- `local_values.tf`を修正します。

- 以下コマンドを実行します。

``` sh
terraform init
terraform plan
terraform apply
```

# 注意

- EC2に設定するKeyペアはあらかじめ作成してください。
- OSはubuntuを想定しています。最新のubuntu AMI IDを取得して構築します。
- EC2立ち上げからDocker、SSMエージェント、K8sコンポーネントのインストールが完了するまで少し時間がかかります。（5分くらい）
- EC2にはSSMエージェントを入れるため、SSM経由でEC2に接続することも可能です。

# Kubeadmの実行

calicoをつかったクラスタを組むには以下手順を実施します。[ネタ元](https://docs.projectcalico.org/getting-started/kubernetes/quickstart)

``` sh
# master
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml

# worker
kubeadm join <master ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>

# master
kubectl get node
```
