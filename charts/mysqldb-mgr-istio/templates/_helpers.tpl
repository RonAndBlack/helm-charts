{{/*
这是一个 Helm Chart 模板文件（通常命名为 _helpers.tpl），它定义了一系列可重用的命名模板（named templates），用于在 Helm Chart 中生成一致的名称和标签。这些模板遵循 Kubernetes 和 Helm 的最佳实践，确保资源名称和标签符合规范（如长度限制）。
*/}}
{{- define "mysqldb-mgr-istio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
创建一个默认的、完全限定的应用名称。
我们将名称截断至 63 个字符，因为某些 Kubernetes 名称字段受此限制（遵循 DNS 命名规范）。
如果 Release 名称包含了 Chart 名称，它将被用作完整名称。
*/}}
{{- define "mysqldb-mgr-istio.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
创建由 Chart 标签使用的 Chart 名称和版本。
*/}}
{{- define "mysqldb-mgr-istio.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
通用标签。
*/}}
{{- define "mysqldb-mgr-istio.labels" -}}
helm.sh/chart: {{ include "mysqldb-mgr-istio.chart" . }}
{{ include "mysqldb-mgr-istio.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
选择器标签。
*/}}
{{- define "mysqldb-mgr-istio.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mysqldb-mgr-istio.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
创建要使用的服务账户名称。
*/}}
{{- define "mysqldb-mgr-istio.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mysqldb-mgr-istio.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
