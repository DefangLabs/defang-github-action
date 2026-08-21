# Defang GitHub Action

This GitHub Action is the easiest way to deploy your application with [Defang](https://defang.io/).

You can deploy to any of the following cloud providers

- [your own AWS account](https://docs.defang.io/docs/providers/aws)
- [your own Azure account](https://docs.defang.io/docs/providers/azure)
- [your own GCP account](https://docs.defang.io/docs/providers/gcp)

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
        uses: DefangLabs/defang-github-action@v2
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
        uses: DefangLabs/defang-github-action@v2
        with:
          # Note: you need to tell Defang which env vars to push to the cloud as config values here. Only these ones will be pushed up.
          config-env-vars: |
            API_KEY
            DB_CONNECTION_STRING
        env:
          API_KEY: ${{ secrets.API_KEY }}
          DB_CONNECTION_STRING: ${{ secrets.DB_CONNECTION_STRING }}
```

### Using an Environment File

By default, Defang loads a `.env` file next to your Compose file to resolve `${VARIABLE}` interpolation. To use a different environment file (or several), set the `env-file` input. This mirrors `docker compose --env-file` and, when set, replaces the default `.env`.

```yaml
jobs:
  test:
    # [...]
    steps:
      # [...]
      - name: Deploy
        uses: DefangLabs/defang-github-action@v2
        with:
          env-file: ".env.production"
```

Pass multiple files whitespace-delimited (`env-file: ".env .env.production"`); later files override earlier ones.

### Projects in a Subdirectory

If your Compose file is in a different directory than your project root, you can specify the path to the project in the `cwd` input.

```yaml
jobs:
  test:
    # [...]
    steps:
      # [...]
      - name: Deploy
        uses: DefangLabs/defang-github-action@v2
        with:
          cwd: "./test"
```

### Specifying the CLI Version

If you want to use a specific version of the Defang CLI, you can specify it using the `cli-version` input.
Specify a version number (with or without `v`), or `nightly` to use the nightly CLI build.
Note that the nightly builds have only undergone limited automated testing and should be considered unstable.
You can also pass any Git ref (branch name like `main` or commit SHA) to build the CLI from source using `go`.

```yaml
jobs:
  test:
    # [...]
    steps:
      # [...]
      - name: Deploy
        uses: DefangLabs/defang-github-action@v2
        with:
          cli-version: v3.5.2 # or 3.5.2 or nightly or main or a commit SHA
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
        uses: DefangLabs/defang-github-action@v2
        with:
          command: "compose up --project-name my-project"
```

### Capturing Output

Set `capture-output: true` to capture the command's stdout as an output (`outputs.stdout`). This is off by default because large deployments can exceed GitHub Actions' memory limits and cause the workflow to fail even though the deployment succeeded:

```yaml
jobs:
  test:
    # [...]
    steps:
      # [...]
      - name: Deploy
        uses: DefangLabs/defang-github-action@v2
        with:
          capture-output: true
```

### Publishing the Deployment Summary

When the command is `compose up` (the default), the action surfaces the deployment result on the GitHub run instead of leaving it buried in the action log. After the command runs, the action calls `defang services --json` and:

- writes a table of deployed services (public endpoints as links, internal services as code) to the [job summary](https://github.blog/news-insights/product-news/supercharging-github-actions-with-job-summaries/), and
- exposes the primary public `https://` endpoint as the `endpoint` output.

Wire that output into the job's `environment.url` to get a clickable **"View deployment"** link on the run, the Environments tab, and the repo sidebar:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: ${{ steps.deploy.outputs.endpoint }}
    permissions:
      contents: read
      id-token: write
    steps:
      # [...]
      - name: Deploy
        id: deploy
        uses: DefangLabs/defang-github-action@v2
        with:
          command: "compose up"
```

Unlike `capture-output`, this writes straight to the job summary (1 MiB per step) rather than through the size-limited step-output channel, and `defang services` output is small and bounded — so it is safe even for large deployments where `capture-output` is disabled.

Set `summary: "false"` to skip the summary, or `summary: "true"` to force it for commands other than `compose up`.

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
    environment:
      name: production
      url: ${{ steps.deploy.outputs.endpoint }}
    permissions:
      contents: read
      id-token: write

    steps:
      - name: Checkout Repo
        uses: actions/checkout@v4

      - name: Deploy
        id: deploy
        uses: DefangLabs/defang-github-action@v2
        with:
          cli-version: v3.5.2
          config-env-vars: "API_KEY DB_CONNECTION_STRING"
          cwd: "./test"
          compose-files: "./docker-compose.yaml"
          mode: "balanced" # deprecated in favor of stack:
          provider: "aws"  # deprecated in favor of stack:
          stack: "production"
          command: "compose up"
          verbose: true
        env:
          API_KEY: ${{ secrets.API_KEY }}
          DB_CONNECTION_STRING: ${{ secrets.DB_CONNECTION_STRING }}
```
