#! /bin/bash

set -eo pipefail

#./08_prom_grafana_thanos.sh -d true
while getopts d: option; do
  case "${option}" in 
    d)
      echo "-d delete was triggered, Parameter: ${OPTARG}";
      helm delete grafana;
      helm delete prometheus;
      kubectl delete -f yace/
      exit 1
      ;;
    \?)
      echo "Invalid option: ${OPTARG}";
      exit 1
      ;;
  esac
done

kubectl apply -f namespace.yaml

helm upgrade -i prometheus stable/prometheus \
    --namespace monitoring \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"

helm upgrade -i grafana ./grafana \
    --namespace monitoring \
    --set persistence.storageClassName="gp2" \
    --set adminPassword='password123' \
    --set datasources."datasources\.yaml".apiVersion=1 \
    --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
    --set datasources."datasources\.yaml".datasources[0].type=prometheus \
    --set datasources."datasources\.yaml".datasources[0].url=http://prometheus-server.monitoring.svc.cluster.local \
    --set datasources."datasources\.yaml".datasources[0].access=proxy \
    --set datasources."datasources\.yaml".datasources[0].isDefault=true \
    --set service.type=LoadBalancer


kubectl apply -f yace/

# kubectl get pods --namespace monitoring -l "app=prometheus,component=alertmanager" -o jsonpath="{.items[0].metadata.name}")
#   kubectl --namespace monitoring port-forward $POD_NAME 9093

# kubectl port-forward -n monitoring deploy/prometheus-server 8080:9090

# localhost:8080