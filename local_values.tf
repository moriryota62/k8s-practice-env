terraform {
  required_version = ">= 0.13.5"
}

provider "aws" {
  region = "us-east-2"
}

locals {

  # common parameter
  pj        = "k8s"
  env       = "practice"
  base_name = "${local.pj}-${local.env}"
  tags = {
    pj    = local.pj
    env   = local.env
    owner = "mori"
  }

  #network
  network_create    = true # 既存のネットワークを流用する場合はfalseにする。
  vpc_cidr          = "10.0.0.0/16"
  availability_zone = "us-east-2a"
  subent_cidr       = "10.0.1.0/24"

  #ec2
  nodes         = ["master", "worker"] # リストした名前のノードを作成
  instance_type = "t3.medium"
  key_name      = "mori" # インスタンスのキーペア。あらかじめ作成が必要

  #sg
  allow_ssh_cidrs       = ["126.72.68.141/32","223.219.138.227/32"] # どこからも許可しない場合は空配列を指定する。
  allow_k8s_api_cidrs   = ["126.72.68.141/32","223.219.138.227/32"] # どこからも許可しない場合は空配列を指定する。
  allow_node_port_cidrs = ["126.72.68.141/32","223.219.138.227/32"] # どこからも許可しない場合は空配列を指定する。

  #clowdwatch
  auto_start          = false # trueにするとEC2の自動起動をスケジュール
  auto_start_schedule = "cron(06 6 ? * MON-FRI *)" # 日本時間で平日09:00の指定
  auto_stop           = false # trueにするとEC2の自動停止をスケジュール
  auto_stop_schedule  = "cron(04 6 ? * MON-FRI *)" # 日本時間で平日19:00の指定
}
