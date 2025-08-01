Feature: Publishing and updating a proposal via Nostr
  As a pillar in the HyperCore One ecosystem I want to be able to
  publish proposals and update my published proposals.

  Background:
    Given the pillar "PillarOne" has a registered npub of "<NPUB>"
    And the system is listening to Nostr events on configured relays

  Scenario: Publishing a proposal
    When a proposal event is received with:
      | id            | event_number | title | description | minimum_znn | minimum_qsr | status | owner  | owner_signature |
      | <PROPOSAL_ID> | 1            | Title | Description | 1000        | 10000       | 0      | <NPUB> | <SIG_VALID>     |
    And the ID is a SHA-256 hash created from the serialized data of event_number, title, description, minimum_znn, minimum_qsr, and owner
    And no proposal exists with an ID of "<PROPOSAL_ID>"
    Then a new proposal is created

  Scenario: Updating a proposal
    When a proposal event is received with:
      | id            | event_number | title | description | minimum_znn | minimum_qsr | status | owner  | owner_signature |
      | <PROPOSAL_ID> | 2            | Title | Description | 1000        | 10000       | 0      | <NPUB> | <SIG_VALID>     |
    And a proposal exists with an ID of "<PROPOSAL_ID>"
    And the event number is greater than the previous known event number
    Then the proposal is updated

  Scenario: Malformed event is ignored
    # TODO: split into specific cases once Nostr event format is finalized.
    # Examples: missing fields, bad event number, malformed JSON, wrong kind, etc.
    When a malformed event is received (missing fields or invalid format)
    Then no proposal should be created or updated