# Defang GitHub Action

A GitHub Action to deploy with Defang. Use this action to deploy your application with Defang, either to the Defang Playground, or to your own AWS account.

## Usage

The simplest usage is to deploy a compose-based project to the Defang Playground. This is done by adding the following to your GitHub workflow, assuming you have a `compose.yaml` file in the root of your repository.

To do so, just add the following to your GitHub workflow (note the permissions and the Deploy step):

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
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write

    steps:
    - name: Checkout Repo
      uses: actions/checkout@v4

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
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write

    steps:
    - name: Checkout Repo
      uses: actions/checkout@v4

    - name: Deploy
      uses: DefangLabs/defang-github-action@v1
      with:
        cwd: "./test"
        configEnvVars: "API_KEY DB_CONNECTION_STRING"
      env:
        API_KEY: ${{ secrets.API_KEY }}
        DB_CONNECTION_STRING: ${{ secrets.DB_CONNECTION_STRING }}
```