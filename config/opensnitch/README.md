# OpenSnitch rules for Hermes

OpenSnitch evaluates rules in alphabetical order by name. A matching deny/reject rule, or a matching rule with `precedence: true`, wins immediately. The `000-`/`001-`/`002-` prefixes sort these before any rules created from pop-ups.

| Rule | Effect |
|---|---|
| `000-hermes-allow-local` | Any Hermes process may reach localhost (the model server and the local DNS stub) |
| `001-hermes-allow-search` | Only the `scout` profile may reach DuckDuckGo, Brave, Mojeek, Startpage and Wikipedia |
| `002-hermes-reject-rest` | All other Hermes traffic is rejected (instant failure rather than a timeout) |

Before installing, replace `USERNAME` with your Linux username:

```fish
sed -i "s/USERNAME/$USER/" *.json
```

The process path is matched with a regex because Hermes' bundled Python lives in a directory whose name changes with each release.

Temporarily disable `002` when running `hermes update`, since updates need GitHub.
