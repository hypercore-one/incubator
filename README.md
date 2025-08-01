# HyperCore One Incubator

The **HyperCore One Incubator** enables pillars and proposers in the HyperCore ecosystem to collaborate on off-chain funding by pledging support to proposals before on-chain grants.
It complements the on-chain grant system by allowing faster funding signals and tactical project proposals via Nostr events.

## Purpose

On-chain grants have long voting periods and are not ideal for rapid iteration or tactical project validation.
The Incubator enables:

- Proposers to publish proposals, tasks, and bounties via Nostr events
- Pillars to browse, review, and publicly pledge support to specific items
- Transparency into pledges and activity through a public interface

## Features (WIP)

- Stores known pillars (e.g. chain rpc or api to update)
- Connects to configurable nostr relays
- Registers pillar npubs by indexing nostr events with pillar signature
- Whitelists configurable proposer npubs
- Tracks proposers' projects, tasks, and bounties by indexing nostr events
- Tracks pillar pledges to projects with ability to overfund by indexing nostr events
- Displays read-only web ui
- Integrates with on-chain grant contracts (e.g. chain rpc or api to update project status based on AZ status)

## Tech Stack

- Frontend: Nuxt 4 + Vue 3 + TypeScript
- Tooling: ESLint, Prettier, Cucumber.js for BDD
- ORM: Drizzle (designed to support both SQLite for development and Postgres for production)
- Messaging: Nostr relays

## Development Setup
          
- Install [Node.js](https://nodejs.org/en/download) and [pnpm](https://pnpm.io/installation)
- Install dependencies by running `pnpm install`
- Run the app with `pnpm dev -o`

## Linting & Formatting

```bash
# Check for linting issues
pnpm lint

# Fix linting issues automatically
pnpm lint:fix

# Format code with Prettier
pnpm prettier
```

The project uses [ESLint](https://eslint.org/) with [@nuxt/eslint](https://github.com/nuxt/eslint) and [Prettier](https://prettier.io/) with [eslint-config-prettier](https://github.com/prettier/eslint-config-prettier) and [eslint-plugin-prettier](https://github.com/prettier/eslint-plugin-prettier).

[Husky](https://typicode.github.io/husky/) and [lint-staged](https://github.com/lint-staged/lint-staged) automatically run linting on staged files before commits.

To skip Git hooks:

```bash
git commit -m "..." -n  # Skips Git hooks
```

## Editor Setup

Recommended extensions:

- [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
- [Vue](https://marketplace.visualstudio.com/items?itemName=Vue.volar)
- [Tailwind CSS](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)

## License

This project is licensed under the [MIT License](LICENSE).
