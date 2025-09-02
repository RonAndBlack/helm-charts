# Git & Helm Chart 仓库

## 1.将 Helm Chart 源代码上传到 Git（如 GitHub, GitLab, Bitbucket）

- 目标： 版本控制、协作开发、CI/CD 集成、存储 Chart 的“源代码”。

- 上传的内容： Helm Chart 的原始目录结构和文件：
  - Chart.yaml(核心元数据文件)
  - values.yaml(默认配置值)
  - templates/目录 (包含 Kubernetes manifest 模板文件 .yaml, .tpl)
  - charts/目录 (包含子 Charts)
  - crds/目录 (自定义资源定义)
  - .helmignore(类似于 .gitignore)
  - 其他辅助文件 (README.md, LICENSE, test 文件等)

- 操作方式： 使用标准的 Git 命令 (git add, git commit, git push) 将 Chart 的源码目录推送到远程 Git 仓库的某个分支。

- 用途：
  - 开发： 跟踪 Chart 的更改历史、回滚到旧版本、代码审查。
  - 协作： 多个开发者共同维护和迭代 Chart。
  - CI/CD： 自动化测试 Chart（例如，使用 helm lint, helm template, ct- chart-testing 工具），自动化构建（helm package）并将打包好的 Chart 推送到 Chart 仓库（这就是第二个概念了）。
  - 文档化： README 文件记录 Chart 的使用说明。
  - 分发源码： 让其他人可以查看、修改或基于你的 Chart 进行开发。

- Helm 是否直接使用？ Helm 客户端不能直接从一个普通的 Git 仓库安装或管理 Chart。它需要的是一个标准的 Helm 仓库（见下文）。

## 2.将 Helm Chart 上传到 Helm Chart 仓库

- 目标： 分发、存储和提供版本化的、可直接部署的 Helm Chart 包，供 helm install, helm upgrade, helm pull等命令使用。

- 上传的内容： 一个或多个打包好的 Helm Chart 文件（*.tgz），以及由这些包生成的或更新的索引文件 index.yaml。
  - 打包：使用 helm package <chart-directory>命令将源码目录打包成一个 *.tgz文件（如 mychart-1.0.0.tgz）。
  - 索引：仓库需要一个 index.yaml文件，该文件列出了仓库中所有可用的 Charts、它们的版本、下载 URL 和校验和等信息。

- 操作方式：
  - 使用特定仓库工具或命令：
    - helm push命令（需要 helm cm-push插件）：专门用于将 .tgz包推送到支持 OCI 协议（如 Harbor, ECR, GAR）或 HTTP/S 协议（如 ChartMuseum）的仓库，并自动更新索引。
    - 仓库管理工具：如 chartmuseum命令行工具、Harbor UI/API、Artifactory UI/API 等。
    - 手动流程：某些简单仓库（如 GitHub Pages）可能需要手动上传 .tgz文件并手动运行 helm repo index来生成 index.yaml。

- 用途：
  - 分发： 使最终用户或系统能够通过 helm repo add <repo-name> <repo-url>添加你的仓库。
  - 版本化部署： 用户可以 helm install myrelease <repo-name>/mychart --version 1.0.0来部署 Chart 的特定版本。
  - 中心化管理： 存储组织内或公开共享的、经过审核的可部署 Charts。
  - 依赖解析： Helm 在安装依赖 Charts (requirements.yaml/ Chart.yaml中的 dependencies:部分) 时会从配置的仓库中拉取它们。

- 仓库类型： Helm Chart 仓库可以有多种形式：
  - OCI Registry： Docker 容器镜像仓库（如 Harbor, Google Artifact Registry, Amazon ECR, Azure Container Registry）扩展支持存储 Helm Charts (OCI artifacts)。
  - 专用 Chart 仓库服务器： 如 ChartMuseum, JFrog Artifactory。
  - 静态文件服务器： 通过 Web 服务器提供 index.yaml和 .tgz文件（如 AWS S3 + CloudFront, Google Cloud Storage, GitHub Pages）。
  - 云服务： 某些云提供商的原生服务。
