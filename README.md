# Introduction
What if I want to have a chatbot that accepts a command and run a shell script?

This chatbot app does just that.

The chatbot can be deployed on K8 using the helm chart.

# Development
```
chatbot go/compile       compile go programs
chatbot docker/tag/list  list the existing tagged images
chatbot docker/build     build and tag the Docker image. vars:tag
chatbot docker/push      push the Docker image to ECR. vars:tag
chatbot helm/install     Deploy stack into kubernetes.
chatbot helm/delete      delete stack from reference. vars: stack
chatbot deploy           Compiles, builds and deploys a stack for a tag. vars: tag
chatbot redeploy         Compiles, builds and deploys a stack for a tag. vars: tag
chatbot help             this helps
```
