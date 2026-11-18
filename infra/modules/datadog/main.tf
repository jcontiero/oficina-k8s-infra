resource "helm_release" "datadog_agent" {
  count            = var.enabled ? 1 : 0
  name             = "datadog"
  repository       = "https://helm.datadoghq.com"
  chart            = "datadog"
  version          = "3.274.0"
  namespace        = "datadog"
  create_namespace = true

  lifecycle {
    precondition {
      condition     = length(var.datadog_api_key) > 0 && var.datadog_api_key != "a_preencher"
      error_message = "Configure DATADOG_API_KEY antes de habilitar o Agent."
    }
  }

  values = [yamlencode({
    datadog = { apm = { socketEnabled = false } }
    agents = { containers = {
      agent      = { resources = { requests = { cpu = "75m", memory = "256Mi" }, limits = { cpu = "150m", memory = "512Mi" } } }
      traceAgent = { resources = { requests = { cpu = "10m", memory = "128Mi" }, limits = { cpu = "50m", memory = "256Mi" } } }
    } }
    clusterAgent = { resources = { requests = { cpu = "50m", memory = "128Mi" }, limits = { memory = "256Mi" } } }
  })]

  set_sensitive {
    name  = "datadog.apiKey"
    value = var.datadog_api_key
  }

  set {
    name  = "datadog.site"
    value = var.datadog_site
  }

  set {
    name  = "datadog.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "datadog.logs.enabled"
    value = "true"
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = "true"
  }

  set {
    name  = "datadog.apm.portEnabled"
    value = "true"
  }

  set {
    name  = "datadog.apm.port"
    value = "8126"
  }

  set {
    name  = "datadog.systemProbe.enableDefaultKernelHeadersPaths"
    value = "false"
  }

  set {
    name  = "datadog.kubelet.tlsVerify"
    value = "false"
  }
}
