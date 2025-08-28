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
    And the following projects have been published:
      | project_id | title                        | proposer_npub          | funding_target | funding_currency | status    |
      | proj_1     | Cross-Chain Bridge           | npub1alice789xyz...    | 50000          | ZNN             | active    |
      | proj_2     | Governance Module            | npub1bob456def...      | 30000          | ZNN             | active    |
      | proj_3     | Token Economics Research     | npub1charlie123abc...  | 15000          | ZNN             | active    |
    And the following tasks belong to these projects:
      | task_id | project_id | title                   | status      | has_bounty | bounty_amount | bounty_currency |
      | task_1  | proj_1     | API Documentation       | TODO        | false      |               |                 |
      | task_2  | proj_1     | Security Audit          | TODO        | true       | 10000         | ZNN            |
      | task_3  | proj_2     | Frontend Development    | IN_PROGRESS | false      |               |                 |
      | task_4  | proj_2     | Testing Framework       | TODO        | true       | 5000          | QSR            |
      | task_5  | proj_3     | Economic Model Design   | COMPLETE    | false      |               |                 |
      | task_6  | proj_3     | Bug Bounty Program      | TODO        | true       | 25000         | ZNN            |

  Scenario: Filter projects by a single publisher's public key
    When I filter projects by pubkey "npub1alice789xyz..."
    Then I should see 1 project in the results
    And the project should be:
      | project_id | title              | funding_target | funding_currency |
      | proj_1     | Cross-Chain Bridge | 50000          | ZNN             |
    And the project should have proposer_npub "npub1alice789xyz..."
    And the project should show 2 associated tasks

  Scenario: Filter projects by multiple publisher public keys
    When I filter projects by pubkeys:
      | npub                  |
      | npub1alice789xyz...   |
      | npub1bob456def...     |
    Then I should see 2 projects in the results
    And the results should contain projects from "npub1alice789xyz..." and "npub1bob456def..."
    But the results should not contain projects from "npub1charlie123abc..."

  Scenario: Combine pubkey filter with task status filter
    When I filter projects by pubkey "npub1bob456def..."
    And I filter tasks by status "IN_PROGRESS"
    Then I should see 1 project in the results
    And the project should show 1 task with status "IN_PROGRESS"
    And the task should be:
      | task_id | title                | status      |
      | task_3  | Frontend Development | IN_PROGRESS |

  Scenario: Filter returns empty results when no projects match
    When I filter projects by pubkey "npub1nonexistent999..."
    Then I should see 0 projects in the results
    And I should see a message "No projects found for the specified publisher"

  Scenario: Invalid npub format returns validation error
    When I filter items by pubkey "invalid-npub-format"
    Then I should receive a validation error
    And the error should indicate "Invalid Nostr public key format"
    And no filtering should be applied

  Scenario: Filter with pagination for large result sets
    Given "npub1alice789xyz..." has published 150 projects
    When I filter projects by pubkey "npub1alice789xyz..."
    And I request page 1 with 50 projects per page
    Then I should see 50 projects in the current page
    And I should see pagination info:
      | Field        | Value |
      | total_projects | 150   |
      | current_page | 1     |
      | total_pages  | 3     |
      | per_page     | 50    |

  Scenario: Filter updates in real-time when new projects are published
    Given I am viewing filtered results for "npub1alice789xyz..."
    And the results show 1 project
    When "npub1alice789xyz..." publishes a new PROJECT "Backend Integration"
    Then the filtered results should automatically update
    And I should now see 2 projects in the results
    And the new project should appear in the list

  Scenario: Clear pubkey filter to view all projects
    Given I have filtered projects by pubkey "npub1alice789xyz..."
    And I see 1 filtered result
    When I clear the pubkey filter
    Then I should see all 3 projects
    And projects from all publishers should be visible

  Scenario Outline: Filter projects and view associated task counts
    When I filter projects by pubkey "<pubkey>"
    Then I should see <project_count> projects in the results
    And the projects should have <task_count> total tasks
    And <bounty_count> tasks should have bounties

    Examples:
      | pubkey                | project_count | task_count | bounty_count |
      | npub1alice789xyz...   | 1            | 2          | 1            |
      | npub1bob456def...     | 1            | 2          | 1            |
      | npub1charlie123abc... | 1            | 2          | 1            |

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
    Given there are 10000 projects from 100 different publishers
    When I filter projects by pubkey "npub1alice789xyz..."
    Then the results should load within 2 seconds
    And the filter should use database indexing on proposer_npub field

  Scenario: Cache filtered results for improved performance
    When I filter projects by pubkey "npub1alice789xyz..."
    And I navigate to a different page
    And I return to the projects list
    Then the previous filter should be maintained
    And the results should load from cache immediately