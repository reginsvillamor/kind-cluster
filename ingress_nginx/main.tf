resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_helm_version

  namespace        = var.ingress_nginx_namespace
  create_namespace = true

  values = [file("ingress_nginx/values.yaml")]

}

data "kubernetes_resources" "ingress_nginx" {
  api_version    = "v1"
  kind           = "Pod"
  label_selector = "app.kubernetes.io/instance=ingress-nginx"
  namespace      = var.ingress_nginx_namespace
}

resource "null_resource" "wait_for_ingress_nginx" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"

      kubectl --kubeconfig ~/.kind_kube/config wait --namespace ${helm_release.ingress_nginx.namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s

      kubectl --kubeconfig ~/.kind_kube/config exec -it ${data.kubernetes_resources.ingress_nginx.objects.0.metadata.name} \
        --namespace ${helm_release.ingress_nginx.namespace} -- env | grep KUBERNETES_SERVICE_HOST | awk -F'=' '{print $2}' | tr -d '\n' > ${path.module}/kubernetes_service_host.localfile    
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}

data "local_file" "kubernetes_service_host" {
  filename   = "${path.module}/kubernetes_service_host.localfile"
  depends_on = [null_resource.wait_for_ingress_nginx]
}
