# Defang GitHub Action

A GitHub Action to deploy with Defang. Use this action to deploy your application with Defang, either to the Defang Playground, or to your own AWS account.

## Usage

The simplest usage is to deploy a compose-based project to the Defang Playground. This is done by adding the following to your GitHub workflow, assuming you have a `compose.yaml` file in the root of your repository.

To do so, just add the following to your GitHub workflow:

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
      uses: DefangLabs/defang-github-action@main
```

### Managing Config Values

Defang allows you to [securely manage configuration values](https://docs.defang.io/docs/concepts/configuration). You can store your config using [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) and then pass them through to the Defang action. Make sure the environment variables you pass has the same name as specified in the Defang config.

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
      uses: DefangLabs/defang-github-action@main
      env:
        API_KEY: ${{ secrets.API_KEY }}
```

### Projects in a Subdirectory

If your project is in a subdirectory, you can specify the path to the project in the `directory` input.

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
      uses: DefangLabs/defang-github-action@main
      with:
        directory: ./test
      env:
        DEFANG_GH_ACTION_TEST_MESSAGE: ${{ secrets.MESSAGE }}
```