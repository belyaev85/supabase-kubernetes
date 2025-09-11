apiVersion: v1
kind: Secret
metadata:
  name: {{ include "supabase.fullname" . }}-secret-db
  labels:
    {{- include "supabase.labels" . | nindent 4 }}
type: Opaque
data:
  username: {{ .Values.global.db.username | b64enc }}
  password: {{ .Values.global.db.password | b64enc }}


