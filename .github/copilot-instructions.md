# Defang GitHub Action

Defang GitHub Action is a composite GitHub Action that enables deployment of applications using the [Defang CLI](https://defang.io/). The action supports deployment to both the Defang Playground and your own AWS account using Docker Compose-based projects.

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Prerequisites and Setup
- **No build step required** - This is a composite GitHub Action using shell scripts only
- Node.js v20+ is required for testing the test application
- Docker is required for container testing and builds
- The action installs the Defang CLI automatically via curl script

### Testing the Action
- Run the test Node.js application:
  ```bash
  cd test
  export PORT=3000
  export DEFANG_GH_ACTION_TEST_MESSAGE="Hello from test"
  node index.js
  # Test with: curl http://localhost:3000
  ```

- Build and test the Docker container:
  ```bash
  cd test
  docker build -t test-app .  # Takes ~20 seconds for initial build, use cached layers after
  docker run --rm -d -p 3001:3000 -e PORT=3000 -e DEFANG_GH_ACTION_TEST_MESSAGE="Hello from Docker" test-app
  # Test with: curl http://localhost:3001
  docker stop $(docker ps -q --filter ancestor=test-app)
  ```

- Test with Docker Compose:
  ```bash
  cd test
  docker compose up -d  # Uses cached image if already built
  # Test with: curl http://localhost:3000
  docker compose down
  ```

### Defang CLI Installation Testing
**WARNING**: Defang CLI installation may fail due to GitHub API rate limits in testing environments.
- The installation script downloads from GitHub releases: `curl -Lf https://raw.githubusercontent.com/DefangLabs/defang/main/src/bin/install`
- Installation typically takes 10-30 seconds when successful
- **NEVER CANCEL** the installation process - wait for completion or explicit error
- In CI environments, the action sets `GH_TOKEN` to avoid rate limits

### Running GitHub Action Tests
- The CI workflow runs dry-run deployments to validate the action
- Tests use `continue-on-error: true` because dry runs are expected to "fail"
- Test scenarios:
  1. Deploy with config environment variables
  2. Deploy with empty parameters and staging mode
  3. Teardown configuration

Run tests locally using act or by checking out and testing individual components:
```bash
# Test the action steps manually (requires GITHUB_TOKEN)
export GH_TOKEN="your-token"
export DEFANG_PROVIDER="defang"
export DEFANG_DEBUG="1"

# This would normally be done by the action:
. <(curl -Lf https://raw.githubusercontent.com/DefangLabs/defang/main/src/bin/install || echo return $?)
defang login  # Requires interactive authentication
defang whoami
```

## Validation

### Manual Testing Requirements
**CRITICAL**: Always manually validate changes by running complete scenarios:

1. **Test the Node.js Application**:
   ```bash
   cd test
   export PORT=3000 DEFANG_GH_ACTION_TEST_MESSAGE="Test message"
   node index.js &
   sleep 2
   curl http://localhost:3000  # Should return "Test message"
   kill %1
   ```

2. **Test Docker Build and Run**:
   ```bash
   cd test
   docker build -t test-app .
   docker run --rm -p 3001:3000 -e PORT=3000 -e DEFANG_GH_ACTION_TEST_MESSAGE="Docker test" test-app &
   sleep 3
   curl http://localhost:3001  # Should return "Docker test"
   docker stop $(docker ps -q --filter ancestor=test-app)
   ```

3. **Test Action Configuration**:
   - Verify `action.yaml` syntax is valid
   - Ensure all input parameters are properly defined
   - Test shell script syntax in the composite action steps

### Timing Expectations
- **Node.js app startup**: < 1 second
- **Docker build (initial)**: 15-25 seconds - **NEVER CANCEL**
- **Docker build (cached)**: < 5 seconds
- **Defang CLI installation**: 10-30 seconds - **NEVER CANCEL**
- **Container startup**: 2-5 seconds

### Before Committing Changes
**Always run these validation steps before committing**:

1. Test the Node.js application works correctly
2. Verify Docker builds complete successfully  
3. Validate action.yaml syntax
4. Test any shell script changes in the action steps
5. Ensure the test compose files are valid

**No traditional linting required** - this is a shell-script based GitHub Action.

## Common Tasks

### Repository Structure
```
.
├── .github/
│   └── workflows/
│       └── test.yaml           # CI workflow that tests the action
├── test/                       # Test application directory
│   ├── Dockerfile             # Node.js container definition
│   ├── compose.yaml           # Main compose file
│   ├── compose.prod.yaml      # Production compose overlay
│   └── index.js               # Simple HTTP server for testing
├── action.yaml                # Main GitHub Action definition
├── README.md                  # Usage documentation
└── LICENSE                    # MIT license
```

### Key Action Inputs
- `cli-version`: Defang CLI version (default: latest)
- `config-env-vars`: Environment variables to deploy as config
- `cwd`: Working directory (default: ".")
- `compose-files`: Compose files to use (space-separated)
- `mode`: Deployment mode (development/staging/production)
- `provider`: Cloud provider (aws/defang/digitalocean)
- `command`: Command to run (default: "compose up")

### Action Workflow Steps
1. **Install defang**: Downloads and installs Defang CLI
2. **Set environment variables**: Configures provider and debug settings
3. **Login to Defang**: Authenticates with Defang service
4. **Set configuration**: Deploys environment variables as secure config
5. **Run command**: Executes the specified Defang command

### Testing Patterns
The action is tested using dry-run deployments:
- `defang compose up --dry-run` validates configuration without deployment
- Multiple scenarios test different parameter combinations
- Configuration cleanup ensures no state leakage between test runs

### Common Issues and Solutions
- **Rate limit errors**: Use `GH_TOKEN` environment variable for CLI installation
- **Port conflicts**: Change port mappings when testing locally
- **Authentication failures**: Defang CLI requires interactive login for actual deployments
- **Compose file errors**: Validate YAML syntax and Docker Compose specification compliance

### Development Workflow
1. Make changes to action.yaml or test files
2. Test locally using the validation steps above
3. Verify CI workflow passes with your changes
4. The action itself requires no build step - changes are immediately testable

## Troubleshooting

### If Tests Fail
- Check action.yaml syntax using YAML validator
- Verify shell script syntax in action steps
- Test Docker builds complete successfully
- Ensure test application responds correctly
- Review CI logs for specific error details

### If Defang CLI Installation Fails
- Check GitHub API rate limits
- Verify internet connectivity
- Set GH_TOKEN environment variable
- Wait for transient network issues to resolve

This repository contains a working GitHub Action that requires no build process, only validation testing.