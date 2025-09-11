{{- define "supabase.base.service" -}}
{{- $ctx := index . "ctx" -}}
{{- $comp := index . "component" -}}
{{- $vals := index $ctx.Values $comp | default dict -}}
{{- $svc := index $vals "service" | default dict -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "supabase.component.fullname" (dict "ctx" $ctx "component" $comp) }}
  labels:
    {{- include "supabase.component.labels" (dict "ctx" $ctx "component" $comp) | nindent 4 }}
spec:
  type: {{ default "ClusterIP" $svc.type }}
  {{- if $svc.port }}
  ports:
    {{- if kindIs "slice" $svc.port }}
      {{- range $svc.port }}
    - name: {{ printf "port-%v" . }}
      port: {{ . }}
      targetPort: {{ . }}
      protocol: TCP
      {{- end }}
    {{- else }}
    - name: {{ printf "port-%v" $svc.port }}
      port: {{ $svc.port }}
      targetPort: {{ $svc.port }}
      protocol: TCP
    {{- end }}
  {{ end -}}
  selector:
    {{- include "supabase.component.selectorLabels" (dict "ctx" $ctx "component" $comp) | nindent 4 }}
{{- end }}
