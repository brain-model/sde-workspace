# Quality Assurance Report: [FEATURE TITLE]

---

**TASK-ID:** [WORKSPACE TASK ID]
**Spec Document:** [PATH/TO/SPEC_DOCUMENT.MD]
**Analyzed Branch:** [GIT-BRANCH-NAME]
**Analyzed Commit:** [SQUASHED-COMMIT-HASH]
**Author(s):** QA Agent
**Date:** {{YYYY-MM-DD}}

---

## 1. Executive Summary

### Describe in 1-2 sentences the overall outcome. Does the code meet main requirements? Were critical issues found?

**Final Decision:** **QA_APPROVED** | **QA_REVISION_NEEDED**

## 2. Requirements Validation Checklist

*(Validate each functional and non-functional requirement from the `Spec Document`. Use this section as proof that the specification was fully covered.)*

| Spec Requirement | Status | Notes |
| :--- | :--- | :--- |
| **[Functional 1.1]** API must return `201 Created` | PASS | |
| **[Functional 1.2]** `name` is required | PASS | |
| **[Non-Functional 4.1]** API response < 200ms | PASS | Averaged 150ms locally. |
| **[Non-Functional 4.2]** Access requires `resource:write` scope | FAIL | Endpoint is public, missing scope validation. |

## 3. Edge Cases and Failure Scenarios

### Document tests that go beyond the happy path to ensure robustness

| Test Scenario | Reproduction Steps | Expected Result | Observed Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Empty request body** | Send `POST` to `/api/v1/resource` with `{}`. | Return `400 Bad Request` with clear message. | Returns `500 Internal Server Error`. | FAIL |
| **Input with special characters** | Send `name` with `"><script>alert(1)</script>"`. | System sanitizes input and saves it without executing. | Input saved as-is, creating XSS vulnerability. | FAIL |
| **Database unavailable** | Simulate `DatabaseService` outage. | API returns `503 Service Unavailable`. | API returns `503 Service Unavailable`. | PASS |

## 4. Actionable Items for the Developer

*(If the decision is `QA_REVISION_NEEDED`, list clear and objective issues to be fixed. Each item must be a direct instruction.)*

1. **[CRITICAL - SECURITY]** Implement authorization scope check (`resource:write`) on the API endpoint, as defined in the `Spec Document`. Endpoint is currently unprotected.
2. **[CRITICAL - ROBUSTNESS]** Add request body validation. An empty `{}` triggers an unhandled exception (`500`) instead of a `400 Bad Request`.
3. **[MEDIUM - SECURITY]** Sanitize the `name` input to prevent Cross-Site Scripting (XSS).
