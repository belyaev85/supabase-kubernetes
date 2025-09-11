{{/*
Expand the name of the chart.
*/}}
{{- define "supabase.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "supabase.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "supabase.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "supabase.labels" -}}
helm.sh/chart: {{ include "supabase.chart" . }}
{{ include "supabase.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "supabase.selectorLabels" -}}
app.kubernetes.io/name: {{ include "supabase.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "supabase.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "supabase.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Common helpers for all Supabase components

This section contains generic template functions that work for any component.
Follows the same pattern as _deployment.tpl - accepts component name as parameter.
*/}}

{{/* Generic component name helper */}}
{{- define "supabase.component.name" -}}
{{- $ctx := index . "ctx" -}}
{{- $comp := index . "component" -}}
{{- $vals := index $ctx.Values $comp | default dict -}}
{{- $defaultName := print $ctx.Chart.Name "-" $comp -}}
{{- default $defaultName $vals.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/* Generic component fullname helper */}}
{{- define "supabase.component.fullname" -}}
{{- $ctx := index . "ctx" -}}
{{- $comp := index . "component" -}}
{{- $vals := index $ctx.Values $comp | default dict -}}
{{- if $vals.fullnameOverride }}
{{- $vals.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := include "supabase.component.name" . -}}
{{- if contains $ctx.Release.Name $name }}
{{- $name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" $ctx.Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/* Generic component selector labels helper */}}
{{- define "supabase.component.selectorLabels" -}}
{{- $ctx := index . "ctx" -}}
{{- $comp := index . "component" -}}
app.kubernetes.io/name: {{ include "supabase.component.name" . }}
app.kubernetes.io/instance: {{ $ctx.Release.Name }}
{{- end }}

{{/* Generic component labels helper */}}
{{- define "supabase.component.labels" -}}
{{- $ctx := index . "ctx" -}}
{{- $comp := index . "component" -}}
helm.sh/chart: {{ include "supabase.chart" $ctx }}
{{ include "supabase.component.selectorLabels" . }}
{{- if $ctx.Chart.AppVersion }}
app.kubernetes.io/version: {{ $ctx.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $ctx.Release.Service }}
{{- end }}

{{/* Generic service account name helper */}}
{{- define "supabase.component.serviceAccountName" -}}
{{- $ctx := index . "ctx" -}}
{{- $comp := index . "component" -}}
{{- $vals := index $ctx.Values $comp | default dict -}}
{{- $serviceAccount := index $vals "serviceAccount" | default dict -}}
{{- if $serviceAccount.create }}
{{- default (include "supabase.component.fullname" .) $serviceAccount.name }}
{{- else }}
{{- default "default" $serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Get component name from template path - assumes structure templates/componentName/file.yaml */}}
{{- define "supabase.component.fromPath" -}}
{{- $path := .Template.Name }}
{{- $parts := splitList "/" $path }}
{{- range $i, $part := $parts }}
  {{- if eq $part "templates" }}
    {{- if gt (len $parts) (add1 $i) }}
      {{- $nextIndex := add1 $i | int }}
      {{- index $parts $nextIndex }}
    {{- end }}
    {{- break }}
  {{- end }}
{{- end }}
{{- end }}

{{/* Automatically include base deployment with component determined from path */}}
{{- define "supabase.auto.deployment" -}}
{{- $component := include "supabase.component.fromPath" . }}
{{- $vals := index .Values $component | default dict -}}
{{- if $vals.enabled }}
{{- include "supabase.base.deployment" (dict "ctx" . "component" $component) }}
{{- end }}
{{- end }}

{{/* Automatically include base service with component determined from path */}}
{{- define "supabase.auto.service" -}}
{{- $component := include "supabase.component.fromPath" . }}
{{- $vals := index .Values $component | default dict -}}
{{- if $vals.enabled }}
{{- include "supabase.base.service" (dict "ctx" . "component" $component) }}
{{- end }}
{{- end }}

{{/* Automatically include base service with component determined from path */}}
{{- define "supabase.auto.serviceaccount" -}}
{{- $component := include "supabase.component.fromPath" . }}
{{- $vals := index .Values $component | default dict -}}
{{- if $vals.enabled }}
{{- include "supabase.base.serviceaccount" (dict "ctx" . "component" $component) }}
{{- end }}
{{- end }}
