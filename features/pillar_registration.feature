Feature: Pillar registration via Nostr

  As a pillar in the HyperCore One ecosystem
  I want to register my public Nostr key (npub)
  So that my pledges and actions can be associated with a valid identity

  Background:
    Given the pillar "PillarOne" has a chain pubkey of "<PILLAR_CHAIN_PUBKEY>"
    And the system is listening to Nostr events on configured relays

  Scenario: First-time pillar registration
    Given "PillarOne" has no registered npub
    When a pillar registration event is received with:
      | registration_number | pillar     | npub         | signature     |
      | 1                   | PillarOne  | <NPUB_VALID> | <SIG_VALID>   |
    Then "PillarOne" should have a registered npub of "<NPUB_VALID>"

  Scenario: Signature does not match pillar’s registered chain pubkey
    Given "PillarOne" has no registered npub
    When a pillar registration event is received with:
      | registration_number | pillar     | npub             | signature             |
      | 1                   | PillarOne  | <NPUB_OTHER>      | <SIG_FROM_OTHER_KEY>  |
    Then "PillarOne" should not have a registered npub

  Scenario: Re-registration with higher registration number updates npub
    Given "PillarOne" has a registered npub of "<NPUB_OLD>" at registration number 1
    When a pillar registration event is received with:
      | registration_number | pillar     | npub         | signature     |
      | 2                   | PillarOne  | <NPUB_NEW>   | <SIG_VALID>   |
    Then "PillarOne" should have a registered npub of "<NPUB_NEW>"

  Scenario: Re-registration with lower registration number is ignored
    Given "PillarOne" has a registered npub of "<NPUB_CURRENT>" at registration number 2
    When a pillar registration event is received with:
      | registration_number | pillar     | npub             | signature     |
      | 1                   | PillarOne  | <NPUB_STALE>     | <SIG_VALID>   |
    Then "PillarOne" should still have a registered npub of "<NPUB_CURRENT>"

  Scenario: Conflicting events with same registration number — ignore second
    Given "PillarOne" has a registered npub of "<NPUB_A>" at registration number 3
    When another pillar registration event is received with:
      | registration_number | pillar     | npub         | signature     |
      | 3                   | PillarOne  | <NPUB_B>     | <SIG_VALID>   |
    Then "PillarOne" should still have a registered npub of "<NPUB_A>"

  Scenario: Duplicate registration event is idempotent
    Given "PillarOne" has no registered npub
    When the same pillar registration event is received twice:
      | registration_number | pillar     | npub         | signature     |
      | 1                   | PillarOne  | <NPUB_VALID> | <SIG_VALID>   |
    Then "PillarOne" should have a registered npub of "<NPUB_VALID>"

  Scenario: Registration for unknown pillar is ignored
    Given no known pillar named "FakePillar"
    When a pillar registration event is received with:
      | registration_number | pillar      | npub          | signature     |
      | 1                   | FakePillar  | <NPUB_VALID>  | <SIG_VALID>   |
    Then there should be no registered npub for "FakePillar"

  Scenario: Malformed event is ignored
    # TODO: split into specific cases once Nostr event format is finalized.
    # Examples: missing fields, bad registration_number, malformed JSON, wrong kind, etc.
    Given "PillarOne" has no registered npub
    When a malformed registration event is received (missing fields or invalid format)
    Then "PillarOne" should not have a registered npub

