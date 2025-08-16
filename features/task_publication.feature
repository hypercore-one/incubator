Feature: Publishing and updating task via Nostr
  As a user I want to be able to publish tasks linked
  to proposals and update my published tasks.

  Background:
    Given the system is listening to Nostr events on configured relays
    And a proposal exists with an ID of "<PROPOSAL_ID>" and an owner of "<NPUB>"

  Scenario: Publishing task
    When a task event is received with:
      | id      | proposal_id   | event_number | title | description | status | sender |
      | <EMPTY> | <PROPOSAL_ID> | 1            | Title | Description | 0      | <NPUB> |
    And the event number is 1
    Then a new task is created with "<NPUB>" as its owner

  Scenario: Creation event with unknown proposal id is ignored
    When a task event is received with:
      | id      | proposal_id  | event_number | title | description | status | sender |
      | <EMPTY> | <UNKNOWN_ID> | 1            | Title | Description | 0      | <NPUB> |
    And no proposal exists with an ID of "<UNKNOWN_ID>"
    Then a task is not created

  Scenario: Update event with higher event number updates task
    Given a task exists with an ID of "<TASK_ID>"
    And an owner of "<NPUB>"
    When a task event is received with:
      | id        | proposal_id   | event_number | title | description | status | owner  | signature   |
      | <TASK_ID> | <PROPOSAL_ID> | 2            | Title | Description | 0      | <NPUB> | <SIG_VALID> |
    And the event number is greater than the previous known event number
    Then the task is updated

  Scenario: Update event with lower event number is ignored
    Given a task exists with an event number of 2
    When a task event is received with:
      | id        | proposal_id   | event_number | title | description | status | sender |
      | <TASK_ID> | <PROPOSAL_ID> | 1            | Title | Description | 0      | <NPUB> |
    Then the task is not updated

  Scenario: Update event with same event number is ignored
    Given a task exists with an event number of 2
    When a task event is received with:
      | id        | proposal_id   | event_number | title | description | status | sender |
      | <TASK_ID> | <PROPOSAL_ID> | 2            | Title | Description | 0      | <NPUB> |
    Then the task is not updated

  Scenario: Update event is ignored when sender is not owner
    Given a task exists with an owner of "<NPUB>"
    When a task event is received with:
      | id        | proposal_id   | event_number | title | description | status | sender       |
      | <TASK_ID> | <PROPOSAL_ID> | 2            | Title | Description | 0      | <NPUB_OTHER> |
    Then the task is not updated

  Scenario: Update event with unknown id is ignored
    When a task event is received with:
      | id           | proposal_id   | event_number | title | description | status | sender |
      | <UNKNOWN_ID> | <PROPOSAL_ID> | 2            | Title | Description | 0      | <NPUB> |
    And no task exists with an ID of "<UNKNOWN_ID>"
    Then the task is not updated

  Scenario: Update event with different proposal id is ignored
    Given a task exists with an ID of "<TASK_ID>"
    And a proposal ID of "<PROPOSAL_ID>"
    When a task event is received with:
      | id        | proposal_id         | event_number | title | description | status | sender |
      | <TASK_ID> | <PROPOSAL_ID_OTHER> | 2            | Title | Description | 0      | <NPUB> |
    Then the task is not updated

  Scenario: Malformed event is ignored
    # TODO: split into specific cases once Nostr event format is finalized.
    # Examples: missing fields, bad event number, malformed JSON, wrong kind, etc.
    When a malformed event is received (missing fields or invalid format)
    Then no task should be created or updated