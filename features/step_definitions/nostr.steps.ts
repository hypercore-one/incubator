// features/step_definitions/nostr.steps.ts
import { Given, When, Then } from "@cucumber/cucumber";
import assert from "assert";
import { getPublicKey, nip19 } from "nostr-tools";

Given("I have the hex private key {string}", function (privkey: string) {
  this.privkey = privkey;
});

When("I derive the public key", function () {
  if (!this.privkey) throw new Error("Private key not set");
  this.pubkey = getPublicKey(this.privkey);
  this.npub = nip19.npubEncode(this.pubkey);
});

Then("the npub should be {string}", function (expected: string) {
  assert.strictEqual(this.npub, expected);
});
