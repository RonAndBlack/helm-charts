# Helm Charts

**目录**：

```text
gh-pages 分支根目录/
└── charts/
    └── docs/
        ├── charts/
        │   └── mysqldb-mgr-0.1.0.tgz
        ├── index.yaml
        └── README.md
```

1.将每个chart目录放在同一个父目录下（比如charts/），或者分散在仓库的不同位置。
2.使用helm package打包每个chart，并输出到同一个目录（比如docs/）。
3.然后在这个docs/目录下运行helm repo index命令，它会扫描目录下所有的.tgz文件并生成或更新index.yaml。

将 Helm Chart 上传到 Helm Chart 仓库后，进入仓库的 Settings-> Pages，确认已选择 gh-pagesbranch 作为源并已保存。

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
helm install mysqldb sjy/mysqldb-mgr --dry-run --debug \
  --namespace mysqldb \
  --set mysql.rootPassword="123456" \
  --set mysql.replicationPassword="Rpl_Pass" | grep image:

# 创建命名空间并关联Helm
kubectl create namespace mysqldb
kubectl label namespace mysqldb app.kubernetes.io/managed-by=Helm
kubectl annotate namespace mysqldb meta.helm.sh/release-name=mysqldb
kubectl annotate namespace mysqldb meta.helm.sh/release-namespace=mysqldb
# 安装脚本
helm install mysqldb sjy/mysqldb-mgr \
  --namespace mysqldb \
  --set mysql.rootPassword="123456" \
  --set mysql.replicationPassword="Rpl_Pass"

# 卸载 Release
# 删除 Release（默认会删除相关资源）
helm uninstall mysqldb -n mysqldb
```
