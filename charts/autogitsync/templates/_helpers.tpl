{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name for autogitsync autogitsync objects
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "autogitsync.autogitsync.fullname" -}}
    {{- include "common.names.fullname" . -}}
{{- end -}}

{{/*
Create the default FQDN for autogitsync autogitsync headless service
We truncate at 63 chars because of the DNS naming spec.
*/}}
{{- define "autogitsync.autogitsync.svc.headless" -}}
{{- printf "%s-hl" (include "autogitsync.autogitsync.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper autogitsync image name
*/}}
{{- define "autogitsync.image" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end -}}

{{/*
Return the proper autogitsync metrics image name
*/}}
{{- define "autogitsync.metrics.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "autogitsync.volumePermissions.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "autogitsync.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.metrics.image .Values.volumePermissions.image) "global" .Values.global) }}
{{- end -}}

{{/*
Get the password secret.
*/}}
{{- define "autogitsync.secretName" -}}
{{- if .Values.autogitsync.existingSecret -}}
    {{- printf "%s" (tpl .Values.autogitsync.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-cfg-autogitsync" (include "autogitsync.autogitsync.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created
*/}}
{{- define "autogitsync.createSecret" -}}
{{- if not (.Values.autogitsync.existingSecret) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return autogitsync service port
*/}}
{{- define "autogitsync.service.port" -}}
    {{ .Values.autogitsync.service.ports.autogitsync }}
{{- end -}}

{{/*
Get the autogitsync autogitsync configuration ConfigMap name.
*/}}
{{- define "autogitsync.autogitsync.configmapName" -}}
{{- if .Values.autogitsync.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.autogitsync.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s-cfg" (include "autogitsync.autogitsync.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the autogitsync autogitsyncknight configuration ConfigMap name.
*/}}
{{- define "autogitsync.autogitsyncknight.configmapName" -}}
{{- if .Values.autogitsyncknight.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.autogitsyncknight.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s-cfg-autogitsyncknight" (include "autogitsync.autogitsync.fullname" .) -}}
{{- end -}}
{{- end -}}


{{/*
 Create the name of the service account to use
 */}}
{{- define "autogitsync.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Get the readiness probe command
*/}}
{{- define "autogitsync.readinessProbeCommand" -}}
- |
  exec echo "Hello"
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "autogitsync.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "autogitsync.validateValues.psp" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate values of autogitsync - If PSP is enabled RBAC should be enabled too
*/}}
{{- define "autogitsync.validateValues.psp" -}}
{{- if and .Values.psp.create (not .Values.rbac.create) }}
autogitsync: psp.create, rbac.create
    RBAC should be enabled if PSP is enabled in order for PSP to work.
    More info at https://kubernetes.io/docs/concepts/policy/pod-security-policy/#authorizing-policies
{{- end -}}
{{- end -}}
