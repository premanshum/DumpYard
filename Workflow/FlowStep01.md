

```yaml{:copy}
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
    jobs:
      create-workflows:
        runs-on: ubuntu-latest
        steps:
          - name: Get branch name
            id: get-branch
            run: |
              if ( "${{ github.event_name }}" -eq "pull_request" ) {
                echo "::set-output name=BRANCH::${{ github.head_ref }}"
              } else {
                echo "::set-output name=BRANCH::${{ github.ref }}"
              }
            shell: pwsh
          - uses: actions/checkout@v2
            with:
              token: "${{ secrets.WORKFLOW_TOKEN }}"
              ref: "${{ steps.get-branch.outputs.BRANCH }}"
          - name: "Add all services into the ${{ matrix.name }} list"
            run: ls "src/services" > "all-services.txt"
          - name: "Create possibly missing IaC workflow"
            uses: "./src/shared/github-actions/create-workflow"
            with:
              service-list: "all-services.txt"
              workflow-type: iac
          - name: "Create possibly missing Code workflow"
            uses: "./src/shared/github-actions/create-workflow"
            with:
              service-list: "all-services.txt"
              workflow-type: code
          - name: Commit changes
            run: |
              git config --global user.name "Admiral Automation"
              git config --global user.email admiral-automation@maersk.com
              have_changes=`git status | grep '.github/workflows'` || {
                echo "No workflow file created."
                exit
              }
              echo "$have_changes"
              git pull
              git add .github/workflows
              git commit -m "Add missing / update workflow files"
              git branch
              git push
              
```

<table style="table-layout: fixed;">
<thead>
  <tr>
    <th scope="col" style="width:60%"><b>Code</b></th>
    <th scope="col" style="width:40%"><b>Explanation</b></th>
  </tr>
</thead>
<tbody>
<tr>
<td>

```yaml{:copy}
name: 'Link Checker: All English'
```
</td>
<td>

{% data reusables.actions.explanation-name-key %}
</td>
</tr>
<tr>
<td>

```yaml{:copy}
on:
```
</td>
<td>

The `on` keyword lets you define the events that trigger when the workflow is run. You can define multiple events here. For more information, see "[AUTOTITLE](/actions/using-workflows/triggering-a-workflow#using-events-to-trigger-workflows)."
</td>
</tr>
<tr>
<td>

```yaml{:copy}
  workflow_dispatch:
```
</td>
<td>

Add the `workflow_dispatch` event if you want to be able to manually run this workflow from the UI. For more information, see [`workflow_dispatch`](/actions/using-workflows/events-that-trigger-workflows#workflow_dispatch).
</td>
</tr>
<tr>
<td>

```yaml{:copy}
  push:
    branches:
      - main
```
</td>
<td>

Add the `push` event, so that the workflow runs automatically every time a commit is pushed to a branch called `main`. For more information, see [`push`](/actions/using-workflows/events-that-trigger-workflows#push).
</td>
</tr>
<tr>
<td>

```yaml{:copy}
  pull_request:
```
</td>
<td>

Add the `pull_request` event, so that the workflow runs automatically every time a pull request is created or updated. For more information, see [`pull_request`](/actions/using-workflows/events-that-trigger-workflows#pull_request).
</td>
</tr>
<tr>
<td>

```yaml{:copy}
permissions:
  contents: read
  pull-requests: read
```
</td>
<td>

Modifies the default permissions granted to `GITHUB_TOKEN`. This will vary depending on the needs of your workflow. For more information, see "[AUTOTITLE](/actions/using-jobs/assigning-permissions-to-jobs)."
</td>
</tr>
<tr>
<td>

{% raw %}
```yaml{:copy}
concurrency:
  group: '${{ github.workflow }} @ ${{ github.event.pull_request.head.label || github.head_ref || github.ref }}'
```
{% endraw %}
</td>
<td>

Creates a concurrency group for specific events, and uses the `||` operator to define fallback values. For more information, see "[AUTOTITLE](/actions/using-jobs/using-concurrency)."
</td>
</tr>
<tr>
<td>

```yaml{:copy}
  cancel-in-progress: true
```
</td>
<td>

Cancels any currently running job or workflow in the same concurrency group.
</td>
</tr>
<tr>
<td>

```yaml{:copy}
jobs:
```
</td>
<td>

Groups together all the jobs that run in the workflow file.
</td>
</tr>
<tr>
<td>

```yaml{:copy}
  check-links:
```
</td>
<td>

Defines a job with the ID `check-links` that is stored within the `jobs` key.
</td>
</tr>
<tr>
<td>

{% raw %}
```yaml{:copy}
    runs-on: ${{ fromJSON('["ubuntu-latest", "self-hosted"]')[github.repository == 'github/docs-internal'] }}
```
{% endraw %}
</td>
<td>

Configures the job to run on a {% data variables.product.prodname_dotcom %}-hosted runner or a self-hosted runner, depending on the repository running the workflow. In this example, the job will run on a self-hosted runner if the repository is named `docs-internal` and is within the `github` organization. If the repository doesn't match this path, then it will run on an `ubuntu-latest` runner hosted by {% data variables.product.prodname_dotcom %}. For more information on these options see "[AUTOTITLE](/actions/using-jobs/choosing-the-runner-for-a-job)."
</td>
</tr>
<tr>
<td>

```yaml{:copy}
    steps:
```
</td>
<td>

Groups together all the steps that will run as part of the `check-links` job. Each job in a workflow has its own `steps` section.
</td>
</tr>
<tr>
<td>

```yaml{:copy}
      - name: Checkout
        uses: {% data reusables.actions.action-checkout %}
```
</td>
<td>

The `uses` keyword tells the job to retrieve the action named `actions/checkout`. This is an action that checks out your repository and downloads it to the runner, allowing you to run actions against your code (such as testing tools). You must use the checkout action any time your workflow will run against the repository's code or you are using an action defined in the repository.
</td>
</tr>
<tr>
<td>

```yaml{:copy}
      - name: Setup node
        uses: {% data reusables.actions.action-setup-node %}
        with:
          node-version: 16.13.x
          cache: npm
```
</td>
<td>

This step uses the `actions/setup-node` action to install the specified version of the Node.js software package on the runner, which gives you access to the `npm` command.
</td>
</tr>

<tr>
<td>

```yaml{:copy}
      - name: Install
        run: npm ci
```
</td>
<td>

The `run` keyword tells the job to execute a command on the runner. In this case, `npm ci` is used to install the npm software packages for the project.
</td>
</tr>

<tr>
<td>

```yaml{:copy}
      - name: Gather files changed
        uses: trilom/file-changes-action@a6ca26c14274c33b15e6499323aac178af06ad4b
        with:
          fileOutput: 'json'
```
</td>
<td>

Uses the `trilom/file-changes-action` action to gather all the changed files. This example is pinned to a specific version of the action, using the `a6ca26c14274c33b15e6499323aac178af06ad4b` SHA.
</td>
</tr>

<tr>
<td>

```yaml{:copy}
      - name: Show files changed
        run: cat $HOME/files.json
```
</td>
<td>

Lists the contents of `files.json`. This will be visible in the workflow run's log, and can be useful for debugging.
</td>
</tr>
<tr>
<td>

```yaml{:copy}
      - name: Link check (warnings, changed files)
        run: |
          ./script/rendered-content-link-checker.mjs \
            --language en \
            --max 100 \
            --check-anchors \
            --check-images \
            --verbose \
            --list $HOME/files.json
```
</td>
<td>

This step uses `run` command to execute a script that is stored in the repository at `script/rendered-content-link-checker.mjs` and passes all the parameters it needs to run.
</td>
</tr>
<tr>
<td>

```yaml{:copy}
      - name: Link check (critical, all files)
        run: |
          ./script/rendered-content-link-checker.mjs \
            --language en \
            --exit \
            --verbose \
            --check-images \
            --level critical
```
</td>
<td>

This step also uses `run` command to execute a script that is stored in the repository at `script/rendered-content-link-checker.mjs` and passes a different set of parameters.
</tr>

</tbody>
</table>

