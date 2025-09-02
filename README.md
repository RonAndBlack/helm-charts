# Helm Chart 配置

## 📁 1. Chart 结构

```bash
# 生成 Chart 骨架
helm create xxxxxx-xx
```

**文件目录**：

```text
xxxxxx-xx/
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
```

## ⚙️ 2. 核心组件配置

某某某 (******)

```yaml:/xxxxxx-xx/******.yaml
```

## 🛠️ 3. 部署与运维脚本

### 节点准备脚本 (清理/PV)

```bash
```

### Helm 部署/调试命令

```bash
# 使用 --dry-run标志，进行模板调试 (检查渲染内容)
helm install xxxxxx ./xxxxxx-xx --dry-run --debug \
  --namespace xxxxxx \
  --set xxx.xxx="xxx" \
  --set xxx.xxx="xxx" | grep image:

# 创建命名空间并关联Helm
kubectl create namespace xxxxxx
kubectl label namespace xxxxxx app.kubernetes.io/managed-by=Helm
kubectl annotate namespace xxxxxx meta.helm.sh/release-name=xxxxxx
kubectl annotate namespace xxxxxx meta.helm.sh/release-namespace=xxxxxx
# 安装Chart
helm install xxxxxx ./xxxxxx-xx \
  --namespace xxxxxx \
  --set xxx.xxx="xxx" \
  --set xxx.xxx="xxx"

# 卸载 Release
# 删除 Release（默认会删除相关资源）
helm uninstall xxxxxx -n xxxxxx
# 保留历史记录（便于审计）
helm uninstall xxxxxx -n xxxxxx --keep-history
# # 删除并保留 PVC（持久化存储数据）  # 实测没用，会一同删除命名空间和所有资源
# # 先解除命名空间与 Helm 的关联
# kubectl label namespace xxxxxx app.kubernetes.io/managed-by-
# kubectl annotate namespace xxxxxx meta.helm.sh/release-name-
# kubectl annotate namespace xxxxxx meta.helm.sh/release-namespace-
# # 再卸载 Release (保留PVC)
# helm uninstall xxxxxx -n xxxxxx --cascade=orphan
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
cd /path/to/xxxxxx-xx/
# 打包Chart。这会在当前目录生成一个 .tgz 文件
helm package . # helm package /path/to/xxxxxx-xx/
# 将打包好的 .tgz 文件移动到你的仓库目录下的 charts/ 文件夹中
mv xxxxxx-xx-*.tgz /root/of/your/repo/charts/

# 更新仓库索引
# 进入仓库根目录
cd /root/of/your/repo/
# 生成或更新 index.yaml 文件
# helm repo index [目录路径] --url [当前仓库的URL]
helm repo index ./charts --url https://RonAndBlack.github.io/helm-charts/charts/docs

# 提交到GitHub仓库
git add ./charts/xxxxxx-xx-*.tgz ./charts/index.yaml
git commit -m "feat: add my-app v2.1.0"
git push origin master
```

<!-- ```bash
# 配置git
# 设置全局用户名（请替换为你自己的名字）
git config --global user.name "JUNYE SUN"
# 设置全局邮箱（请替换为你自己的邮箱）
git config --global user.email "1350087353@qq.com"
# 检查所有配置项，确认信息是否正确
git config --list

# 初始化仓库
git init
``` -->

## 🔧 5. Git 仓库管理

将 Helm Chart 源代码上传到 Git

### Git 常用工作流

**初始化与基础操作**：

```bash
# 创建与克隆仓库
git init   # 初始化本地仓库（创建.git文件夹）
# git clone https://github.com/xxx.git # 克隆远程仓库到本地

# 提交和修改
# git status                     # 查看文件状态（红=未跟踪/修改，绿=已暂存）
# git add filename               # 将文件添加到暂存区
git add .                      # 添加所有修改到暂存区
git commit -m "注释"           # 提交并注释
# git commit -am "注释"          # 跳过add直接提交已跟踪文件的修改
```

**分支管理**：

```bash
# git branch                     # 查看本地分支
git branch -M master           # 强制重命名当前分支为 master，同时覆盖任何已存在的 master分支。
# git branch dev                 # 创建新分支dev
# git checkout dev               # 切换到dev分支
# git checkout -b feature-branch # 创建并切换分支
# git switch dev                 # (推荐) 同上，新版本Git更安全
# git branch -d dev              # 删除分支（安全）
# git branch -D dev              # 强制删除分支（未合并也删除）
# git merge dev                  # 将dev分支合并到当前分支
# 清空源代码历史记录
# git update-ref -d HEAD         # 删除当前分支引用
# git reset                      # 重置暂存区（保留工作区修改）
```

**远程仓库操作**：

```bash
# git remote -v                  # 查看已关联的远程仓库
git remote add origin https://github.com/RonAndBlack/helm-charts.git # 添加远程仓库：这是将本地 Git 仓库关联到远程仓库的命令
  # git remote add: 添加一个新的远程仓库地址。
  # origin: 远程仓库的默认别名（可自定义）。
  # <https://github.com/...>: 远程仓库的 HTTPS URL。
git push -u origin master      # 首次推送并关联分支（-u=设置上游）
# git push origin dev            # 推送dev分支到远程
# git pull origin main           # 拉取远程main分支的更新
# git fetch origin               # 只下载远程变更不自动合并

# git branch -r或 git ls-remote --heads # 查看远程分支
# git fetch --prune                     # 同步远程分支状态（清理缓存）
# git branch -dr origin/<分支名>        # 清理本地追踪分支
# git push origin --delete <分支名>     # 删除远程分支
```

```bash
# 撤销与回退
# git restore filename           # 丢弃工作区修改 （未add）
# git restore --staged filename  # 将文件移出暂存区 （已add但未commit）
# git reset --soft HEAD^         # 撤销提交但保留更改（软重置） （撤销上一次提交，但保留所有更改在暂存区）
# git reset --hard HEAD^         # 撤销提交并丢弃更改（硬重置） （丢弃提交和修改）
# git revert <commit-id>         # 创建一个新的提交来撤销之前的更改 （安全回退）

# 日志与对比
# git log                        # 查看提交历史 （commit_id）
# git log --oneline --graph      # 简洁图形化日志
# git diff                       # 查看未暂存的修改
# git diff --cached              # 查看已暂存的修改

# 标签管理
# git tag v1.0                   # 创建轻量标签
# git tag -a v2.0 -m "正式版"    # 创建附注标签（含描述）
# git push origin v1.0           # 推送标签到远程

# 实用技巧
# git stash                      # 临时保存工作区修改（不提交）
# git stash pop                  # 恢复最近一次暂存的修改
# .gitignore                     # 在项目根目录创建此文件可忽略指定文件/文件夹
```

#### 常用工作流示例

```bash
git clone https://xxx.git       # 克隆远程仓库
git checkout -b feature         # 创建并切换到新分支
git add .                       # 添加修改
git commit -m "add feature"     # 提交修改
git push origin feature         # 推送分支到远程
# 在GitHub发起Pull Request合并到main分支
```

### 清空仓库记录的特殊场景

#### 🗑 清空本地历史 (保留文件，只删历史)

```bash
# 1. 重置到空提交状态（相当于撤销第一次提交但保留所有改动）
git update-ref -d HEAD # 此方法只对根提交有效

# 2. 验证状态（应显示所有文件在暂存区等待提交）
git status
```

```bash
cp -r my-repo/ my-repo-backup/  # 1. 备份现有文件（可选）
cd my-repo                      # 2. 进入仓库目录
rm -rf .git                     # 3. 删除 Git 记录（核心操作）
git init                        # 4. 重新初始化
git add .
git remote add origin https://github.com/RonAndBlack/helm-charts.git # 添加远程仓库：这是将本地 Git 仓库关联到远程仓库的命令
# git commit -m "全新开始"
git commit -f "全新开始"        # 覆盖
```

#### 🌌 清空远程历史 (保留仓库地址)

有点问题，实测无法清空。

```bash
# 创建空白分支替代主分支
git checkout --orphan temp_branch
# git add .
git commit -m "初始空白提交" --allow-empty
# git branch -D master            # 删除原分支（如 main/master）
git branch -m master            # 重命名分支
git push -f origin master       # 强制覆盖远程

# 清理历史（可选）
git reflog expire --expire=now --all
git gc --prune=now
```

#### 💥 彻底删除 GitHub 仓库

```bash
# 1. 删除本地关联
git remote remove origin

# 2. 网页端操作（以 GitHub 为例）：
#    - 进入仓库页面
#    - Settings > Danger Zone > Delete this repository
#    - 输入仓库名确认删除

# 3. 重建空仓库
#    - 在 GitHub 新建同名空仓库
#    - 重新关联：
git remote add origin https://github.com/user/repo.git
git push -u origin main
```

#### 🧹 附加清理技巧

1.清除历史提交记录

```bash
git update-ref -d HEAD  # 删最新提交
git reset --hard HEAD~3 # 回退3个提交
```

2.清理跟踪记录

```bash
git rm -r --cached .    # 取消所有跟踪
git add .               # 重新建立索引
```

**⚠ 重要警告**
1.git push -f会覆盖远程历史，操作前需确认：

- 确保有仓库管理员权限
- 通知所有协作者重新克隆

2.清空后历史提交将不可恢复，建议提前：

```bash
git bundle create backup.bundle --all  # 完整备份
```

3.超过 100MB 的大文件需额外清理：

```bash
git filter-branch --force --index-filter \
"git rm -rf --cached --ignore-unmatch BIGFILE" \
--prune-empty --tag-name-filter cat -- --all
```
