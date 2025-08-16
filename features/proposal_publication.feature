Feature: Publishing and updating proposal via Nostr
  As a user I want to be able to publish proposals and
  update my published proposals tied to my npub.

  Background:
    Given the system is listening to Nostr events on configured relays

  Scenario: Publishing proposal
    When a proposal event is received with:
      | id | event_number | title | description | funding | currency | status | sender    |
      |    | 1            | Title | Description | 10000   | points   | 0      | npubAlice |
    And the event number is 1
    And the ID is empty
    Then a new proposal is created with "npubAlice" as its owner

  Scenario: Update event with higher event number updates proposal
    Given a proposal exists with an ID of "P123"
    And an owner of "npubAlice"
    When a proposal event is received with:
      | id   | event_number | title | description | funding | currency | status | sender    |
      | P123 | 2            | Title | Description | 10000   | points   | 0      | npubAlice |
    And the event number is greater than the previous known event number
    Then the proposal's title, description, funding, currency, and status are updated

  Scenario: Update event with lower event number is ignored
    Given a proposal exists with an event number of 2
    When a proposal event is received with:
      | id   | event_number | title | description | funding | currency | status | sender    |
      | P123 | 1            | Title | Description | 10000   | points   | 0      | npubAlice |
    Then the proposal is not updated

  Scenario: Update event with same event number is ignored
    Given a proposal exists with an event number of 2
    When a proposal event is received with:
      | id   | event_number | title | description | funding | currency | status | sender    |
      | P123 | 2            | Title | Description | 10000   | points   | 0      | npubAlice |
    Then the proposal is not updated

  Scenario: Update event is ignored when sender is not owner
    Given a proposal exists with an owner of "npubAlice"
    When a proposal event is received with:
      | id   | event_number | title | description | funding | currency | status | sender  |
      | P123 | 2            | Title | Description | 10000   | points   | 0      | npubBob |
    Then the proposal is not updated

  Scenario: Update event with unknown id is ignored
    When a proposal event is received with:
      | id   | event_number | title | description | funding | currency | status | sender    |
      | P321 | 2            | Title | Description | 10000   | points   | 0      | npubAlice |
    And no proposal exists with an ID of "P321"
    Then the proposal is not updated

  Scenario: Malformed event is ignored
    # TODO: split into specific cases once Nostr event format is finalized.
    # Examples: missing fields, bad event number, malformed JSON, wrong kind, etc.
    When a malformed event is received (missing fields or invalid format)
    Then no proposal should be created or updated