**YAML**

    name: Create or Update service workflows
    concurrency: service-workflow-cu_${{ github.ref }}
    on:
      workflow_dispatch:
      push:
        #Service workflows should be updated / created before PRs are merged
        branches-ignore: [dev, test, preprod, main]
        paths-ignore:
          - ".github/workflows/**"
          - "!.github/workflows/service-workflow-cu.yml"
      pull_request:
        # Nothing should be committed directly to the master branch
        branches: [dev, test, preprod]
        paths-ignore:
          - ".github/workflows/**"
          - "!.github/workflows/service-workflow-cu.yml"
