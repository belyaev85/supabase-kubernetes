apiVersion: v1
kind: Secret
metadata:
  name: {{ include "supabase.fullname" . }}-secret-jwt
  labels:
    {{- include "supabase.labels" . | nindent 4 }}
type: Opaque
data:
  secret: {{ .Values.global.jwt.secret | b64enc | quote }}
  anon: {{ .Values.global.jwt.anon | b64enc | quote }}
  service: {{ .Values.global.jwt.service | b64enc | quote }}


