# Adapting AI-Bastion to Your Agent

AI-Bastion is agent-agnostic. While examples reference OpenClaw, every layer works with any AI agent on Linux.

## Step 1: Edit Configuration

Open `configs/bastion.conf` and set your agent's data directory:

```bash
# For OpenClaw (default)
AGENT_DATA_DIR="$HOME/.openclaw"

# For Claude Code
AGENT_DATA_DIR="$HOME/.claude"

# For a custom agent
AGENT_DATA_DIR="$HOME/.my-agent"
```

## Step 2: Install Infrastructure Layers (1, 4, 5, 6, 7)

These layers work identically regardless of which agent you use:

- **Layer 1** (Network): Firewall rules protect the whole system
- **Layer 4** (Monitoring): Process and network monitors watch for threats
- **Layer 5** (Integrity): SHA-256 baseline works with any files
- **Layer 6** (SOAR): Incident response is agent-agnostic
- **Layer 7** (Hardening): OS-level security protects everything

Just run the install script and these layers work immediately.

## Step 3: Deploy Canary Tokens (Layer 2)

Canary files are placed in your agent's data directory. The install script uses `AGENT_DATA_DIR` from your config. If your agent looks in a different location for credentials, add extra canary files manually:

```bash
echo "CANARY_TOKEN=canary-DETECT-IF-READ" > /path/to/agent/data/.env.backup
```

## Step 4: Integrate Anti-Prompt Injection Rules (Layer 3)

This is the only layer that requires manual integration. You need to add the rules to your agent's system prompt.

### OpenClaw
Add the XML content from `layers/03-anti-prompt-injection/security-rules.xml` to your `SOUL.md` file.

### Claude Code
Add the rules to your `CLAUDE.md` file in the project root:
```markdown
## Security Rules
<!-- Paste the XML rules here -->
```

### LangChain / CrewAI
Include the rules in your system prompt template:
```python
with open("path/to/security-rules.xml") as f:
    security_rules = f.read()

system_prompt = f"""
You are a helpful assistant.

{security_rules}

Now respond to the user's request.
"""
```

### AutoGPT / Custom Agents
Prepend the rules to whatever system prompt your agent uses. The XML format is designed to be parsed by any LLM.

## Step 5: Customize Process Monitoring

Edit `configs/suspicious-processes.txt` to add patterns specific to your setup. For example, if your agent should never run Python:

```
python
python3
```

## Step 6: Update Integrity Baseline

After installing and configuring your agent, create a fresh integrity baseline:

```bash
bash layers/05-integrity/create-baseline.sh
```

This captures the SHA-256 hashes of your current configuration files. Any unauthorized modification will be detected.
