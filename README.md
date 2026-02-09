# scan-vulnerabilities

Reference repository to automate security scans for **Docker**, **Kubernetes**, and **Terraform** using GitHub Actions, with results published to **GitHub Code Scanning** (SARIF format).

## Objective

Centralize and reuse vulnerability and misconfiguration scanning pipelines (IaC/container) to:

- detect risks early in `pull_request` and `push` to `main`
- standardize tools and reporting
- consolidate findings in the GitHub **Security** tab

## Included Tools

### Docker
- Checkov (`.github/workflows/docker/checkov.yaml`)
- Grype (`.github/workflows/docker/grype.yaml`)
- Snyk (`.github/workflows/docker/snyk.yaml`)
- Trivy (`.github/workflows/docker/trivy.yaml`)

### Kubernetes
- Checkov (`.github/workflows/kubernetes/checkov.yaml`)
- Kube-score (`.github/workflows/kubernetes/kube-score.yaml`)
- Kubeaudit (`.github/workflows/kubernetes/kubeaudit.yaml`)
- Kubescape (`.github/workflows/kubernetes/kubescape.yaml`)
- Snyk (`.github/workflows/kubernetes/snyk.yaml`)
- Trivy (`.github/workflows/kubernetes/trivy.yaml`)

### Terraform
- Checkov (`.github/workflows/terraform/checkov.yaml`)
- Snyk (`.github/workflows/terraform/snyk.yaml`)
- Terrascan (`.github/workflows/terraform/terrascan.yaml`)
- Trivy (`.github/workflows/terraform/trivy.yaml`)

## Repository Structure

```text
.github/workflows/
  docker/
    all-scans.yaml
    checkov.yaml
    grype.yaml
    snyk.yaml
    trivy.yaml
  kubernetes/
    all-scans.yaml
    checkov.yaml
    kube-score.yaml
    kubeaudit.yaml
    kubescape.yaml
    snyk.yaml
    trivy.yaml
  terraform/
    all-scans.yaml
    checkov.yaml
    snyk.yaml
    terrascan.yaml
    trivy.yaml
steps.sh
```

## How CI Works

- Each scanner is defined as a reusable workflow with `on: workflow_call`.
- Each domain has an `all-scans.yaml` aggregator that runs all scanners.
- Aggregators are triggered on:
  - `push` to `main` (ignoring changes only in `README.md`)
  - `pull_request` to `main`
  - manual execution (`workflow_dispatch`)

## Requirements

- GitHub Actions enabled in the consumer repository.
- Permissions required to upload SARIF:
  - `contents: read`
  - `security-events: write`
- `SNYK_TOKEN` secret for workflows that use Snyk:
  - Docker Snyk
  - Kubernetes Snyk
  - Terraform Snyk

## Reusable Workflow Usage

Example usage from another repository:

```yaml
name: Security Scans

on:
  pull_request:
  push:
    branches: [main]

jobs:
  terraform-scans:
    permissions:
      contents: read
      security-events: write
    uses: jagc108/scan-vulnerabilities/.github/workflows/terraform/all-scans.yaml@main
    secrets:
      SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

You can also invoke an individual scanner and pass `inputs` (for example `working-directory`, `image_name`, `dockerfile_path`, `context`, depending on the workflow).

## Local Execution (Quick Reference)

The `steps.sh` file includes useful commands for local testing with Trivy, Checkov, Terrascan, Snyk, Grype, Kube-score, Kubescape, and Kubeaudit.

Example:

```bash
trivy config .
checkov -d . --output cli --output sarif --output-file-path console,results.sarif --soft-fail
terrascan scan -d .
```

## Output and Results

- Scans generate SARIF files (`results.sarif`, `trivy-results.sarif`, `snyk-iac.sarif`, etc.).
- SARIF files are uploaded using `github/codeql-action/upload-sarif`.
- Findings are available in **Security -> Code scanning alerts**.
