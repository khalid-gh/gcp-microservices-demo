resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "10.18.2"
  namespace        = "argocd"
  create_namespace = true
  atomic           = true
  timeout          = 600

  values = [
    yamlencode({
      global = {
        image = {
          repository = "quay.io/argoproj/argocd"
          tag        = "v3.6.2"
        }
      }
      dex = {
        enabled = false
      }
      notifications = {
        enabled = false
      }
      applicationSet = {
        enabled = false
      }
      server = {
        service = {
          type = "ClusterIP"
        }
      }
      configs = {
        repositories = {
          online-boutique = {
            name      = "online-boutique"
            url       = "us-docker.pkg.dev/online-boutique-ci/charts"
            type      = "helm"
            enableOCI = "true"
          }
        }
      }
    })
  ]
}

resource "helm_release" "istio-base" {
  name             = "istio-base"
  repository       = "https://blob.istio.io/istio-release/charts"
  chart            = "base"
  version          = local.istio_chart_version
  namespace        = "istio-system"
  create_namespace = true
  atomic           = true
  timeout          = 600

  values = [
    yamlencode({
      defaultRevision = "default"
    })
  ]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://blob.istio.io/istio-release/charts"
  chart      = "istiod"
  version    = local.istio_chart_version
  namespace  = "istio-system"
  atomic     = true
  timeout    = 600

  values = [
    yamlencode({
      autoscaleEnabled = false
      replicaCount     = 1
      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
      }
    })
  ]

  depends_on = [helm_release.istio-base]
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "31.0.0"
  namespace  = "istio-system"
  atomic     = true
  timeout    = 600

  values = [
    yamlencode({
      alertmanager             = { enabled = false }
      kube-state-metrics       = { enabled = false }
      prometheus-node-exporter = { enabled = false }
      prometheus-pushgateway   = { enabled = false }
      server = {
        fullnameOverride = "prometheus"
        retention        = "6h"
        persistentVolume = { enabled = false }
        service          = { type = "ClusterIP" }
        ingress          = { enabled = false }
        global = {
          scrape_interval     = "30s"
          evaluation_interval = "30s"
        }
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = { memory = "1Gi" }
        }
      }
    })
  ]

  depends_on = [helm_release.istiod]
}

resource "helm_release" "kiali" {
  name       = "kiali"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  version    = "2.35.0"
  namespace  = "istio-system"
  atomic     = true
  timeout    = 600

  values = [
    yamlencode({
      auth = { strategy = "token" }
      deployment = {
        service_type   = "ClusterIP"
        view_only_mode = true
        ingress        = { enabled = false }
      }
      external_services = {
        prometheus = {
          url = "http://prometheus.istio-system.svc.cluster.local"
        }
        grafana = { enabled = false }
        tracing = { enabled = false }
      }
    })
  ]

  depends_on = [helm_release.prometheus]
}

resource "kubernetes_manifest" "online-boutique-app" {
  manifest = yamldecode(file("${path.module}/../argocd/applications/online-boutique.yaml"))

  depends_on = [helm_release.argocd, helm_release.istiod]
}
