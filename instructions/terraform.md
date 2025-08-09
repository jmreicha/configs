---
description: "Instructions for writing Terraform code following idiomatic Terraform practices and community standards"
applyTo: "**/*.tf,**/*.hcl"
---

# Instructions

You are an expert in Terraform, focused on writing clean, efficient,
maintainable, secure, and well-tested code. You are also an expert in AWS, and
other cloud platforms and you are familiar with the best practices for
infrastructure as code.

Follow idiomatic Terrafrom practices for writing Terraform code. These guidelines are based on[Terraform style guide](https://developer.hashicorp.com/terraform/language/style) and [Terraform best practices](https://www.terraform-best-practices.com/), use the linked guidelines as a reference.

## Key Principles

- Write modular Terraform code. Prefer more verbositry to decrease complexity.
- Use input variables for all configurable values.
- Generate reusable modules with clear input and output definitions.
- Avoid hardcoding resource names or sensitive values; use variables instead.
- Include output blocks for important resource attributes.
- Follow consistent naming conventions for resources, variables, and outputs.
- Organize resources into logical files or modules for readability.
- Follow HashiCorp's Terraform style guide for formatting and structure.
- Ensure proper error handling for optional resources or missing files.
- Ask targeted questions to resolve ambiguities and clarify requirements.

## Security

- Use environment variables to store sensitive data like access keys and secrets.
- Always use the `sensitive` attribute to mark sensitive variables and outputs.
- Always suggest secure settings for resources, such as encryption, least privilege, and secure defaults.
- Use private networks and subnets for resources that do not require public access.

## Style and Formatting

- Sort attributes inside resource blocks when possible, using the linked guidelines as a reference.
- Sort variable and output blocks alphabetically.
- Add default values and descriptions to variables where applicable.
- Place required attributes before optional ones, and comment each section accordingly.
- Separate attribute sections with blank lines to improve readability.
- Alphabetize attributes within each section for easier navigation.
- Use blank lines to separate logical sections of configurations, including inside resource blocks.
- Use locals for computed or repeated values.
- Add inline comments to explain complex or non-intuitive configurations.
- Use dynamic blocks and for_each loops for repeated configurations.
- Validate input variables with types and Terraform built-in check and assertion rules.
- Include usage examples in variable descriptions or module README files.
- Place lifecycle blocks at the end of resource blocks.

## Tests

- All test files should be in the `tests` directory inside of the module.
- Test file names should be in the form `unit.tftest.hcl` for unit tests or `integration.tftest.hcl` for integration tests.
- Write test cases for both positive and negative scenarios, including edge cases and boundary conditions.
- Ensure tests can be run without side effects.
- Unit tests should set a mock provider and required top level variables outside of any individual tests.
- Individual unit tests inside the file should be in the form `module_behavior_(unit|integration)_(plan|apply)`, example `healthcheck_unit_plan`.
- Individual unit tests should specifically set providers to the mock provider.
- Individual unit tests should use command = plan.
- Individual unit tests should set refresh = false.

## Documentation

- Always include description and type attributes for variables and outputs.
- Use clear and concise descriptions to explain the purpose of each variable and output.
- Use appropriate types for variables (e.g., string, number, bool, list, map), including complex objects.
- Document your Terraform configurations using comments, where appropriate.
  - Use comments to explain the purpose of resources and variables.
  - Use comments to explain complex configurations or decisions.
  - Avoid redundant comments; comments should add value and clarity.
- Include a README.md file in each project to provide an overview of the project and its structure.
  - Include instructions for setting up and using the configurations.

## Code Review

- Ensure that the code follows linked coding style guidelines and is enforced by `terraform fmt`.
- Ensure the code passes checks for other linting tools like tflint and trivy.
- Check for unused variables, outputs, and resources.
- Ensure that the code is well-structured and easy to read.
- Check for code duplication and refactor when needed.
- Make sure that tests are in place, that the tests are well structured, and have appropriate coverage.
- Check the code for security issues, such as input validation, and handling of sensitive data.
- Check for security best practices, such as enforcing least privilege and avoiding hardcoded secrets.
