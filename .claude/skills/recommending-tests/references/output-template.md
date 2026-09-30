# Output template

This is a worked example. Copy its structure exactly: heading levels, the opening
verification-style line, the sentence-per-case phrasing, and the sequential numbering across
both test-level sections. Only the content changes per target.

The example below targets a fictional static class, `OrderApprovalChecker`, with these methods:

- `IsApprovalRequest(Order order)` — true if the order is the kind that requires approval at all.
- `GetLineItems(Order order)` — the line items that each need their own approval check.
- `HasFailedPayment(Order order)` — true if the order's payment already failed upstream.
- `IsApprovedByFinance(LineItem item, ApprovalPolicy policy, Approver approver)` — checks one
  line item against a real or cached approver record, decrypting an approver token when needed.
- `EnsureAllLineItemsApproved(Order order, ApprovalPolicy policy, Approver approver)` — throws if
  any line item lacks approval.

---

**Verified** (agent read the source file and both test directories this session): No dedicated
unit test file exists for `OrderApprovalChecker`; unit-level coverage is indirect, through
`ProcessOrderAsync` tests in `OrderProcessorTests.cs`. Integration-level coverage is direct and
thorough: `OrderApprovalIntegrationTests.cs` already drives every branch of
`EnsureAllLineItemsApproved`, `IsApprovalRequest`, and `HasFailedPayment` through the real
approval pipeline, a real database-backed `ApprovalPolicy`, and real approver-token fixtures.

## Recommendation

**Unit**: Add a new file, `test/Utilities/Orders/OrderApprovalCheckerTests.cs`. Test each static
method directly — a direct test isolates a failure to one method, where the existing integration
tests only isolate it to the whole `ProcessOrderAsync` call.

**Integration**: Extend `OrderApprovalIntegrationTests.cs` with the two cases below. The real
approver service's timeout behavior is not exercised anywhere today, and a mock cannot stand in
for it — the timeout only exists in the real network client.

## Unit test cases by method

### `IsApprovalRequest`
1. The method must return `true` for an order above the policy's approval threshold.
2. The method must return `false` for an order at or below the policy's approval threshold.
3. The method must return `false` for an order already marked pre-approved.

### `GetLineItems`
4. The method must return an empty array when the order has no line items.
5. The method must return one element for an order with a single line item.
6. The method must return one element per line item for an order with several line items.
7. The method must exclude a line item marked as cancelled.

### `HasFailedPayment`
8. The method must return `false` when the order has no payment record.
9. The method must return `false` when the order has no payment status field.
10. The method must return `false` when the payment status is `Succeeded`.
11. The method must return `true` when the payment status is a non-success failure code.
12. The method must return `false` when the payment status value is empty or whitespace only.
13. The method must trim whitespace around the payment status value before it compares the value.

### `IsApprovedByFinance`
14. The method must return `true` for a line item approved by a trusted approver token.
15. The method must return `false` for a line item with no approver token.
16. The method must return `false` for a line item approved by an untrusted approver token.
17. The method must return `true` for an encrypted approver token that decrypts and carries a
    valid approval.
18. The method must return `false` for an encrypted approver token that decrypts but carries no
    approval.
19. The method must return `false` when the token decryption fails, and it must not call the
    approval check in this case.

### `EnsureAllLineItemsApproved`
20. The method must not throw for an order that does not require approval, regardless of line
    item content.
21. The method must not throw for an order with a failed payment and no line items.
22. The method must throw for an order with a successful payment and no line items.
23. The method must throw for an order with no payment record and no line items.
24. The method must throw for an order with zero line items, even where `HasFailedPayment`
    returns `false`. This is the explicit `Length == 0` fail-closed guard.
25. The method must not throw when every line item in the order is approved.
26. The method must throw when at least one line item is unapproved, regardless of line item
    order.
27. The method must throw when one line item is approved and a sibling encrypted-token line item
    is unapproved.

## Integration test cases by scenario

### Real approver service rejects a line item through the live approval API
28. The system must reject the order when the real approval service returns a rejection for one
    line item, not just when a fake approver returns `false`.

### Real approver service times out mid-batch
29. The system must throw, not silently pass, when the real approval service times out while
    checking a later line item after approving an earlier one.

## Gap noted, one item to flag

⚠️ The token decryption itself, `TokenCrypto.DecryptApproverToken`, comes from a third-party
library. A test of `IsApprovedByFinance` needs real encrypted and plaintext token fixtures. It
cannot mock this call through an interface. The existing integration tests already build this
fixture pattern; reuse it rather than write it twice.

---

## Authoring note (not part of the output — delete this section before you present the result)

The example above populates both the unit and integration sections, because this target has a
real gap at each level. Sometimes one level is already closed — for instance, if an existing
integration suite already drives every branch of the target end-to-end, write
`## Integration test cases by scenario` as a single sentence instead of a numbered list:

```
## Integration test cases by scenario

No new cases. See the "Recommendation" section above for why this level is already closed.
```

Use a `###` scenario heading in the integration section whenever a case only fails at the wiring
level — a real config binding, a real database round-trip, a real HTTP pipeline stage, a real
third-party library call — never a case that a unit test could already catch just as reliably.
If every behavior is fully exercised by unit tests and there is no real collaborator left to get
wrong, say so in one sentence. Do not invent an integration case just to fill the section.
