

```yaml {:copy}
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
    <th scope="col" style="width:30%"><b>Code</b></th>
    <th scope="col" style="width:70%"><b>Explanation</b></th>
  </tr>
</thead>
<tbody>
<tr>
<td>

```yaml
name: 'Create or Update service workflows'
```
</td>
<td>

The name of the workflow as it will appear in the "Actions" tab of the GitHub repository.
</td>
</tr>
    
<tr>
<td>
    
```yaml
concurrency: service-workflow-cu_${{ github.ref }}
```
</td>
<td>
    
Creates a concurrency group for specific events. For more information, see "[AUTOTITLE](/actions/using-jobs/using-concurrency)."
</td>
</tr>
    
<tr>
<td>
    
```yaml
on:
```
</td>
<td>
    
The `on` keyword lets you define the events that trigger when the workflow is run. You can define multiple events here. For more information, see "[AUTOTITLE](/actions/using-workflows/triggering-a-workflow#using-events-to-trigger-workflows)."
</td>
</tr>
<tr>
<td>

```yaml 
  workflow_dispatch:
```
</td>
<td>

Add the `workflow_dispatch` event if you want to be able to manually run this workflow from the UI. For more information, see [`workflow_dispatch`](/actions/using-workflows/events-that-trigger-workflows#workflow_dispatch).
</td>
</tr>
<tr>
<td>

```yaml
  push:
    # Service workflows should be updated / created before PRs are merged
    branches-ignore: [dev, test, preprod, main]
    paths-ignore:
      - ".github/workflows/**"
      - "!.github/workflows/service-workflow-cu.yml"
```
</td>
<td>

Add the `push` event, so that the workflow DOES NOT runs when a commit is pushed to a branches called `dev, test, preprod and main`. Even For feature branches, ignore the changes committed to any files in '.github/workflows' path EXCEPT 'service-workflow-cu.yml' file. For more information, see [`push`](/actions/using-workflows/events-that-trigger-workflows#push).
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

</tbody>
</table>

