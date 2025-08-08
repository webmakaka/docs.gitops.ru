---
layout: page
title: Using Role-based Access Control in Kubernetes Engine
description: Using Role-based Access Control in Kubernetes Engine
keywords: Using Role-based Access Control in Kubernetes Engine
permalink: /devops/clouds/google/gke/qwiklabs/kubernetes-best-practices-security/using-role-based-access-control-in-kubernetes-engine/
---

# [GSP493] Using Role-based Access Control in Kubernetes Engine

<br/>

Делаю:  
07.06.2019

https://www.qwiklabs.com/focuses/5156?parent=catalog

![Using Role-based Access Control in Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices-security/using-role-based-access-control-in-kubernetes-engine/pic1.png 'Using Role-based Access Control in Kubernetes Engine'){: .center-image }

<br/>

### [Install Terraform](//docs.gitops.ru/terraform/setup//)

<br>

### Lab setup

    $ gcloud config set compute/region us-central1
    $ gcloud config set compute/zone us-central1-a

    $ git clone https://github.com/GoogleCloudPlatform/gke-rbac-demo.git

    $ cd gke-rbac-demo

    $ make create

While the resources are building, you can check on the progress in the Console by going to Compute Engine > VM instances. Use the Refresh button on the VM instances page to view the most up to date information.

<br/>

    $ gcloud compute instances list
    NAME                                              ZONE           MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP     STATUS
    gke-rbac-demo-cluster-default-pool-34702928-1k57  us-central1-a  n1-standard-1               10.0.96.5                    RUNNING
    gke-rbac-demo-cluster-default-pool-34702928-9rv8  us-central1-a  n1-standard-1               10.0.96.6                    RUNNING
    gke-tutorial-admin                                us-central1-a  f1-micro                    10.0.96.2    35.202.40.109   RUNNING
    gke-tutorial-auditor                              us-central1-a  f1-micro                    10.0.96.4    35.238.157.159  RUNNING
    gke-tutorial-owner                                us-central1-a  f1-micro                    10.0.96.3    35.225.158.60   RUNNING

<br>

### Validation

    $ make validate

Navigation menu > Kubernetes Engine > Clusters

Legacy Authorization должна быть выключена.

<br>

## Scenario 1: Assigning permissions by user persona

<br/>

### IAM - Role

A role named kube-api-ro-xxxxxxxx has been created with the permissions below as part of the Terraform configuration in iam.tf. These permissions are the minimum required for any user that requires access to the Kubernetes API.

- container.apiServices.get
- container.apiServices.list
- container.clusters.get
- container.clusters.getCredentials

<br/>

### Simulating users

Three service accounts have been created to act as Test Users:

- admin: has admin permissions over the cluster and all resources
- owner: has read-write permissions over common cluster resources
- auditor: has read-only permissions within the dev namespace only

<br/>

    $ gcloud iam service-accounts list
    NAME                                    EMAIL                                                                                DISABLED
    ql-api                                  qwiklabs-gcp-ae7c11a5b4abd659@qwiklabs-gcp-ae7c11a5b4abd659.iam.gserviceaccount.com  False
    App Engine default service account      qwiklabs-gcp-ae7c11a5b4abd659@appspot.gserviceaccount.com                            False
    GKE Tutorial Admin RBAC                 gke-tutorial-admin-rbac@qwiklabs-gcp-ae7c11a5b4abd659.iam.gserviceaccount.com        False
    Compute Engine default service account  556338330314-compute@developer.gserviceaccount.com                                   False
    GKE Tutorial Auditor RBAC               gke-tutorial-auditor-rbac@qwiklabs-gcp-ae7c11a5b4abd659.iam.gserviceaccount.com      False
    GKE Tutorial Owner RBAC                 gke-tutorial-owner-rbac@qwiklabs-gcp-ae7c11a5b4abd659.iam.gserviceaccount.com        False

<br/>

- gke-tutorial-admin: kubectl and gcloud are authenticated as a cluster administrator.
- gke-tutorial-owner: simulates the 'owner' account
- gke-tutorial-auditor: simulates the 'auditor'account

<br/>

### Creating the RBAC rules

Now you'll create the the namespaces, Roles, and RoleBindings by logging into the admin instance and applying the rbac.yaml manifest.

    $ gcloud compute ssh gke-tutorial-admin
    $ kubectl apply -f ./manifests/rbac.yaml

    $ cat ./manifests/rbac.yaml

```
# This manifest defines the RBAC resources (Roles, ServiceAccounts, and Bindings)
# used in the scenario 1 of this tutorial (see the README.md).

###################################################################################
# Role Definitions
# The following roles define two sets of permissions, read-write and read-only,
# for common resources in two namespaces: dev and prod.
###################################################################################
apiVersion: v1
kind: Namespace
metadata:
  name: dev
---

apiVersion: v1
kind: Namespace
metadata:
  name: prod

---
apiVersion: v1
kind: Namespace
metadata:
  name: test

---
# RBAC Documentation: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
# Grants read only permissions to common resource types in the dev namespace
# Because we're restricting permissions to a namespace.
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  # The namespace in which this role applies
  namespace: dev
  name: dev-ro
rules:
  # The api groups that contain the resources we want to manage
- apiGroups: ["", apps, extensions]
  # The resources to which this role grants permissions
  resources: [pods, pods/log, services, deployments, configmaps]
  # The permissions granted by this role
  verbs: [get, list, watch]

---
# Grants read-write permissions to common resource types in all namespaces
# We use a ClusterRole because we're defining cluster-wide permissions.
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  # The namespace in which this role applies
  name: all-rw
rules:
  # The api groups that contain the resources we want to manage
- apiGroups: ["", apps, extensions]
  # The resources to which this role grants permissions
  resources: [pods, services, deployments, configmaps]
  # The permissions granted by this role
  verbs: [get, list, create, update, patch, delete]

---

# Allows anyone in the manager group to read resources in any namespace.
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: owner-binding
subjects:
- kind: User
  name: gke-tutorial-owner-rbac@qwiklabs-gcp-ae7c11a5b4abd659.iam.gserviceaccount.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: all-rw
  apiGroup: rbac.authorization.k8s.io

---
# This role binding allows anyone in the developer group to have read access
# to resources in the dev namespace.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: dev
  name: auditor-binding
subjects:
- kind: User
  name: gke-tutorial-auditor-rbac@qwiklabs-gcp-ae7c11a5b4abd659.iam.gserviceaccount.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: dev-ro
  apiGroup: rbac.authorization.k8s.io

```

<br/>

Открываем еще 1 терминальную сессию

    $ gcloud compute ssh gke-tutorial-owner
    $ kubectl create -n dev -f ./manifests/hello-server.yaml
    $ kubectl create -n prod -f ./manifests/hello-server.yaml
    $ kubectl create -n test -f ./manifests/hello-server.yaml

    $ cat ./manifests/hello-server.yaml

```

# The manifest exposes a simple hello-server service and deployment with a single pod

# Makes the hello-server pod addressable within the cluster
kind: Service
apiVersion: v1
metadata:
  # Label and name the service
  labels:
    app: hello-server
  name: hello-server
spec:
  ports:
    # Listens on port 8080 and routes to targetPort 8080 on backend pods
  - port: 8080
    protocol: TCP
    targetPort: 8080

  # Load balance requests across all pods labeled with app=hello-server
  selector:
    app: hello-server

  # Disable session affinity, each request may be routed to a new pod
  sessionAffinity: None

  # Expose the service internally only
  type: ClusterIP

---
# Deploys a pod to service hello-server requests
apiVersion: apps/v1
kind: Deployment
metadata:
  # Label and name the deployment
  labels:
    app: hello-server
  name: hello-server
spec:

  # Only run a single pod
  replicas: 1

  # Control any pod labeled with app=hello
  selector:
    matchLabels:
      app: hello-server

  # Define pod properties
  template:
    # Ensure created pods are labeled with hello-server to match the deployment selector
    metadata:
      labels:
        app: hello-server
    spec:
      # This pod does not require access to the Kubernetes API server, so we prevent
      # even the default token from being mounted
      automountServiceAccountToken: false

      # Pod-level security context to define the default UID and GIDs under which to
      # run all container processes. We use 9999 for all IDs since it is unprivileged
      # and known to be unallocated on the node instances.
      securityContext:
        runAsUser: 9999
        runAsGroup: 9999
        fsGroup: 9999

      # Define container properties
      containers:
      - image: gcr.io/google-samples/hello-app:1.0
        name: hello-server

        # Describes the ports exposed on the service
        ports:
        - containerPort: 8080
          protocol: TCP

        # Container-level security settings
        # Note, containers are unprivileged by default
        securityContext:
          # Prevents the container from writing to its filesystem
          readOnlyRootFilesystem: true
```

<br/>

    $ kubectl get pods -l app=hello-server --all-namespaces
    NAMESPACE   NAME                           READY   STATUS    RESTARTS   AGE
    dev         hello-server-c7665786b-xdcnt   1/1     Running   0          66s
    prod        hello-server-c7665786b-hxlg2   1/1     Running   0          33s
    test        hello-server-c7665786b-qbhl7   1/1     Running   0          15s

<br/>

### Viewing resources as the auditor

<br/>

Открываем еще 1 терминальную сессию

    $ gcloud compute ssh gke-tutorial-auditor


    $ kubectl get pods -l app=hello-server --all-namespaces
    Error from server (Forbidden): pods is forbidden: User "gke-tutorial-auditor-rbac@qwiklabs-gcp-ae7c11a5b4abd659.iam.gserviceaccount.com" cannot list resource "pods" in API group "" at the cluster scope: Required "container.pods.list" permission.

The error indicates that you don't have sufficient permissions. The auditor role is restricted to viewing only the resources in the dev namespace, so you'll need to specify the namespace when viewing resources.

    $ kubectl get pods -l app=hello-server --namespace=dev
    NAME                           READY   STATUS    RESTARTS   AGE
    hello-server-c7665786b-xdcnt   1/1     Running   0          9m11s

<br/>

    $ kubectl get pods -l app=hello-server --namespace=test
    // тоже forbidden

<br/>

Finally, verify the that the auditor has read-only access by trying to create and delete a deployment in the dev namespace.

    $ kubectl create -n dev -f manifests/hello-server.yaml
    $ kubectl delete deployment -n dev -l app=hello-server

<br/>

## Scenario 2: Assigning API permissions to a cluster application

In this scenario you'll go through the process of deploying an application that requires access to the Kubernetes API as well as configure RBAC rules while troubleshooting some common use cases.

<br/>

### Deploying the sample application

"Admin" instance

    $ kubectl apply -f manifests/pod-labeler.yaml

    $ cat manifests/pod-labeler.yaml

```
# Create a custom role in the default namespace that grants access to
# list pods
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pod-labeler
  namespace: default
rules:
- apiGroups: [""] # "" refers to the core API group
  resources: ["pods"]
  verbs: ["list"] # "patch" is intentionally omitted for troubleshooting (see README)

---
# Create a ServiceAccount that will be bound to the role above
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-labeler
  namespace: default

---
# Binds the pod-labeler ServiceAccount to the pod-labeler Role
# Any pod using the pod-labeler ServiceAccount will be granted
# API permissions based on the pod-labeler role.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pod-labeler
  namespace: default
subjects:
  # List of service accounts to bind
- kind: ServiceAccount
  name: pod-labeler
roleRef:
  # The role to bind
  kind: Role
  name: pod-labeler
  apiGroup: rbac.authorization.k8s.io
---
# Deploys a single pod to run the pod-labeler code
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-labeler
  namespace: default
spec:
  replicas: 1

  # Control any pod labeled with app=pod-labeler
  selector:
    matchLabels:
      app: pod-labeler

  template:
    # Ensure created pods are labeled with app=pod-labeler to match the deployment selector
    metadata:
      labels:
        app: pod-labeler

    spec:
      # Intentionally omitting serviceAccount for troubleshooting (see README)
      # serviceAccount: pod-labeler

      # Pod-level security context to define the default UID and GIDs under which to
      # run all container processes. We use 9999 for all IDs since it is unprivileged
      # and known to be unallocated on the node instances.
      securityContext:
        runAsUser: 9999
        runAsGroup: 9999
        fsGroup: 9999

      containers:
      - image: gcr.io/pso-examples/pod-labeler:0.1.5
        name: pod-labeler

```

<br/>

    $ kubectl get pods -l app=pod-labeler
    NAME                           READY   STATUS             RESTARTS   AGE
    pod-labeler-66df4f5746-7tdgf   0/1     CrashLoopBackOff   3          105s

<br/>

    $ kubectl describe pod -l app=pod-labeler | tail -n 20

    $ kubectl logs -l app=pod-labeler

<br/>

### Fixing the serviceAccountName

    $ kubectl get pod -oyaml -l app=pod-labeler

    // The pod-labeler-fix-1.yaml file contains the fix in the deployment's template spec:
    $ kubectl apply -f manifests/pod-labeler-fix-1.yaml

    $ cat manifests/pod-labeler-fix-1.yaml

<br/>

```
# Create a custom role in the default namespace that grants access to
# list pods
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pod-labeler
  namespace: default
rules:
- apiGroups: [""] # "" refers to the core API group
  resources: ["pods"]
  verbs: ["list"] # "patch" is intentionally omitted for troubleshooting (see README)

---
# Create a ServiceAccount that will be bound to the role above
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-labeler
  namespace: default

---
# Binds the pod-labeler ServiceAccount to the pod-labeler Role
# Any pod using the pod-labeler ServiceAccount will be granted
# API permissions based on the pod-labeler role.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pod-labeler
  namespace: default
subjects:
  # List of service accounts to bind
- kind: ServiceAccount
  name: pod-labeler
roleRef:
  # The role to bind
  kind: Role
  name: pod-labeler
  apiGroup: rbac.authorization.k8s.io
---
# Deploys a single pod to run the pod-labeler code
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-labeler
  namespace: default
spec:
  replicas: 1

  # Control any pod labeled with app=pod-labeler
  selector:
    matchLabels:
      app: pod-labeler

  template:
    # Ensure created pods are labeled with app=pod-labeler to match the deployment selector
    metadata:
      labels:
        app: pod-labeler

    spec:
      # Fix 1, set the serviceAccount so RBAC rules apply
      serviceAccount: pod-labeler

      # Pod-level security context to define the default UID and GIDs under which to
      # run all container processes. We use 9999 for all IDs since it is unprivileged
      # and known to be unallocated on the node instances.
      securityContext:
        runAsUser: 9999
        runAsGroup: 9999
        fsGroup: 9999

      containers:
      - image: gcr.io/pso-examples/pod-labeler:0.1.5
        name: pod-labeler

```

    $ kubectl get deployment pod-labeler -oyaml

    $ kubectl get pods -l app=pod-labeler

Ошибка

<br/>

### Identifying the application's role and permissions

    $ kubectl get rolebinding pod-labeler -oyaml

    $ kubectl apply -f manifests/pod-labeler-fix-2.yaml

    $ cat manifests/pod-labeler-fix-2.yaml

```
# Create a custom role in the default namespace that grants access to
# list pods
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pod-labeler
  namespace: default
rules:
- apiGroups: [""] # "" refers to the core API group
  resources: ["pods"]
  verbs: ["list","patch"] # Fix 2: adding permission to patch (update) pods

---
# Create a ServiceAccount that will be bound to the role above
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-labeler
  namespace: default

---
# Binds the pod-labeler ServiceAccount to the pod-labeler Role
# Any pod using the pod-labeler ServiceAccount will be granted
# API permissions based on the pod-labeler role.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pod-labeler
  namespace: default
subjects:
  # List of service accounts to bind
- kind: ServiceAccount
  name: pod-labeler
roleRef:
  # The role to bind
  kind: Role
  name: pod-labeler
  apiGroup: rbac.authorization.k8s.io

---
# Deploys a single pod to run the pod-labeler code
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-labeler
  namespace: default
spec:
  replicas: 1

  # Control any pod labeled with app=pod-labeler
  selector:
    matchLabels:
      app: pod-labeler

  template:
    # Ensure created pods are labeled with app=pod-labeler to match the deployment selector
    metadata:
      labels:
        app: pod-labeler

    spec:
      # Fix 1, set the serviceAccount so RBAC rules apply
      serviceAccount: pod-labeler

      # Pod-level security context to define the default UID and GIDs under which to
      # run all container processes. We use 9999 for all IDs since it is unprivileged
      # and known to be unallocated on the node instances.
      securityContext:
        runAsUser: 9999
        runAsGroup: 9999
        fsGroup: 9999

      containers:
      - image: gcr.io/pso-examples/pod-labeler:0.1.5
        name: pod-labeler

```

    $ kubectl delete pod -l app=pod-labeler

<br/>

### Verifying successful configuration

    $ kubectl get pods --show-labels
    NAME                         READY   STATUS    RESTARTS   AGE    LABELS
    pod-labeler-5df9db46-frf76   1/1     Running   0          110s   app=pod-labeler,pod-template-hash=5df9db46,updated=1559858449.38

**Key take-aways**

- Container and API server logs will be your best source of clues for diagnosing RBAC issues.

- Use RoleBindings or ClusterRoleBindings to determine which role is specifying the permissions for a pod.

- API server logs can be found in stackdriver under the Kubernetes resource.

- Not all API calls will be logged to stack driver. Frequent, or verbose payloads are omitted by the Kubernetes' audit policy used in Kubernetes Engine. The exact policy will vary by Kubernetes version, but can be found in the open source codebase.
