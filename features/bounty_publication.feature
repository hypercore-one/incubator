Feature: Publishing and updating a bounty via Nostr
  As a pillar in the HyperCore One ecosystem I want to be able to
  publish bounties linked to tasks and update my published bounties.

  Background:
    Given the pillar "PillarOne" has a registered npub of "<NPUB>"
    And the system is listening to Nostr events on configured relays
    And a task exists with an ID of "<TASK_ID>" and an owner of "<NPUB>"

  Scenario: Publishing a bounty
    When a bounty event is received with:
      | id          | task_id   | event_number | amount_znn | amount_qsr | status | owner  | signature   |
      | <BOUNTY_ID> | <TASK_ID> | 1            | 1000       | 10000      | 0      | <NPUB> | <SIG_VALID> |
    And the ID is a SHA-256 hash created from the serialized data of task_id, event_number, amount_znn, amount_qsr, and owner
    And no bounty exists with an ID of "<BOUNTY_ID>"
    Then a new bounty is created

  Scenario: Updating a bounty
    When a bounty event is received with:
      | id          | task_id   | event_number | amount_znn | amount_qsr | status | owner  | signature   |
      | <BOUNTY_ID> | <TASK_ID> | 2            | 1000       | 10000      | 0      | <NPUB> | <SIG_VALID> |
    And a bounty exists with an ID of "<BOUNTY_ID>"
    And the event number is greater than the previous known event number
    And the ZNN and QSR amounts are the same as the previously known amounts
    Then the bounty is updated

  Scenario: Bounty amounts cannot be updated
    Given a bounty exists with a ZNN amount of 1,000 and a QSR amount of 10,000
    And the bounty has an ID of "<BOUNTY_ID>"
    When a bounty event is received with:
      | id          | task_id   | event_number | amount_znn | amount_qsr | status | owner  | signature   |
      | <BOUNTY_ID> | <TASK_ID> | 2            | 1500       | 15000      | 0      | <NPUB> | <SIG_VALID> |
    Then the bounty is not updated

  Scenario: Malformed event is ignored
    # TODO: split into specific cases once Nostr event format is finalized.
    # Examples: missing fields, bad event number, malformed JSON, wrong kind, etc.
    When a malformed event is received (missing fields or invalid format)
    Then no bounty should be created or updated
