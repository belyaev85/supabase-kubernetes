{{/*
Component condition helper - automatically determines if component should be enabled based on its path
Usage: {{- if include "supabase.component.enabled" . }} ... {{- end }}
*/}}
{{- define "supabase.component.enabled" -}}
{{- $component := include "supabase.component.fromPath" . }}
{{- if index .Values $component "enabled" }}
true
{{- end }}
{{- end }}
