---
name: research
description: Use before implementing new features to gather context from documentation, real-world code examples, and web resources. Provides structured findings to inform implementation decisions.
---

# Research

This skill provides systematic multi-source research for gathering context before implementing new functionality.

## Purpose

Research enables autonomous context gathering from multiple sources to inform implementation decisions. It provides structured findings from documentation, real-world code examples, and community knowledge to maximize implementation success and minimize false starts.

## When to Use This Skill

Use this skill when:

- Planning or immplementing new features (try to use whenever possible)
- Working with unfamiliar libraries or frameworks
- Evaluating architectural approaches or design patterns
- Understanding how others solved similar problems
- Making technology selection decisions

## Research Process

### Overview

The research process follows three phases with user interaction before beginning:

1. **User Interaction** - Clarify requirements and gather documentation references
2. **Documentation Research** - Query official documentation using context7
3. **Code Examples** - Find real-world implementations using grep/searchGitHub
4. **Web Research** - Optional supplemental research using webfetch

### User Interaction

Before starting research, gather context from the user:

**Questions to ask:**

- What are the specific requirements and constraints for this feature?
- Do you have any preferred libraries or approaches?
- Are there specific documentation sources you'd like me to consult?
- What are the key priorities (performance, simplicity, maintainability)?
- What is your familiarity with this technology?

**Documentation references:**

- Request any relevant documentation links from the user
- Note any specific examples or resources the user has found
- Understand user's prior experience with similar implementations

### Documentation Research

Use the context7 MCP server to query official documentation.

**Process:**

1. Resolve library IDs for relevant packages and frameworks
2. Query documentation for APIs, configuration, and best practices
3. Note version-specific considerations and compatibility requirements
4. Focus on the specific feature being implemented

**Quick scan approach:**

- Execute 1 targeted query focused on the specific feature
- Prioritize official documentation for the exact library version in use
- Capture key API patterns and configuration requirements

**Example:**

```bash
# Resolve library ID
mcp-cli context7/resolve-library-id '{"query": "OAuth2 authentication", "libraryName": "golang.org/x/oauth2"}'

# Query documentation
mcp-cli context7/query-docs '{"libraryId": "/golang/oauth2", "query": "Google OAuth configuration and token handling"}'
```

**Fallback:**

If context7 is unavailable, document the failure and proceed with remaining phases.

**Example failure message:**

"⚠️ MCP server 'context7' unavailable (connection refused on https://mcp.context7.com/mcp) - proceeding with code example research only"

### Code Examples

Use the grep/searchGitHub MCP server to find real-world implementations.

**Process:**

1. Search for literal code patterns that would appear in files
2. Find common idioms and production-ready implementations
3. Identify error handling approaches and edge cases
4. Filter by language, repository, or file path as needed

**Quick scan approach:**

- Execute 1-2 searches (main pattern + error handling)
- Search for actual code, not keywords or prose
- Focus on recent, maintained repositories

**Search pattern guidelines:**

- Good: `oauth2.Config{`, `import "golang.org/x/oauth2"`, `TokenSource`
- Bad: `oauth tutorial`, `best practices`, `how to authenticate`

**Example:**

```bash
# Find main implementation pattern
mcp-cli grep/searchGitHub '{"query": "oauth2.Config{", "language": ["Go"]}'

# Find error handling pattern
mcp-cli grep/searchGitHub '{"query": "oauth2.TokenSource", "language": ["Go"]}'
```

**Fallback:**

If grep is unavailable, document the failure and proceed with web research or best-effort implementation.

**Example failure message:**

"⚠️ MCP server 'grep' unavailable (network timeout after 30s) - proceeding with best-effort implementation based on documentation only"

### Web Research

Use webfetch to gather supplemental context from blog posts, tutorials, discussions and other project documentation sources.

**When to use:**

- User already has an idea about what they're looking for
- MCP sources lack critical context
- Complex architectural decisions require community input
- Need to understand trade-offs between different approaches

**Quick scan approach:**

- Ask user to provide input by providing links to sources
- Execute 1-2 web fetch (only if MCP sources insufficient)
- Focus on authoritative sources (official blogs, established documentation and tutorial sites)
- Prioritize recent content within 1 year

**Example:**

```bash
# Fetch architectural guidance
webfetch https://cloud.google.com/docs/authentication
```

**Fallback:**

If webfetch fails, proceed with available research from previous phases.

### Fallback Handling

When MCP servers are unavailable:

1. Document the specific failure with details
2. Proceed with best-effort implementation using available sources
3. Notify the end user explicitly about the limitation
4. Make implementation assumptions explicit

**Failure message format:**

"⚠️ MCP server '[server]' unavailable ([specific error: connection refused, timeout, etc.]) - proceeding with [alternative approach]"

## Research Scope Guidance

Different scenarios require different research depths:

| Scenario                    | Depth      | Strategy                                   | Queries                     |
| --------------------------- | ---------- | ------------------------------------------ | --------------------------- |
| **Well-known patterns**     | Minimal    | Quick validation of current best practices | 1 doc, 1 code               |
| **Standard features**       | Quick scan | Verify common approaches and patterns      | 1 doc, 1-2 code             |
| **Novel implementations**   | Thorough   | Explore alternatives and trade-offs        | 2-3 doc, 3-4 code           |
| **Critical infrastructure** | Deep       | Understand failure modes and edge cases    | Multiple across all sources |

**Quick scan (recommended default):**

- Time budget: 2-3 minutes total
- Focus on answering specific implementation questions
- Prioritize recent, high-quality sources
- Balance thoroughness with execution speed

**Depth selection criteria:**

- User familiarity with technology
- Feature complexity and novelty
- Risk level (security, data integrity, performance)
- Availability of existing patterns in codebase

## Output Format

Produce structured findings using this template:

```markdown
## Research Summary: [Feature/Topic]

### User Context

- [Key requirements from user discussion]
- [Constraints or preferences mentioned]
- [Relevant documentation links provided by user]

### Common Patterns

- Pattern 1: [description + source]
- Pattern 2: [description + source]
- Pattern 3: [description + source]

### Trade-offs & Considerations

- **Approach A**: [pros/cons, use cases]
- **Approach B**: [pros/cons, use cases]
- **Key decisions**: [what needs to be decided and why]

### Recommended Approach

[Clear recommendation with rationale based on research and user requirements]

### Implementation Notes

- Key insight 1 from research
- Common pitfall to avoid
- Important configuration detail
- Testing/validation strategy

### Sources

- [Library docs - specific page]
- [GitHub example - repo/file:line]
- [Additional resource - blog/guide]

### MCP Status

✓ All sources available | ⚠️ [specific failure details]
```

**Output guidelines:**

- Be concise and actionable
- Provide clear rationale for recommendations
- Include source links for further exploration
- Document assumptions when data is limited
- Make MCP status explicit

## Best Practices

### Do:

- Ask user questions before starting research
- Request specific documentation links from users
- Search for literal code patterns, not keywords
- Focus on production-ready, maintained examples
- Consider version compatibility and recent changes
- Document assumptions when data is limited
- Provide source links for further exploration
- Report MCP failures specifically with error details
- Make clear recommendations with rationale

### Don't:

- Guess or assume user requirements
- Skip user interaction during planning phase
- Search for prose descriptions instead of code patterns
- Rely solely on old or unmaintained examples
- Make recommendations without rationale
- Proceed with implementation before research (unless MCP unavailable)
- Hide MCP availability issues from user
- Use vague failure messages

## Examples

### Example: Adding OAuth Authentication

**User interaction:**

```
Q: "Which OAuth provider are you planning to use?"
A: "Google OAuth, but open to suggestions"

Q: "Are there any specific documentation or libraries you prefer?"
A: "No preference, whatever is most reliable"

Q: "What are the key constraints (compliance, user experience)?"
A: "Need to be production-ready and secure"
```

**Research execution:**

1. Resolve library ID for Go OAuth libraries → `golang.org/x/oauth2`
2. Query context7: "Google OAuth configuration and token handling"
3. Search GitHub: `oauth2.Config{` with language=["Go"]
4. Search GitHub: `oauth2.TokenSource` with language=["Go"]

**Key findings:**

- Most Go projects use `golang.org/x/oauth2` standard library
- Common pattern: Middleware for token validation
- Key consideration: Token refresh and expiration handling
- Error handling: Check token validity before each request
- Configuration: Store credentials in environment variables

**Recommendation:**

Use `golang.org/x/oauth2/google` package with middleware-based token validation. This is the most widely adopted pattern in production Go applications and provides built-in token refresh handling.

### Example: Implementing Rate Limiting

**User interaction:**

```
Q: "What type of rate limiting do you need (per-user, per-IP, global)?"
A: "Per-user, based on API key"

Q: "What are your rate limit requirements?"
A: "100 requests per minute per user"

Q: "Do you need distributed rate limiting across multiple servers?"
A: "No, single server deployment"
```

**Research execution:**

1. Resolve library ID for rate limiting → `golang.org/x/time/rate`
2. Query context7: "rate limiting configuration" → ⚠️ connection timeout
3. Search GitHub: `rate.NewLimiter` with language=["Go"]
4. Search GitHub: `rate.Limiter.Allow` with language=["Go"]

**Key findings:**

- ⚠️ MCP server 'context7' unavailable (connection timeout after 30s) - proceeding with grep searches only
- Common library: `golang.org/x/time/rate` (standard library)
- Pattern: Store limiters in map keyed by API key or user ID
- Implementation: Middleware checks limiter before handler execution
- Consideration: Single-server uses in-memory map, distributed needs Redis

**Recommendation:**

Use `golang.org/x/time/rate.NewLimiter(rate.Limit(100/60), 100)` with sync.Map for storing per-user limiters. This provides efficient in-memory rate limiting suitable for single-server deployments.

### Example: CI/CD Pipeline Configuration

**User interaction:**

```
Q: "Which CI/CD platform are you using?"
A: "GitHub Actions"

Q: "What should the pipeline do?"
A: "Run tests, linting, and build on every push"
```

**Research execution:**

1. Query context7: "GitHub Actions Go workflow configuration"
2. Search GitHub: `runs-on: ubuntu-latest` with path=".github/workflows", language=["YAML"]
3. Search GitHub: `go test ./...` with path=".github/workflows"

**Key findings:**

- Common pattern: Matrix builds for multiple Go versions
- Standard steps: Checkout, setup Go, cache dependencies, test, build
- Best practice: Run linters before tests (fail fast)
- Configuration: Use actions/cache for Go module caching
- Consideration: Separate workflows for PR vs main branch

**Recommendation:**

Use GitHub Actions with matrix strategy for Go 1.21+ testing. Run golangci-lint before tests to catch issues early. Cache Go modules to speed up builds. This pattern is standard across open-source Go projects.

## Integration with Planning

When planning feature implementation:

1. **Start with research skill** (try to use whenever possible)
2. Ask user clarifying questions about requirements
3. Request any specific documentation references from user
4. Execute research phases (documentation → code examples → web)
5. Present structured findings with clear recommendations
6. Get user approval on recommended approach
7. Proceed to implementation planning with research context

Research findings should directly inform:

- Library, pattern or framework selection decisions
- Architecture and design patterns
- Error handling and edge case strategies
- Testing approaches and validation methods
- Documentation structure and examples

## Summary

The research skill provides:

- Systematic multi-source context gathering before implementation
- User-driven requirements clarification and documentation input
- Structured, actionable findings with source references
- Clear rationale for implementation recommendations
- Transparency about data availability and MCP status
- Quick scan approach balancing thoroughness with speed

Use this skill at the start of any feature planning to maximize implementation success and minimize false starts. The goal is to gather diverse perspectives and proven patterns to inform better implementation decisions.
