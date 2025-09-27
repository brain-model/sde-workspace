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

### Describe in 1-2 sentences the overall result of the analysis. Does the code meet the main requirements? Were critical issues found?

**Final Decision:** **QA_APPROVED** | **QA_REVISION_NEEDED**

## 2. Requirements Validation Checklist

*(Validate each functional and non-functional requirement from the `Spec Document`. Use this section as proof that the specification was completely covered.)*

| Spec Requirement | Status | Observations |
| :--- | :--- | :--- |
| **[Functional 1.1]** API must return `201 Created` | PASS | |
| **[Functional 1.2]** Validation of required `name` field | PASS | |
| **[Non-Functional 4.1]** API response < 200ms | PASS | Average of 150ms in local tests. |
| **[Non-Functional 4.2]** Access requires `resource:write` scope | FAIL | Access is public, no scope validation. |

## 3. Edge Cases and Failure Scenario Analysis

### Document here the tests that go beyond the "happy path" to ensure application robustness

| Test Scenario | Reproduction Steps | Expected Result | Observed Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Empty request body** | Send `POST` to `/api/v1/new-resource` with `{}`. | Return `400 Bad Request` with clear message. | Returns `500 Internal Server Error`. | FAIL |
| **Input with special characters** | Send `name` with `"><script>alert(1)</script>"`. | System should sanitize input and save it without executing the script. | Input is saved as is, creating XSS vulnerability. | FAIL |
| **Database unavailable** | Simulate `DatabaseService` unavailability. | API should return `503 Service Unavailable`. | API returns `503 Service Unavailable` as expected. | PASS |

## 4. Actionable Items for Developer

*(If the decision is `QA_REVISION_NEEDED`, clearly and objectively list the issues that need to be fixed. Each item should be a direct instruction.)*

1. **[CRITICAL - SECURITY]** Implement authorization scope verification (`resource:write`) in the API endpoint, as defined in the `Spec Document`. Currently, the endpoint is unprotected.
2. **[CRITICAL - ROBUSTNESS]** Add validation for the request body. An empty request (`{}`) is causing an unhandled exception (`Internal Server Error 500`) instead of a `Bad Request 400`.
3. **[MEDIUM - SECURITY]** Implement sanitization for the `name` field input to prevent Cross-Site Scripting (XSS) vulnerabilities.
