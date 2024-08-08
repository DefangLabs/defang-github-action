# Defang GitHub Action

A GitHub Action to deploy with Defang. Use this action to deploy your application with Defang, either to the Defang Playground, or to your own AWS account.

## Usage

The simplest usage is to deploy a compose-based project to the Defang Playground. This is done by adding the following to your GitHub workflow, assuming you have a `compose.yaml` file in the root of your repository.

To do so, just add a job like the following to your GitHub workflow (note the permissions and the Deploy step):

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write

    steps:
    - name: Checkout Repo
      uses: actions/checkout@v4

    - name: Deploy
      uses: DefangLabs/defang-github-action@v1
```

### Managing Config Values

Defang allows you to [securely manage configuration values](https://docs.defang.io/docs/concepts/configuration). You can store your config using [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) and then pass them through to the Defang action. To do so, make sure to set your env vars in the `env` section of the action. This is where you can pass the value of the secret. Then specify the names of the env vars you want Defang to use in the `configEnvVars` input. We do this for security reasons: we don't want to accidentally expose sensitive information in the logs, so you have to be explicit about which env vars you want Defang to submit as config.

```yaml
jobs:
  test:
    # [...]
    steps:
      # [...]
    - name: Deploy
      uses: DefangLabs/defang-github-action@v1
      with:
        configEnvVars: "API_KEY DB_CONNECTION_STRING"
      env:
        API_KEY: ${{ secrets.API_KEY }}
        DB_CONNECTION_STRING: ${{ secrets.DB_CONNECTION_STRING }}
```

### Projects in a Subdirectory

If your compose file is in a different directory than your project root, you can specify the path to the project in the `cwd` input.

```yaml
jobs:
  test:
    # [...]
    steps:
      # [...]
    - name: Deploy
      uses: DefangLabs/defang-github-action@v1
      with:
        cwd: "./test"
```

### Specifying the CLI Version

If you want to use a specific version of the Defang CLI, you can specify it using the `cliVersion` input.

```yaml
jobs:
  test:
    # [...]
    steps:
      # [...]
    - name: Deploy
      uses: DefangLabs/defang-github-action@v1
      with:
        cliVersion: v0.5.38
```

### Full Example

Here is a full example of a GitHub workflow that does everything we've discussed so far:

```yaml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write

    steps:
    - name: Checkout Repo
      uses: actions/checkout@v4

    - name: Deploy
      uses: DefangLabs/defang-github-action@main
      with:
        cliVersion: v0.5.38
        configEnvVars: "API_KEY DB_CONNECTION_STRING"
        cwd: "./test"
      env:
        API_KEY: ${{ secrets.API_KEY }}
        DB_CONNECTION_STRING: ${{ secrets.DB_CONNECTION_STRING }}
```