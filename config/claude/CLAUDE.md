# Core Tenets

- Prefer keeping comments to 2 lines max to help human readability.

- Always use the "lytxread" role when connecting to AWS unless told otherwise or elevated priviliges are required.
- Always ask before making a change to AWS or Kubernetes
- Always refer brevity and conciseness.
- Always use "aws-vault" when connecting to AWS.
- Always use "kubectl --context" with existing profile when connecting to clusters.

- Never create new profiles in ~/.kube/config. It pollutes configurations.
- Never use "aws sso login" to connect to an AWS account. It leaves credentials in plaintext.
