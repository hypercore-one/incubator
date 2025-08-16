Feature: Publishing and updating a bounty via Nostr
  As a user in the I want to be able to publish bounties linked
  to tasks and update my published bounties.

  Background:
    Given the system is listening to Nostr events on configured relays
    And a task exists with an ID of "<TASK_ID>" and an owner of "<NPUB>"

  Scenario: Publishing a bounty
    When a bounty event is received with:
      | id      | task_id   | event_number | amount | currency | status | sender |
      | <EMPTY> | <TASK_ID> | 1            | 1000   | points   | 0      | <NPUB> |
    And the event number is 1
    Then a new bounty is created with "<NPUB>" as its owner

  Scenario: Creation event with unknown task id is ignored
    When a bounty event is received with:
      | id      | task_id      | event_number | amount | currency | status | sender |
      | <EMPTY> | <UNKNOWN_ID> | 1            | 1000   | points   | 0      | <NPUB> |
    And no bounty exists with an ID of "<UNKNOWN_ID>"
    Then a bounty is not created

  Scenario: Update event with higher event number updates bounty
    Given a bounty exists with an ID of "<BOUNTY_ID>"
    And an owner of "<NPUB>"
    When a bounty event is received with:
      | id          | task_id   | event_number | amount | currency | status | sender |
      | <BOUNTY_ID> | <TASK_ID> | 2            | 500    | ZNN      | 1      | <NPUB> |
    And the event number is greater than the previous known event number
    Then the bounty's status is updated

Scenario: Update event with lower event number is ignored
    Given a bounty exists with an event number of 2
    When a bounty event is received with:
      | id          | task_id   | event_number | amount | currency | status | sender |
      | <BOUNTY_ID> | <TASK_ID> | 1            | 1000   | points   | 0      | <NPUB> |
    Then the bounty is not updated

Scenario: Update event with same event number is ignored
    Given a bounty exists with an event number of 2
    When a bounty event is received with:
      | id          | task_id   | event_number | amount | currency | status | sender |
      | <BOUNTY_ID> | <TASK_ID> | 2            | 1000   | points   | 0      | <NPUB> |
    Then the bounty is not updated

  Scenario: Update event is ignored when sender is not owner
    Given a bounty exists with an owner of "<NPUB>"
    When a bounty event is received with:
      | id          | task_id   | event_number | amount | currency | status | sender       |
      | <BOUNTY_ID> | <TASK_ID> | 2            | 1000   | points   | 0      | <NPUB_OTHER> |
    Then the bounty is not updated

  Scenario: Update event with unknown id is ignored
    When a bounty event is received with:
      | id           | task_id   | event_number | amount | currency | status | sender |
      | <UNKNOWN_ID> | <TASK_ID> | 2            | 1000   | points   | 0      | <NPUB> |
    And no bounty exists with an ID of "<UNKNOWN_ID>"
    Then the bounty is not updated

  Scenario: Update event with different task id is ignored
    Given a bounty exists with an ID of "<BOUNTY_ID>"
    And a task ID of "<TASK_ID>"
    When a bounty event is received with:
      | id          | task_id         | event_number | amount | currency | status | sender |
      | <BOUNTY_ID> | <TASK_ID_OTHER> | 2            | 1000   | points   | 0      | <NPUB> |
    Then the bounty is not updated

  Scenario: Malformed event is ignored
    # TODO: split into specific cases once Nostr event format is finalized.
    # Examples: missing fields, bad event number, malformed JSON, wrong kind, etc.
    When a malformed event is received (missing fields or invalid format)
    Then no bounty should be created or updated
