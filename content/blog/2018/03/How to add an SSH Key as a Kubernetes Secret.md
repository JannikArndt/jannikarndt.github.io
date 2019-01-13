+++
title = "How to add an SSH Key as a Kubernetes Secret"
draft = false
date = "2018-03-22T07:00:00+01:00"
keywords = [ "DevOps", "Kubernetes", "Docker", "SSH" ]
slug = "ssh_key_as_kubernetes_secret"

[params]
  author = "Jannik Arndt"
+++

Adding an ssh-file as a secret sounds easy, but there are pitfalls.

<!--more-->

## Step 1: Add secret to kubernetes

First, add the key as a secret, for example with terraform

```hcl
resource "kubernetes_secret" "ssh_key_verstehensystem_csv_ingest_bwh" {
  metadata {
    name      = "my-ssh-key"
  }

  data {
    "id_rsa" = "${file("id_rsa")}"
  }

  type = "Opaque"
}
```

(see [Docs](https://www.terraform.io/docs/providers/kubernetes/r/secret.html)) or with `kubectl`:

```shell
$ kubectl create secret generic my-ssh-key --from-file=id_rsa=/path/to/local-ssh-keys
```

(see [Docs](https://kubernetes.io/docs/concepts/configuration/secret/#use-case-pod-with-ssh-keys)). Note that this command renames the file: `--from-file=<name on the cluster>=<local file>`.

## Step 2: Mount the secret

Now, in your pod, mount the secret as a volume:

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: ...
spec:
  containers:
  - name: ...
    image: ...
    volumeMounts:
    - name: ssh-key-volume
      mountPath: "/etc/ssh-key"
  volumes:
  - name: ssh-key-volume
    secret:
      secretName: my-ssh-key
      defaultMode: 256
```

## Step 3: Do's and Dont's

### Mount to `~/.ssh/`

Remember that mounting to an existing directory will _overwrite_ it. Even if `.ssh` does not exist, it will be replaced by a _read-only_ mount, so `ssh` will fail when it creates the `known_hosts` file.

Besides, writing `~` in your `yaml` will most likely create a folder called `'~'`. You need absolute paths!

### Forget the `defaultMode`

`ssh` checks the key's file permissions and will fail if they are too broad. Since the volume is read-only, you cannot simply `chmod` after the fact, you need to set the permissions in your `yaml`. But beware…

### Write POSIX in `defaultMode`

The docs [state](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod):

> Note that the JSON spec doesn’t support octal notation, so use the value 256 for 0400 permissions. If you use yaml instead of json for the pod, you can use octal notation to specify permissions in a more natural way.

In my experience, the `yaml` spec _also_ does not support octal notation, so you need to convert:

```shell
400 = (4 * 8^2) + (4 * 8^1) + (4 * 8^0) = (4 * 64) + (0 * 8) + (0 * 1) = 256 + 0 + 0 = 256
```