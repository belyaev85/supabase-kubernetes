{{- define "supabase.base.serviceaccount" -}}
{{- $ctx := index . "ctx" -}}
{{- $comp := index . "component" -}}
{{- $vals := index $ctx.Values $comp | default dict -}}
{{- $serviceAccount := index $vals "serviceAccount" | default dict -}}
{{- if $serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "supabase.component.serviceAccountName" (dict "ctx" $ctx "component" $comp) }}
  labels:
    {{- include "supabase.component.labels" (dict "ctx" $ctx "component" $comp) | nindent 4 }}
  {{- with $serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
