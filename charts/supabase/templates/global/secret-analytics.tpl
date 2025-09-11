apiVersion: v1
kind: Secret
metadata:
  name: {{ include "supabase.fullname" . }}-secret-analytics
  labels:
    {{- include "supabase.labels" . | nindent 4 }}
type: Opaque
data:
  publicAccessToken: {{ .Values.global.analytics.publicAccessToken | b64enc }}
  privateAccessToken: {{ .Values.global.analytics.privateAccessToken | b64enc }}
