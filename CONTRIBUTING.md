# Contributing

## Releasing a New Version

Push a tag in `vMAJOR.MINOR.PATCH` format (e.g. `v1.2.3`) pointing to the commit on `main` you want to release, using either:

- **Git CLI:**
  ```sh
  git tag v1.2.3
  git push origin v1.2.3
  ```

- **GitHub web UI:** Go to the [New Release](https://github.com/DefangLabs/defang-github-action/releases/new) page. In the **Choose a tag** dropdown, type the new tag (e.g. `v1.2.3`) and select **Create new tag on publish**. Set the target to `main`, then click **Publish release**.

The [release workflow](.github/workflows/release.yaml) triggers automatically on the new tag and will:
- Update the floating `vMAJOR` and `vMAJOR.MINOR` tags (e.g. `v1` and `v1.2`) to point at the new commit.
- Create a GitHub Release with auto-generated notes, marked as **latest** only if the new tag is the highest semver across all existing releases. This step is skipped if the release already exists (e.g. when using the web UI), in which case whatever **latest** setting was chosen in the web UI is preserved.
