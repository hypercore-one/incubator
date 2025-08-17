# Kind 3001: Proposals

| Property | Value |
| --- | --- |
| Kind Number | 3001 |
| Event Range | Regular (non-replaceable) |
| Status | Draft |
| Depends on | [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md), [NIP-27](https://github.com/nostr-protocol/nips/blob/master/27.md), [NIP-73](https://github.com/nostr-protocol/nips/blob/master/73.md) |

This document specifies a Nostr event for publishing and updating Proposals within the HyperCore One Incubator ecosystem. It binds a proposal's state changes to a Nostr public key (`pubkey`) and defines how clients discover, select, and validate updates.

This is a **regular, non-replaceable event**. A full history of proposal events is maintained to provide an audit trail. Updates are managed via a sequentially increasing `event_number` and MUST be authored by the same `pubkey` as the genesis event.

This specification incorporates [NIP-73](https://github.com/nostr-protocol/nips/blob/master/73.md) for optional external identifiers and discoverability.

## Content Format

The `content` field SHOULD contain a human-readable Markdown description of the proposal. Title and numeric metadata are provided in tags.

Schema:

```json
"content": "<markdown description of the proposal>"
```

- Use NIP-27 references (`nostr:...`) inside `content` if needed.
- Do not embed HTML in Markdown.

## Event Structure

```json
{
  "id": "<32-bytes lowercase hex-encoded sha256 of the serialized event data>",
  "pubkey": "<32-bytes lowercase hex-encoded public key of the event creator>",
  "created_at": <unix_timestamp>,
  "kind": 3001,
  "tags": [
    ["event_number", "<sequential number as string>"],
    ["title", "<short title>"],
    ["minZNN", "<decimal string>"] ,
    ["minQSR", "<decimal string>"],
    ["status", "<0|1|2|3>"],
    ["t", "<hashtag>"] ,
    ["i", "<external-id-per-nip73>"],
    ["k", "<external-id-kind-per-nip73>"],
    ["e", "<proposal genesis event id (required on updates) or other referenced event id>"]
  ],
  "content": "<markdown>",
  "sig": "<64-bytes lowercase hex of the signature of the sha256 hash of the serialized event data>"
}
```

## Tags

| Tag Name | Description | Example Format | Required |
|----------|-------------|----------------|----------|
| `event_number` | Event number for updates; must strictly increase for events that reference the same proposal (genesis id) | `["event_number", "1"]` | Yes. Genesis event MUST use `1`. |
| `title` | Short title of the proposal | `["title", "This is an example title"]` | Yes |
| `minZNN` | Minimum ZNN target as decimal string | `["minZNN", "5000"]` | Recommended |
| `minQSR` | Minimum QSR target as decimal string | `["minQSR", "50000"]` | Recommended |
| `status` | Numeric status code | `["status", "0"]` | Yes |
| `t` | Topic hashtag(s) | `["t", "flutter", "android"]` | Optional |
| `i`/`k` | NIP-73 external content ID and kind (e.g., external url) | `["i", "https://example.com/proposal"], ["k", "web"]` | Optional |
| `e` | Proposal genesis event id (required on updates). MAY include an additional, repeated `e` to the previous update. | `["e", "<event_id>"]` | Updates only |

### Notes on proposal identity
- The proposal identity is the id of the genesis event (`event_number == "1"`).
- Genesis event MUST NOT include any `e` tag.
- Updates MUST include an `e` tag referencing the genesis id; they MAY include an additional `e` to the immediate previous update.

### Status mapping
- `0`: OPEN
- `1`: IN_PROGRESS
- `2`: COMPLETED
- `3`: CANCELLED

## Client Behavior

To create or update a Proposal, clients MUST:

1. Author binding
   - Treat the author `pubkey` as the owner. Only events signed by the same `pubkey` can update a proposal.

2. Creation
   - New proposal: publish with `event_number == "1"` and no `e` tags.

3. Updates
   - Updates MUST include at least one `e` tag that references the genesis event id.
   - Updates MAY include a second `e` tag that references the immediate previous update (event_number - 1).
   - Only accept updates from the same `pubkey` as the original owner.
   - For a given genesis id, accept only if `event_number` is strictly greater than the last known `event_number`.
   - Ignore if `event_number` is lower or equal, or if the required `e` tag to genesis is missing.

4. Recommended fields
   - Each update SHOULD include the full current values for `title`, `minZNN`, `minQSR`, `status`, and `content` (i.e., include all tags even if a particular value did not change). Clients SHOULD render the event with the highest `event_number` for the proposal.
   - Use `t` for discoverability and NIP-73 `i`/`k` to associate external ids (e.g., external resources, chain addresses or txs).

## Relay Behavior

- Treat Kind 3001 events as regular events (NIP-01). No special validation beyond standard event validation.
- Single-letter tags (e.g., `e`, `t`) are indexable and can be used in filters like `{"#e":["<genesis_id>"]}`.

## Filtering Examples

- Latest by author: `{"kinds":[3001],"authors":["<pubkey>"]}`
- By proposal (genesis id): `{"kinds":[3001],"#e":["<genesis_id>"]}`
- By hashtag/topic: `{"kinds":[3001],"#t":["syrius"]}`

## Example Events

### 1) Create (no `e` tags on genesis)

```json
{
  "id": "f1f2ab00ccddeeff00112233445566778899aabbccddeeff0011223344556677",
  "pubkey": "6e468422dfb74a5738702a8823b9b28168abab8655faacb6853cd0ee15deee93",
  "created_at": 1710000000,
  "kind": 3001,
  "tags": [
    ["event_number", "1"],
    ["title", "Redesign syrius dashboard"],
    ["minZNN", "5000"],
    ["minQSR", "50000"],
    ["status", "0"],
    ["t", "zenon"]
  ],
  "content": "This proposal describes a redesigned syrius dashboard...",
  "sig": "908a15e46fb4d8675bab026fc230a0e3542bfade63da02d542fb78b2a8513fcd0092619a2c8c1221e581946e0191f2af505dfdf8657a414dbca329186f009262"
}
```

### 2) Update (with `e` to genesis, higher `event_number`, same author)

```json
{
  "id": "aa32cc00ddeeff11223344556677889900aabbccddeeff112233445566778899",
  "pubkey": "6e468422dfb74a5738702a8823b9b28168abab8655faacb6853cd0ee15deee93",
  "created_at": 1710003600,
  "kind": 3001,
  "tags": [
    ["event_number", "2"],
    ["title", "Redesign syrius dashboard"],
    ["minZNN", "5000"],
    ["minQSR", "50000"],
    ["status", "0"],
    ["e", "f1f2ab00ccddeeff00112233445566778899aabbccddeeff0011223344556677"] // genesis id
  ],
  "content": "Updated scope after feedback...",
  "sig": "908a15e46fb4d8675bab026fc230a0e3542bfade63da02d542fb78b2a8513fcd0092619a2c8c1221e581946e0191f2af505dfdf8657a414dbca329186f009262"
}
```
