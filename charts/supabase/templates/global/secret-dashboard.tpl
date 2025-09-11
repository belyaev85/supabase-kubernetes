apiVersion: v1
kind: Secret
metadata:
  name: {{ include "supabase.fullname" . }}-secret-dashboard
  labels:
    {{- include "supabase.labels" . | nindent 4 }}
type: Opaque
data:
  username: {{ .Values.global.dashboard.username | b64enc }}
  password: {{ .Values.global.dashboard.password | b64enc }}
  openAIKey: {{ .Values.global.dashboard.openAIKey | b64enc }}


