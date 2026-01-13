# Defang GitHub Action

A GitHub Action to deploy with [Defang](https://defang.io/). Use this action to deploy your application with Defang, either to the [Defang Playground](https://docs.defang.io/docs/providers/playground), or to [your own AWS account](https://docs.defang.io/docs/providers/aws).

## Usage

The simplest usage is to deploy a [Compose-based](https://github.com/compose-spec/compose-spec/blob/main/spec.md) project to the Defang Playground. This is done by adding the following to your GitHub workflow, assuming you have a `compose.yaml` file in the root of your repository.

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
      uses: DefangLabs/defang-github-action@v1.2.1
```

### Managing Config Values

Defang allows you to [securely manage configuration values](https://docs.defang.io/docs/concepts/configuration). You can store your config using [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) and then pass them through to the Defang action.

To publish a secret stored in GitHub to the cloud as a secure config value with defang, you need to do two things:

  1. Use the `env` section of the step to pass the value of the secrets to environment variables that match the names of the config values in your Compose file.
  2. Specify the names of the environment variables you want to push to the cloud as config values in the `config-env-vars` input, either whitespace delimited or as a YAML literal block scalar (`|`).

The second step is to make sure that we only publish the secrets you explicitly tell us to. For example, you could have a secret in an env var at the job level, instead of the step level that you might not want to push to the cloud, even if it is in a secure store.

```yaml
jobs:
  test:
    # [...]
    steps:
      # [...]
    - name: Deploy
      uses: DefangLabs/defang-github-action@v1.2.1
      with:
        # Note: you need to tell Defang which env vars to push to the cloud as config values here. Only these ones will be pushed up.
        config-env-vars: |
          API_KEY
          DB_CONNECTION_STRING
      env:
        API_KEY: ${{ secrets.API_KEY }}
        DB_CONNECTION_STRING: ${{ secrets.DB_CONNECTION_STRING }}
```

### Projects in a Subdirectory

If your Compose file is in a different directory than your project root, you can specify the path to the project in the `cwd` input.

```yaml
jobs:
  test:
    # [...]
    steps:
      # [...]
    - name: Deploy
      uses: DefangLabs/defang-github-action@v1.2.0
      with:
        cwd: "./test"
```

### Specifying the CLI Version

If you want to use a specific version of the Defang CLI, you can specify it using the `cli-version` input.

```yaml
jobs:
  test:
    # [...]
    steps:
      # [...]
    - name: Deploy
      uses: DefangLabs/defang-github-action@v1.2.1
      with:
        cli-version: v0.5.38
```

### Customizing the Defang Command

If you want to customize the Defang command that is run, you can specify it using the `command` input.
This is useful if you want to run a command other than `compose up` or if you want to pass additional arguments to the command.

```yaml
jobs:
  test:
    # [...]
    steps:
      # [...]
    - name: Deploy
      uses: DefangLabs/defang-github-action@v1.2.1
      with:
        command: "compose up --project-name my-project"
```

### Deploying to AWS

To deploy to your own AWS account, you'll first need to configure AWS for OIDC authentication. The easiest way is through the [Defang Portal](https://portal.defang.io) - navigate to **Clouds** → **AWS** and follow the setup wizard to create the required IAM role via CloudFormation.

Once configured, use the `aws-account-id` input to deploy:

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
      uses: DefangLabs/defang-github-action@v1.3.1
      with:
        provider: aws
        aws-account-id: "123456789012"  # Your AWS Account ID
      env:
        AWS_REGION: us-west-2
```

This automatically sets the `AWS_ROLE_ARN` to `arn:aws:iam::<account-id>:role/defang-cd-CIRole`, which is the default role created by the Portal.

If you configured AWS manually with a different role name, you can set `AWS_ROLE_ARN` directly in the `env` section instead of using `aws-account-id`.

For detailed setup instructions, see [Deploying to AWS from GitHub Actions](https://docs.defang.io/docs/tutorials/deploying-from-github-actions/to-aws).

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
      uses: DefangLabs/defang-github-action@v1.3.1
      with:
        cli-version: v0.5.43
        config-env-vars: "API_KEY DB_CONNECTION_STRING"
        cwd: "./test"
        compose-files: "./docker-compose.yaml"
        mode: "staging"
        provider: "aws"
        aws-account-id: "123456789012"
        command: "compose up"
        verbose: true
      env:
        AWS_REGION: us-west-2
        API_KEY: ${{ secrets.API_KEY }}
        DB_CONNECTION_STRING: ${{ secrets.DB_CONNECTION_STRING }}
```
