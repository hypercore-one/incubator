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

## License

This project is licensed under the [MIT License](LICENSE).

