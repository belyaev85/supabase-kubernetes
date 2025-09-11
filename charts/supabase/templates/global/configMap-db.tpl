apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "supabase.fullname" . }}-config-db
  labels:
    {{- include "supabase.labels" . | nindent 4 }}
data:
  {{- $dbsvc := include "supabase.component.fullname" (dict "ctx" . "component" "db") }}
  host: {{ default $dbsvc .Values.global.db.host }}
  port: {{ default "5432" .Values.global.db.port | quote }}
  database: {{ default "postgres" .Values.global.db.database}}
