Feature: Nostr public key generation

  @automated
  Scenario: Convert private key to npub
    Given I have the hex private key "0000000000000000000000000000000000000000000000000000000000000001"
    When I derive the public key
    Then the npub should be "npub10xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqpkge6d"
