# Database Schema Specification

This document outlines the database schema for the HyperCore One Incubator, focusing on pillars, items (projects, tasks, bounties), and pledges.

## Tables

### Pillars

The `pillars` table stores information about pillars in the HyperCore Incubator ecosystem.

```sql
CREATE TABLE pillars (
  id SERIAL PRIMARY KEY,
  npub VARCHAR(64) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  address VARCHAR(40) NOT NULL,
  registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
);
```

### Items

The `items` table stores bounties for tasks that can be pledged to by pillars. An item can either be Project with child Tasks or an individual Bounty.

```sql
-- Create ENUM types for item status and type
CREATE TYPE item_status_enum AS ENUM ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');
CREATE TYPE item_type_enum AS ENUM ('PROJECT', 'TASK', 'BOUNTY');
CREATE TYPE item_funding_currency_enum AS ENUM ('ZNN', 'QSR');

CREATE TABLE items (
  id SERIAL PRIMARY KEY,
  parent_item_id INTEGER REFERENCES items(id),
  nostr_event_id VARCHAR(64) UNIQUE
  proposer_npub VARCHAR(64) NOT NULL,
  type item_type_enum NOT NULL DEFAULT 'BOUNTY',
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  funding_target DECIMAL(18, 8) NOT NULL,
  funding_currency VARCHAR(10) NOT NULL DEFAULT 'ZNN',
  status item_status_enum NOT NULL DEFAULT 'OPEN',
  deadline TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
);

CREATE INDEX idx_items_proposer ON items(proposer_npub);
CREATE INDEX idx_items_parent ON items(parent_item_id);
CREATE INDEX idx_items_type ON items(type);
CREATE INDEX idx_items_status ON items(status);
```

### Pledges

The `pledges` table tracks pledges made by pillars to specific items.

```sql
-- Create ENUM type for pledge status
CREATE TYPE pledge_status_enum AS ENUM ('PLEDGED', 'FULFILLED', 'CANCELLED');
CREATE TYPE pledge_currency_enum AS ENUM ('ZNN', 'QSR');

CREATE TABLE pledges (
  id SERIAL PRIMARY KEY,
  pillar_id INTEGER NOT NULL REFERENCES pillars(id),
  item_id INTEGER NOT NULL REFERENCES items(id),
  nostr_event_id VARCHAR(64) UNIQUE,
  amount DECIMAL(18, 8) NOT NULL,
  currency pledge_currency_enum NOT NULL DEFAULT 'ZNN',
  status pledge_status_enum NOT NULL DEFAULT 'PLEDGED',
  message TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT unique_pillar_item UNIQUE (pillar_id, item_id)
);

CREATE INDEX idx_pledges_pillar ON pledges(pillar_id);
CREATE INDEX idx_pledges_item ON pledges(item_id);
CREATE INDEX idx_pledges_status ON pledges(status);
```

## Relationships

1. **Items to Items** (Self-referential):
   - An item can have a parent item (for hierarchical organization of tasks)
   - This allows for nesting of items (e.g., a project can contain multiple tasks)

2. **Pillars to Pledges**:
   - One-to-many relationship: A pillar can make multiple pledges
   - Each pledge is associated with exactly one pillar

3. **Items to Pledges**:
   - One-to-many relationship: An item can receive multiple pledges
   - Each pledge is associated with exactly one item

## Constraints

1. **Unique Constraints**:
   - Pillar npubs must be unique
   - Nostr event IDs must be unique for both items and pledges
   - A pillar can only have one active pledge per item

2. **Foreign Key Constraints**:
   - `pledges.pillar_id` references `pillars.id`
   - `pledges.item_id` references `items.id`
   - `items.parent_item_id` references `items.id` (self-referential)

3. **ENUM Types**:
   - Item status is restricted to: 'OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
   - Item type is restricted to: 'PROJECT', 'TASK', 'BOUNTY'
   - Item funding currency is restricted to: 'ZNN', 'QSR'
   - Pledge status is restricted to: 'PLEDGED', 'FULFILLED', 'CANCELLED'
   - Pledge currency is restricted to: 'ZNN', 'QSR'

## Indexes

1. Indexes on foreign keys for performance:
   - `idx_items_proposer` on `items.proposer_npub`
   - `idx_items_parent` on `items.parent_item_id`
   - `idx_items_type` on `items.type`
   - `idx_items_status` on `items.status`
   - `idx_pledges_pillar` on `pledges.pillar_id`
   - `idx_pledges_item` on `pledges.item_id`
   - `idx_pledges_status` on `pledges.status`

## Notes

- The schema supports the hierarchical organization of items (projects can contain tasks or be a standalone bounty)
- Multiple pillars can pledge to the same item
- The system tracks Nostr event IDs to maintain synchronization with Nostr events
- Timestamps are maintained for creation and updates to all records