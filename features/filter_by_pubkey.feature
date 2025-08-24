Feature: Filter Items by Publisher Public Key
  As any user of the HyperCore One Incubator app
  I want to filter the list of published items by public key
  So that I can view all items from a specific publisher


  Background:
    Given the following pillars are registered:
      | name          | npub                           |
      | PillarOne     | npub1alice789xyz...            |
      | PillarTwo     | npub1bob456def...              |
      | PillarThree   | npub1charlie123abc...          |
    And the following items have been published:
      | item_id | type    | title                        | proposer_npub          | funding_target | funding_currency | status    |
      | proj_1  | PROJECT | Cross-Chain Bridge           | npub1alice789xyz...    | 50000          | ZNN             | active    |
      | task_1  | TASK    | API Documentation            | npub1alice789xyz...    | 2000           | QSR             | active    |
      | bounty_1| BOUNTY  | Security Audit               | npub1alice789xyz...    | 10000          | ZNN             | active    |
      | proj_2  | PROJECT | Governance Module            | npub1bob456def...      | 30000          | ZNN             | active    |
      | task_2  | TASK    | Frontend Development         | npub1bob456def...      | 5000           | QSR             | active    |
      | proj_3  | PROJECT | Token Economics Research     | npub1charlie123abc...  | 15000          | ZNN             | active    |
      | bounty_2| BOUNTY  | Bug Bounty Program           | npub1charlie123abc...  | 25000          | ZNN             | active    |

  Scenario: Filter items by a single publisher's public key
    When I filter items by pubkey "npub1alice789xyz..."
    Then I should see 3 items in the results
    And the results should contain:
      | item_id | type    | title              | funding_target | funding_currency |
      | proj_1  | PROJECT | Cross-Chain Bridge | 50000          | ZNN             |
      | task_1  | TASK    | API Documentation  | 2000           | QSR             |
      | bounty_1| BOUNTY  | Security Audit     | 10000          | ZNN             |
    And all items should have proposer_npub "npub1alice789xyz..."

  Scenario: Filter items by multiple publisher public keys
    When I filter items by pubkeys:
      | npub                  |
      | npub1alice789xyz...   |
      | npub1bob456def...     |
    Then I should see 5 items in the results
    And the results should contain items from "npub1alice789xyz..." and "npub1bob456def..."
    But the results should not contain items from "npub1charlie123abc..."

  Scenario: Combine pubkey filter with item type filter
    When I filter items by pubkey "npub1alice789xyz..."
    And I filter by item type "PROJECT"
    Then I should see 1 item in the results
    And the result should be:
      | item_id | type    | title              | proposer_npub       |
      | proj_1  | PROJECT | Cross-Chain Bridge | npub1alice789xyz... |

  Scenario: Filter returns empty results when no items match
    When I filter items by pubkey "npub1nonexistent999..."
    Then I should see 0 items in the results
    And I should see a message "No items found for the specified publisher"

  Scenario: Invalid npub format returns validation error
    When I filter items by pubkey "invalid-npub-format"
    Then I should receive a validation error
    And the error should indicate "Invalid Nostr public key format"
    And no filtering should be applied

  Scenario: Filter with pagination for large result sets
    Given "npub1alice789xyz..." has published 150 items
    When I filter items by pubkey "npub1alice789xyz..."
    And I request page 1 with 50 items per page
    Then I should see 50 items in the current page
    And I should see pagination info:
      | Field        | Value |
      | total_items  | 150   |
      | current_page | 1     |
      | total_pages  | 3     |
      | per_page     | 50    |

  Scenario: Filter updates in real-time when new items are published
    Given I am viewing filtered results for "npub1alice789xyz..."
    And the results show 3 items
    When "npub1alice789xyz..." publishes a new TASK "Backend Integration"
    Then the filtered results should automatically update
    And I should now see 4 items in the results
    And the new task should appear in the list

  Scenario: Clear pubkey filter to view all items
    Given I have filtered items by pubkey "npub1alice789xyz..."
    And I see 3 filtered results
    When I clear the pubkey filter
    Then I should see all 7 items
    And items from all publishers should be visible

  Scenario Outline: Filter by pubkey across different item types
    When I filter items by pubkey "<pubkey>"
    And I filter by item type "<item_type>"
    Then I should see <count> items in the results

    Examples:
      | pubkey                | item_type | count |
      | npub1alice789xyz...   | PROJECT   | 1     |
      | npub1alice789xyz...   | TASK      | 1     |
      | npub1alice789xyz...   | BOUNTY    | 1     |
      | npub1bob456def...     | PROJECT   | 1     |
      | npub1bob456def...     | TASK      | 1     |
      | npub1bob456def...     | BOUNTY    | 0     |
      | npub1charlie123abc... | PROJECT   | 1     |
      | npub1charlie123abc... | TASK      | 0     |
      | npub1charlie123abc... | BOUNTY    | 1     |

  # UI/UX Scenarios

  Scenario: Display publisher information in filter UI
    When I open the filter options
    Then I should see a "Filter by Publisher" section
    And I should see a searchable dropdown with registered publishers:
      | display                        | npub                  |
      | PillarOne (npub1alice789xyz...)   | npub1alice789xyz...   |
      | PillarTwo (npub1bob456def...)     | npub1bob456def...     |
      | PillarThree (npub1charlie123abc...)| npub1charlie123abc... |

  Scenario: Autocomplete publisher search
    Given I am in the publisher filter input field
    When I type "Pillar"
    Then I should see autocomplete suggestions:
      | suggestion                     |
      | PillarOne (npub1alice789xyz...)   |
    When I select "PillarOne (npub1alice789xyz...)"
    Then the filter should be applied with "npub1alice789xyz..."

  Scenario: Persist filter selections across sessions
    Given I have filtered items by pubkey "npub1alice789xyz..."
    When I refresh the page
    Then the pubkey filter "npub1alice789xyz..." should still be active
    And I should still see the filtered results

  Scenario: Show active filters clearly in the UI
    When I filter items by pubkey "npub1alice789xyz..."
    Then I should see an active filter badge showing "Publisher: PillarOne"
    And the badge should have a clear option to remove the filter

  # Performance Scenarios

  Scenario: Filter performance with large dataset
    Given there are 10000 items from 100 different publishers
    When I filter items by pubkey "npub1alice789xyz..."
    Then the results should load within 2 seconds
    And the filter should use database indexing on proposer_npub field

  Scenario: Cache filtered results for improved performance
    When I filter items by pubkey "npub1alice789xyz..."
    And I navigate to a different page
    And I return to the items list
    Then the previous filter should be maintained
    And the results should load from cache immediately