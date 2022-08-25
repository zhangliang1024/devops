

# 查看资源
kubectl get pods -n eip-base -o wide --show-labels

# 扩缩容
kubectl scale --replicas=3 -f nginx-deployment.yaml

# 进入容器
kubectl exec -it nginx-6cfd85b64c-nrzdk -n eip-base /bin/bash


# 说明
```yaml
# nginx-service.yaml
apiVersion: v1 # 资源版本
kind: Service  # 资源类型
metadata:      # 元数据
  namespace: eip-base # 命名空间
  name: nginx  # 资源名称
  labels:
    app: nginx
spec: # 描述
  selector: # 标签选择器，用于确定当前service代理哪些pod
    app: nginx
  type: NodePort  # Service类型，指定service的访问方式
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

---
### 参考文档
[K8s 安装apollo](https://www.jianshu.com/p/9c0dd2e71336)
[k8s部署apollo配置中心](https://www.jianshu.com/p/33d50f934407)
[基于Helm部署到K8S](https://www.jianshu.com/p/e9dad5c535dc)
[]()