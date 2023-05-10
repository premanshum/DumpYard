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
