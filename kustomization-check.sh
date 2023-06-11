#! /bin/bash
for config in ./deploy/*; do
  if [ -f "$config/kustomization.yaml" ]; then
    kustomize build --load-restrictor=LoadRestrictionsNone --reorder=legacy $config | kubectl apply --dry-run=client -f- --validate=false
  fi
done
