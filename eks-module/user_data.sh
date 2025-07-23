#!/bin/bash
set -o xtrace

# Install required packages
yum install -y amazon-efs-utils

# Install Docker
yum install -y docker
systemctl enable docker
systemctl start docker

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Create kubelet config
mkdir -p /etc/eks
cat > /etc/eks/kubelet-config.json <<EOF
{
  "kind": "KubeletConfiguration",
  "apiVersion": "kubelet.config.k8s.io/v1beta1",
  "authentication": {
    "anonymous": {
      "enabled": false
    },
    "webhook": {
      "cacheTTL": "2m0s",
      "enabled": true
    },
    "x509": {
      "clientCAFile": "/etc/kubernetes/pki/ca.crt"
    }
  },
  "authorization": {
    "mode": "Webhook",
    "webhook": {
      "cacheAuthorizedTTL": "5m0s",
      "cacheUnauthorizedTTL": "30s"
    }
  },
  "clusterDomain": "cluster.local",
  "clusterDNS": [
    "10.100.0.10"
  ],
  "cgroupDriver": "cgroupfs",
  "containerRuntime": "docker",
  "containerRuntimeEndpoint": "unix:///var/run/docker.sock",
  "cpuCFSQuota": true,
  "cpuCFSQuotaPeriod": "100us",
  "cpuManagerPolicy": "none",
  "failSwapOn": false,
  "fileCheckFrequency": "20s",
  "hairpinMode": "hairpin-veth",
  "httpCheckFrequency": "20s",
  "imageGCHighThresholdPercent": 85,
  "imageGCLowThresholdPercent": 80,
  "imageMinimumGCAge": "2m0s",
  "kubeAPIBurst": 10,
  "kubeAPIQPS": 5,
  "maxOpenFiles": 1000000,
  "maxPods": 110,
  "nodeStatusUpdateFrequency": "10s",
  "oomScoreAdj": -999,
  "podPidsLimit": -1,
  "registryBurst": 10,
  "registryPullQPS": 5,
  "resolvConf": "/etc/resolv.conf",
  "rotateCertificates": true,
  "runtimeRequestTimeout": "15m",
  "serializeImagePulls": false,
  "serverTLSBootstrap": true,
  "streamingConnectionIdleTimeout": "4h",
  "syncFrequency": "1m0s",
  "volumeStatsAggPeriod": "1m0s"
}
EOF

# Create kubelet service
cat > /etc/systemd/system/kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet \\
  --config=/etc/eks/kubelet-config.json \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --container-runtime=docker \\
  --network-plugin=cni \\
  --node-ip=\$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) \\
  --node-labels=node.kubernetes.io/instance-type=\$(curl -s http://169.254.169.254/latest/meta-data/instance-type) \\
  --register-with-taints=node.kubernetes.io/not-ready:NoSchedule \\
  --pod-infra-container-image=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.5 \\
  --v=2
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Create kubeconfig
mkdir -p /var/lib/kubelet
cat > /var/lib/kubelet/kubeconfig <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${cluster_certificate_authority}
    server: ${cluster_endpoint}
  name: ${cluster_name}
contexts:
- context:
    cluster: ${cluster_name}
    user: kubelet
  name: kubelet
current-context: kubelet
users:
- name: kubelet
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - eks
        - get-token
        - --cluster-name
        - ${cluster_name}
        - --region
        - us-east-1
EOF

# Start kubelet
systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet

# Install CNI
yum install -y amazon-vpc-cni-k8s
systemctl enable amazon-vpc-cni-k8s
systemctl start amazon-vpc-cni-k8s 