# Kuboard安装

## 一、环境要求

```shell
hostnamectl set-hostname china-zh-04
hostnamectl status
echo "127.0.0.1   $(hostname)" >> /etc/hosts
cat /etc/hosts

```



## 二、基础安装


```shell
export REGISTRY_MIRROR=https://registry.cn-hangzhou.aliyuncs.com
curl -sSL https://kuboard.cn/install-script/v1.21.x/install_kubelet.sh | sh -s 1.21.5

containerd --version
kubelet --version
```


## 三、Master安装


```shell
export MASTER_IP=10.140.21.37
export APISERVER_NAME=apiserver.master
echo "${MASTER_IP}    ${APISERVER_NAME}" >> /etc/hosts

export POD_SUBNET=10.100.0.0/16
curl -sSL https://kuboard.cn/install-script/v1.21.x/init_master.sh | sh -s 1.21.5
```
- 日志输出如下，说明安装成功


```shell
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join apiserver.master:6443 --token o8qmsw.1d26myujk4n5l6dm \
        --discovery-token-ca-cert-hash sha256:6722832c05b29a74612c816dc1d66ba7be215df55b51898812cf8bbfbdd8c3bf \
        --control-plane --certificate-key 1b2143266920aab9daa1ddc3636f97d6a607c76b17d078fcd3d16abf7b9e0924

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join apiserver.master:6443 --token o8qmsw.1d26myujk4n5l6dm \
        --discovery-token-ca-cert-hash sha256:6722832c05b29a74612c816dc1d66ba7be215df55b51898812cf8bbfbdd8c3bf
[root@china-zh-02 ~]#
```

## 四、Node安装
```shell
export MASTER_IP=10.140.21.37
export APISERVER_NAME=apiserver.master
echo "${MASTER_IP}  ${APISERVER_NAME}" >> /etc/hosts

```


## 五、Kuboard安装
```bash
docker stop kuboard && docker rm kuboard

sudo docker run -d \
  --restart=unless-stopped \
  --name=kuboard \
  -p 80:80/tcp \
  -p 10081:10081/tcp \
  -e KUBOARD_ENDPOINT="http://10.140.xxx.8:80" \
  -e KUBOARD_AGENT_SERVER_TCP_PORT="10081" \
  -v /root/kuboard-data:/data \
  eipwork/kuboard:v3
```


## 六、部署eureka
> - http://eureka-0.eureka.ocp.svc.cluster.local:1111/eureka
> - 说明
>   - eureka-0: 部署pod服务名称eureka+$(Pod 序号)
>   - eurka : Service服务名称$(service name)
>   - ocp: 部署名称空间
>   - svc.cluster.local: 集群的域
>   - 1111: 服务端口
>   - eureka: 固定接口路径
```bash
http://eureka-0.eureka.ocp.svc.cluster.local:1111/eureka,http://eureka-1.eureka.ocp.svc.cluster.local:1111/eureka,http://eureka-2.eureka.ocp.svc.cluster.local:1111/eureka
```