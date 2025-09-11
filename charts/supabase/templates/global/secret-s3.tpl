apiVersion: v1
kind: Secret
metadata:
  name: {{ include "supabase.fullname" . }}-secret-s3
  labels:
    {{- include "supabase.labels" . | nindent 4 }}
type: Opaque
data:
  username: {{ .Values.global.s3.username | b64enc }}
  password: {{ .Values.global.s3.password | b64enc }}


