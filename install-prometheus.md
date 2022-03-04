TO INSTALL PROMETHEUS AND GRAFANA ONLY

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install [RELEASE_NAME] prometheus-community/kube-prometheus-stack

kubectl create namespace monitoring
helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring

---------------------------------------------------------------------------------------

ALTERNATIVELY, USE THIS ALL IN ONE SOLUTION THAT MAY HAVE BEEN A BIT UNSTABLE IN THE PAST
(but includes pi specific bits, including temperatures)

https://github.com/carlosedp/cluster-monitoring

git clone https://github.com/carlosedp/cluster-monitoring.git
git checkout v0.40.0

# Quickstart for K3s
To deploy the monitoring stack on your K3s cluster, there are four parameters that need to be configured in the `vars.jsonnet` file:

1. Set `k3s.enabled` to `true`.
1. Change your K3s master node IP (your VM or host IP) on k3s.master_ip parameter.
1. Edit `suffixDomain` to have your node IP with the `.nip.io` suffix or your cluster URL. This will be your ingress URL suffix.
1. Set `traefikExporter` enabled parameter to `true` to collect Traefik metrics and deploy dashboard.

After changing these values to deploy the stack, run:

$ make vendor
$ make
$ make deploy

# Or manually:

$ make vendor
$ make
$ kubectl apply -f manifests/setup/
$ kubectl apply -f manifests/
