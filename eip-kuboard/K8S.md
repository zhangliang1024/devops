# 


## 卸载K8S集群


### 1. 清理K8S集群中运行POD
```bash
kubectl delete node --all
```
### 2. 停止所有服务
```bash
kubeclt delete svc --all
```


## 强制删除POD/NS
### 1.删除POD
```bash
kubectl delete pod <podname> --force --grace-period=0
```
### 2. 删除NS
```bash
kubectl delete ns <nsname> --force --grace-period=0
```