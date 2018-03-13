+++
title = "Lazy Aliases in my Shell"
draft = true
date = "2018-03-13T12:00:00+01:00"
keywords = [ "Shell", "Bash", "ZSH", "Oh-My-ZSH", "DevOps" ]
slug = "lazy_aliases_in_my_shell"

[params]
  author = "Jannik Arndt"
+++

I reduced the startup time of my shell by one second. Here's how:

## What I do

I work _a lot_ with the shell (or “Terminal” app on MacOS), mostly `kubectl`, `git`, `terraform` and `docker`. And of course I use the absolutely best shell of all, [oh-my-zsh](http://ohmyz.sh).

## The Problem

I noticed that recently the startup time for a new shell (or new tab) has grown longer than a second. That's annoying, because usually when I open a new tab, I want to _quickly_ check on something, like the logs of a pod or if I have committed something in a different project.

I inserted some `gdate +%s.%N` commands in my `.zshrc` to find out, at which point the slowdown was occurring. (`gdate` is the gnu-version of `date` and can be installed with `brew install coreutils`.)

The problem lies in the `kubectl` plugin, which creates the completions-list via `source <(kubectl completion zsh)`. This creates a _huge_ list of instructions.

## The Solution

1. The `kubectl` plugin also defines the `alias k=kubectl`, which shaves seconds, if not minutes off my daily work.
2. When I start a new shell, I expect it to be fast. When I check on something in the Kubernetes cluster I expect it to go through the network, i.e. to be slow.

So I delayed the initialization of the `kubectl completion` until I first call something:

```bash
function k() {
  source <(kubectl completion zsh)
  alias k=kubectl
  kubectl $@
}
```

This way, when I write `k get pods` for the first time, it creates the autocompletion list, rebinds what `k` does and then runs the command I wanted in the first place. All following `k get pods` go directly to `kubectl`.