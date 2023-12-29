resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_helm_version

  namespace        = var.ingress_nginx_namespace
  create_namespace = true

  values = [file("${path.module}/values.yaml")]

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

      POD_NAME=$(kubectl --kubeconfig ~/.kind_kube/config get po --namespace ${helm_release.ingress_nginx.namespace} -o name | head -n 1)
      kubectl --kubeconfig ~/.kind_kube/config exec -it $POD_NAME \
        --namespace ${helm_release.ingress_nginx.namespace} -- env | grep KUBERNETES_SERVICE_HOST | awk -F'=' '{print $2}' | tr -d '\n' > ${path.module}/kubernetes_service_host.localfile    
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}

data "local_file" "kubernetes_service_host" {
  filename   = "${path.module}/kubernetes_service_host.localfile"
  depends_on = [null_resource.wait_for_ingress_nginx]
}
