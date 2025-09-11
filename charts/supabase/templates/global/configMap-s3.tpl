apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "supabase.fullname" . }}-config-s3
  labels:
    {{- include "supabase.labels" . | nindent 4 }}
data:
  URL: {{ .Values.global.s3.URL }}
