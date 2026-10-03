@~/.claude/RTK.md
@RTK.md

# Core Tenets

- Always ask before making potentially destructive changes to AWS, Kubernetes, GCloud or other cloud resources.
- Always lookup docs using context7 for things you aren't sure about.
- Always prefer brevity and conciseness.
- Always prefer keeping comments to 2 lines max to help human readability.
- Always use the "lytxread" role when connecting to AWS unless told otherwise or elevated priviliges are required.
- Always use "aws-vault" when connecting to AWS.
- Always use "kubectl --context" with existing profile when connecting to clusters.
- Always fetch credentials with "op read op://..." when a 1Password service account is configured. See instructions/agent-bootstrap.md.

- Never create new Kubernetes profiles in ~/.kube/config. It pollutes configurations.
- Never print or store secret values in chat, notes, memory, or files. Refer to them by op:// reference.
- Never use "aws sso login" to connect to an AWS account. It leaves credentials in plaintext.
