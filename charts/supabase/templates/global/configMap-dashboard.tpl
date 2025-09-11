apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "supabase.fullname" . }}-config-dashboard
  labels:
    {{- include "supabase.labels" . | nindent 4 }}
data:
  supabaseUrl: {{ .Values.global.dashboard.supabaseUrl}}
