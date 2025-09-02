# mysqldb-mgr-istio Helm Chart 配置

## 📁 1. Chart 结构

```bash
# 生成 Chart 骨架
helm create mysqldb-mgr-istio
```

**文件目录**
mysqldb-mgr-istio/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── _helpers.tpl
│   ├── namespace.yaml
│   ├── configmap-core-config.yaml
│   ├── configmap-scripts.yaml
│   ├── configmap-init-db.yaml
│   ├── persistentvolume.yaml   <!-- PV是集群公用资源，无命名空间 -->
│   ├── secret.yaml
│   ├── service.yaml
│   ├── statefulset.yaml
│   └── tests/   <!-- 暂时不会用替换成tests.bak -->
│       └── test-connection.yaml
└── README.md

## ⚙️ 2. 核心组件配置

有状态集 (statefulset)

```yaml:/mysqldb-mgr-istio/statefulset.yaml
      # 临时配置
      # 添加亲和性配置
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100  # 高权重优先调度到 node1
            preference:
              matchExpressions:
              - key: kubernetes.io/hostname  # 使用主机名标签
                operator: In
                values:
                - node1  # 您的节点1名称
          - weight: 50   # 较低权重作为备选
            preference:
              matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - node2  # 您的节点2名称
        podAntiAffinity:
          # preferredDuringSchedulingIgnoredDuringExecution: 软策略，尽量满足
          # requiredDuringSchedulingIgnoredDuringExecution: 硬策略，必须满足
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app # 根据您Pod的实际标签来匹配
                operator: In
                values:
                - mysql
            topologyKey: kubernetes.io/hostname # 指定互斥的范围是“主机名”，即不能在同一节点
```

## 🛠️ 3. 部署与运维脚本

### 节点准备脚本 (清理/PV)

在工作节点node1、node2上准备好静态pv

```bash:clean_up.sh
#! /bin/bash

# 重置pv数据（各工作节点运行）
rm -rf /data/mysql-00
rm -rf /data/mysql-01
sudo mkdir -p /data/mysql-{00..01}
sudo chmod 777 /data/mysql-*

```

### Helm 部署/调试命令

```bash
# 使用 --dry-run标志，进行模板调试 (检查渲染内容)
helm install mysqldb ./mysqldb-mgr-istio --dry-run --debug \
  --namespace mysqldb \
  --set mysql.rootPassword="123456" \
  --set mysql.replicationPassword="Rpl_Pass" | grep image:

# 创建命名空间并关联Helm
kubectl create namespace mysqldb
kubectl label namespace mysqldb app.kubernetes.io/managed-by=Helm
kubectl annotate namespace mysqldb meta.helm.sh/release-name=mysqldb
kubectl annotate namespace mysqldb meta.helm.sh/release-namespace=mysqldb
# 安装脚本
helm install mysqldb ./mysqldb-mgr-istio \
  --namespace mysqldb \
  --set mysql.rootPassword="123456" \
  --set mysql.replicationPassword="Rpl_Pass"

# 卸载 Release
# 删除 Release（默认会删除相关资源）
helm uninstall mysqldb -n mysqldb
# 保留历史记录（便于审计）
helm uninstall mysqldb -n mysqldb --keep-history
# # 删除并保留 PVC（持久化存储数据）
# helm uninstall mysqldb -n mysqldb --cascade=orphan
```

## 📦 4. Helm 仓库管理

将 Helm Chart 上传到 Helm Chart 仓库

```bash
# 通过yum安装(CentOS 7 自带的仓库中的 Git 版本较旧。)
# 更新系统包
sudo yum update -y
# 安装 git
sudo yum install -y git
# 验证安装
git --version --short
```

```bash
# 打包 Chart（进入Chart目录）
# 进入你的Chart源码目录
cd /path/to/mysqldb-mgr-istio/
# 打包Chart。这会在当前目录生成一个 .tgz 文件
helm package . # helm package /path/to/mysqldb-mgr-istio/
# 将打包好的 .tgz 文件移动到你的仓库目录下的 charts/ 文件夹中
mv mysqldb-mgr-istio-*.tgz /root/of/your/repo/charts/

# 更新仓库索引
# 进入仓库根目录
cd /root/of/your/repo/
# 生成或更新 index.yaml 文件
# helm repo index [目录路径] --url [当前仓库的URL]
helm repo index ./charts --url https://RonAndBlack.github.io/helm-charts/charts/docs # 和index.yaml文件在同一目录

git add .
git commit -m "feat: add my-app v2.1.0"
git push origin main
```

将 Helm Chart 上传到 Helm Chart 仓库后，进入仓库的 Settings-> Pages，确认已选择 gh-pagesbranch 作为源并已保存。

## 🔧 5. Git 仓库管理

```bash
# 1. 添加仓库，请使用您验证成功的 URL
helm repo add sjy https://ronandblack.github.io/helm-charts/charts/docs # 和index.yaml文件在同一目录
# # 移除仓库
# helm repo remove sjy 
# # 列出所有已添加的仓库
# helm repo list

# 2. 更新本地仓库索引（同步最新 Chart 信息）
helm repo update

# 3. 搜索 Chart（如 MySQL）
helm search repo sjy/mysql

# 4. 安装 Chart（生成一个 Release）
# 使用 --dry-run标志，进行模板调试 (检查渲染内容)
helm install mysqldb sjy/mysqldb-mgr-istio --dry-run --debug \
  --namespace mysqldb \
  --set mysql.rootPassword="123456" \
  --set mysql.replicationPassword="Rpl_Pass" | grep image:

# 创建命名空间并关联Helm
kubectl create namespace mysqldb
kubectl label namespace mysqldb app.kubernetes.io/managed-by=Helm
kubectl annotate namespace mysqldb meta.helm.sh/release-name=mysqldb
kubectl annotate namespace mysqldb meta.helm.sh/release-namespace=mysqldb
# 安装脚本
helm install mysqldb sjy/mysqldb-mgr-istio \
  --namespace mysqldb \
  --set mysql.rootPassword="123456" \
  --set mysql.replicationPassword="Rpl_Pass"

# 卸载 Release
# 删除 Release（默认会删除相关资源）
helm uninstall mysqldb -n mysqldb
```
