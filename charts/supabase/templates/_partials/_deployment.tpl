{{- define "supabase.base.deployment" -}}
{{- $ctx := index . "ctx" -}}
{{- $comp := index . "component" -}}
{{- $vals := index $ctx.Values $comp | default dict -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  {{- $fullname := include "supabase.component.fullname" (dict "ctx" $ctx "component" $comp) }}
  name: {{ $fullname }}
  labels:
    {{- include "supabase.component.labels" (dict "ctx" $ctx "component" $comp) | nindent 4 }}
spec:
  {{- if and $vals.autoscaling (not $vals.autoscaling.enabled) }}
  replicas: {{ $vals.replicaCount }}
  {{- else if not $vals.autoscaling }}
  replicas: {{ $vals.replicaCount }}
  {{- else if $vals.autoscaling.enabled }}
  {{- else }}
  replicas: {{ $vals.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "supabase.component.selectorLabels" (dict "ctx" $ctx "component" $comp) | nindent 6 }}
  template:
    metadata:
      {{- with $vals.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "supabase.component.labels" (dict "ctx" $ctx "component" $comp) | nindent 8 }}
        {{- with $vals.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with $vals.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "supabase.component.serviceAccountName" (dict "ctx" $ctx "component" $comp) }}
      {{- with $vals.podSecurityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ $fullname }}
          {{- with $vals.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if $vals.image }}
          image: "{{ $vals.image.repository }}:{{ $vals.image.tag | default "latest" }}"
          imagePullPolicy: {{ $vals.image.pullPolicy }}
          {{- end }}
          ports:
            {{- if $vals.service }}
              {{- if $vals.service.port }}
                {{- if kindIs "slice" $vals.service.port }}
                  {{- range $vals.service.port }}
            - containerPort: {{ . }}
              protocol: {{ default "TCP" }}
                  {{- end }}
                {{- else }}
            - containerPort: {{ $vals.service.port }}
              protocol: {{ default "TCP" }}
                {{- end }}
              {{- end }}
            {{- end }}
          {{- if $vals.command }}
          command: {{- toYaml $vals.command | nindent 12 }}
          {{- end }}
          {{- if $vals.args }}
          args: {{- toYaml $vals.args | nindent 12 }}
          {{- end }}
          {{- with $vals.livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $vals.readinessProbe }}
          readinessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $vals.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $vals.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if $vals.environment }}
          env:
              {{- range $vals.environment }}
              - name: {{ .name -}}

              {{- if eq .type "value"}}
                {{- if kindIs "bool" .value }}
                value: {{ .value | toString | quote }}
                {{- else }}
                value: {{ .value | quote }}
                {{- end -}}
              {{ end -}}

              {{- if eq .type "secret"}}
                valueFrom:
                  secretKeyRef:
                    {{- $supabaseFullname := print (include "supabase.fullname" $ctx) }}
                    name: {{ print $supabaseFullname "-" .secretName }}
                    key: {{ .secretKey }}
              {{- end }}

              {{- if eq .type "configMap"}}
                valueFrom:
                  configMapKeyRef:
                    {{- $supabaseFullname := print (include "supabase.fullname" $ctx) }}
                    name: {{ print $supabaseFullname "-" .configMapName }}
                    key: {{ .configMapKey }}
              {{- end }}

              {{- if eq .type "DBUri" }}
              {{- $protocol := "postgres" }}
              {{- $user := .user }}
              {{- $password := $ctx.Values.global.db.password }}
              {{- $host := default (include "supabase.component.fullname" (dict "ctx" $ctx "component" "db")) $ctx.Values.global.db.host }}
              {{- $port := int $ctx.Values.global.db.port }}
              {{- $database := $ctx.Values.global.db.database }}
                value: {{ print $protocol "://" $user ":" $password "@" $host ":" $port "/" $database }}
              {{ end -}}

              {{- if eq .type "svcURL" }}
              {{- $comp := .component }}
              {{- $protocol := default "http" .protocol }}
              {{- $svc := include "supabase.component.fullname" (dict "ctx" $ctx "component" $comp) }}
              {{- $portVal := index $ctx.Values $comp "service" "port" }}
              {{- $port := 80 }}
              {{- if $portVal }}
                {{- if kindIs "slice" $portVal }}
                  {{- $port = index $portVal 0 }}
                {{- else }}
                  {{- $port = $portVal }}
                {{- end }}
              {{- end }}
                value: {{ print $protocol "://" $svc ":" $port -}}
              {{ end -}}
              {{ end -}}
          {{- end }}
      {{- if $vals.initContainers }}
      initContainers:
        {{- $vals.initContainers | toYaml | nindent 8 }}
      {{- end -}}
      {{- if $vals.volumes }}
      volumes:
        {{- range $vals.volumes }}
        - name: {{ .name }}
          {{- if .configMap }}
          configMap:
            name: {{ printf "%s-%s" (include "supabase.component.fullname" (dict "ctx" $ctx "component" $comp)) .configMap.name }}
          {{- end }}
          {{- if .persistentVolumeClaim }}
          persistentVolumeClaim:
            claimName: {{ printf "%s-%s" (include "supabase.component.fullname" (dict "ctx" $ctx "component" $comp)) .persistentVolumeClaim.claimName }}
          {{- end }}
          {{- if .emptyDir }}
          emptyDir:
            {{- if kindIs "map" .emptyDir }}
            {{- toYaml .emptyDir | nindent 12 }}
            {{- else }}
            {}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
      {{- with $vals.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $vals.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $vals.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
