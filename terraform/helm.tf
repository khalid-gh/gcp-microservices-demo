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
      redis = {
        image = {
          repository = "docker.io/library/redis"
          tag        = "8.6.4-alpine"
        }
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

resource "kubernetes_manifest" "online-boutique-app" {
  manifest = yamldecode(file("${path.module}/../argocd/applications/online-boutique.yaml"))

  depends_on = [helm_release.argocd]
}
