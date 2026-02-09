############################
# TERRAFORM
############################

# Scan using trivy https://github.com/aquasecurity/trivy
# ------------------------------------------------------------------------------

trivy config . 
trivy config  --format table --exit-code  0 --severity  UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL  .

# Scan using checkov https://github.com/bridgecrewio/checkov
# ------------------------------------------------------------------------------
checkov -h
# Scan only terraform files
checkov -d . --output cli --output sarif --output-file-path console,results.sarif --soft-fail    

# Scan using terrascan https://github.com/tenable/terrascan
# ------------------------------------------------------------------------------
terrascan -h
terrascan scan -d .

# Scan using snyk https://github.com/snyk/cli
# ------------------------------------------------------------------------------
snyk -h
snyk auth
snyk iac test --help
SNYK_TOKEN=1a0bee11-920a-477a-9c9f-3dcf40b26a41
snyk config set api=$SNYK_TOKEN
snyk iac test . --sarif


############################
# DOCKER
############################

# Generate docker image and run the container
docker build -t apache .

# Scan with Scout (Free only local)
docker scout quickview # Needs the image already built
docker scout cves <IMAGE_NAME>
docker scout recommendations <IMAGE_NAME>

# Run the container
docker run -p 8080:80 apache

# Trivy
trivy image apache 
trivy image apache --exit-code 0 --format sarif > trivy-results.sarif

# Snyk
snyk auth
snyk container test apache

# Checkov
checkov --framework=dockerfile -f Dockerfile -o sarif

# Grype
grype docker:apache

############################
# KUBERNETES
############################

# kube-score
# ---------------------------------------------------------------------------------
kube-score score manifests/*.yaml
kube-score score manifests/*.yaml --output-format sarif > kube-score-results.sarif

# Kubescape
# ---------------------------------------------------------------------------------
kubescape scan manifests/*.yaml
kubescape scan manifests/*.yaml --format sarif

# Kubeaudit
# ---------------------------------------------------------------------------------
kubeaudit all -f manifests/*.yaml
kubeaudit all -f manifests/*.yaml --format sarif
kubeaudit autofix -f manifests/*.yaml

# Trivy
# ---------------------------------------------------------------------------------
trivy config manifests/
trivy config manifests/ --format sarif

# Checkov
# ---------------------------------------------------------------------------------
checkov -d manifests/

# Snyk
# ---------------------------------------------------------------------------------
# Load .env
set -o allexport; source .env; set +o allexport

snyk config set api=$SNYK_TOKEN
snyk iac test manifests/*.yaml