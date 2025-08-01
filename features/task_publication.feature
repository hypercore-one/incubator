Feature: Publishing and updating a proposal via Nostr
  As a pillar in the HyperCore One ecosystem I want to be able to
  publish tasks linked to proposals and update my published tasks.

  Background:
    Given the pillar "PillarOne" has a registered npub of "<NPUB>"
    And the system is listening to Nostr events on configured relays
    And a proposal exists with an ID of "<PROPOSAL_ID>" and an owner of "<NPUB>"

  Scenario: Publishing a task
    When a task event is received with:
      | id        | proposal_id   | event_number | title | description | status | owner  | signature   |
      | <TASK_ID> | <PROPOSAL_ID> | 1            | Title | Description | 0      | <NPUB> | <SIG_VALID> |
    And the ID is a SHA-256 hash created from the serialized data of proposal_id, event_number, title, description, and owner
    And no task exists with an ID of "<TASK_ID>"
    Then a new task is created

  Scenario: Updating a task
    When a task event is received with:
      | id        | proposal_id   | event_number | title | description | status | owner  | signature   |
      | <TASK_ID> | <PROPOSAL_ID> | 2            | Title | Description | 0      | <NPUB> | <SIG_VALID> |
    And a task exists with an ID of "<TASK_ID>"
    And the event number is greater than the previous known event number
    Then the task is updated

  Scenario: Malformed event is ignored
    # TODO: split into specific cases once Nostr event format is finalized.
    # Examples: missing fields, bad event number, malformed JSON, wrong kind, etc.
    When a malformed event is received (missing fields or invalid format)
    Then no task should be created or updated