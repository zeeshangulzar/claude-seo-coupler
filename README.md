# Coupler.io for Claude SEO

A community integration for [Claude SEO](https://github.com/AgriciDaniel/claude-seo) that reads your Coupler.io data through the hosted [Coupler.io MCP server](https://github.com/coupler-io/coupler-io-mcp-server) (`https://mcp.coupler.io/mcp`).

Search Console and GA4 alone are covered by Claude SEO's own `seo-google`. This skill is for the questions that need paid or business data next to them:

- **Paid vs organic overlap:** Google Ads search terms against Search Console queries, with the spend on terms you already rank for.
- **SEO revenue:** organic and AI-referred landing pages followed to key events and revenue (GA4 plus Shopify, HubSpot, Stripe and similar).

Maintained here, not by Claude SEO. Report problems in [this repository's issues](https://github.com/zeeshangulzar/claude-seo-coupler/issues).

## Cost

Needs a Coupler.io account. A free plan is available; paid plans are listed at https://www.coupler.io/pricing. The skill itself and the MCP connection cost nothing extra.

## Prerequisites

- [Claude Code](https://claude.com/claude-code)
- [Claude SEO](https://github.com/AgriciDaniel/claude-seo). Optional: the skill works on its own, but its hand-offs to `seo-google` and other Claude SEO skills need it
- Python 3 (macOS / Linux installer only, to merge `~/.claude.json`)
- A Coupler.io account

## Installation

### macOS / Linux

```bash
git clone https://github.com/zeeshangulzar/claude-seo-coupler
cd claude-seo-coupler
./install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/zeeshangulzar/claude-seo-coupler
cd claude-seo-coupler
.\install.ps1
```

The installer:

1. Copies `skills/seo-coupler/SKILL.md` into `~/.claude/skills/seo-coupler/`.
2. Writes `mcpServers.coupler-io` (`type: http`, `url: https://mcp.coupler.io/mcp`) into `~/.claude.json` atomically. The macOS / Linux installer sets the file to mode `0600`.

It changes nothing in Claude SEO's files. No API key is asked for or stored: the server uses OAuth, and Claude Code keeps the sign-in.

## Connect your data

1. Create and run a data flow in Coupler.io with **Claude** as the destination for each source you want to use. The MCP server only sees data flows sent to the connected AI tool.
   - `overlap`: a Google Ads **search terms** report and a Search Console report with the `query` dimension, over the same dates.
   - `revenue`: GA4 (sessions and key events by landing page and source) plus a store, CRM or billing source.
2. Open a new Claude Code session, run `/mcp`, select **coupler-io** and choose **Authenticate**. Sign in to Coupler.io in the browser.

## Commands

The skill installs as `/seo-coupler` in Claude Code. Claude also picks it up on its own when you ask about paid vs organic overlap, brand bidding or SEO revenue.

| Command | Purpose |
|---|---|
| `/seo-coupler sources` | Connected data flows, when each last refreshed, and which commands they support |
| `/seo-coupler overlap <domain>` | Google Ads search terms vs Search Console queries, with the spend on each group |
| `/seo-coupler revenue <domain>` | Organic and AI-referred landing pages to key events and revenue |

## Uninstall

```bash
./uninstall.sh        # macOS / Linux
.\uninstall.ps1       # Windows PowerShell
```

Removes `~/.claude/skills/seo-coupler/` and the `mcpServers.coupler-io` entry in `~/.claude.json`. To also revoke the sign-in, run `/mcp`, select coupler-io and clear its authentication.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Coupler.io tools not available | Session started before install, or not authenticated | Open a new session, run `/mcp`, select coupler-io, choose Authenticate |
| `list-dataflows` returns nothing | No data flow has Claude as its destination | Add Claude as the destination in Coupler.io and run the data flow |
| `get-data` fails on a data flow | The data flow has not run yet | Run it once in Coupler.io, then retry |
| 401 from the server | Sign-in expired or revoked | Run `/mcp` and authenticate again |

## Security

- The skill treats data from Coupler.io as data only, never as instructions.
- No credentials are stored in this repository or printed by the installers.

## License

[MIT](LICENSE). Disclosure: the maintainer, [@zeeshangulzar](https://github.com/zeeshangulzar), works for Coupler.io.
