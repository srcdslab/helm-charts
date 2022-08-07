{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name for srcds srcds objects
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "srcds.srcds.fullname" -}}
    {{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create the default FQDN for srcds srcds headless service
We truncate at 63 chars because of the DNS naming spec.
*/}}
{{- define "srcds.srcds.svc.headless" -}}
{{- printf "%s-hl" (include "srcds.srcds.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper srcds image name
*/}}
{{- define "srcds.image" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end -}}

{{/*
Return the proper srcds metrics image name
*/}}
{{- define "srcds.metrics.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "srcds.volumePermissions.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "srcds.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.metrics.image .Values.volumePermissions.image) "global" .Values.global) }}
{{- end -}}

{{/*
Get the password secret.
*/}}
{{- define "srcds.secretName" -}}
{{- if .Values.srcds.existingSecret -}}
    {{- printf "%s" (tpl .Values.srcds.existingSecret $) -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created
*/}}
{{- define "srcds.createSecret" -}}
{{- if not (.Values.srcds.existingSecret) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return srcds service port
*/}}
{{- define "srcds.service.port" -}}
    {{ .Values.srcds.service.ports.srcds }}
{{- end -}}

{{/*
Get the srcds srcds configuration ConfigMap name.
*/}}
{{- define "srcds.srcds.configmapName" -}}
{{- if .Values.srcds.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.srcds.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s-configuration" (include "srcds.srcds.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "srcds.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Get the readiness probe command
*/}}
{{- define "srcds.readinessProbeCommand" -}}
- |
  exec echo "Hello"
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "srcds.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "srcds.validateValues.psp" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate values of srcds - If PSP is enabled RBAC should be enabled too
*/}}
{{- define "srcds.validateValues.psp" -}}
{{- if and .Values.psp.create (not .Values.rbac.create) }}
srcds: psp.create, rbac.create
    RBAC should be enabled if PSP is enabled in order for PSP to work.
    More info at https://kubernetes.io/docs/concepts/policy/pod-security-policy/#authorizing-policies
{{- end -}}
{{- end -}}
