# Service Offers

## Status

Draft commercial-offer design for `galewilliams.com`. This document defines the
shape, boundaries, choices, and review gates for future productized services. It
does not approve public prices, payment collection, contractual terms, or site
implementation by itself.

Public positioning and candidate website copy remain in
[MESSAGING_REVIEW.md](MESSAGING_REVIEW.md). The current general-purpose contact
form is not project intake and is not changed by this plan.

## Objective

Make it easy for someone with an Apple-platform product to choose a recognizable
piece of work, answer a small number of useful questions, and submit it for
review. Gale can then approve the standard scope and send an invoice, request
missing information, or propose a custom engagement when the product does not
fit the standard offer.

The offers should reduce sales and scoping overhead without turning unknown
codebases, unbounded bug fixing, App Review, or production support into
unlimited fixed-price obligations.

## Recorded Decisions

- Offer both two-week and four-week Instrumented Beta Runs.
- A launch without an external beta includes six weeks of post-launch
  observation and support.
- A beta-plus-launch engagement uses the same six-week service window,
  allocated at the client’s choice as either:
  - two weeks of beta and four weeks of post-launch support; or
  - four weeks of beta and two weeks of post-launch support.
- Every launch includes some focused, privacy-aware unified logging and
  MetricKit coverage when the product and deployment targets support it. The
  exact standard baseline remains to be defined.
- The remediation unit, included build and App Review allowances, ongoing-care
  terms, service-window pause rules, and centralized MetricKit handling are not
  yet decided.

## Proposed Operating Rules

The following boundaries are recommended but not yet approved:

- Define whether waiting for builds, access, testers, assets, App Review, or
  client decisions pauses or consumes the scheduled window.
- The standard telemetry baseline does not automatically include a remote
  collector, custom MetricKit ingestion endpoint, dashboard, analytics system,
  or long-term diagnostic storage. Those remain separately scoped options.

## Offer Principles

- Sell a concrete outcome, not a bucket of engineering time.
- Use fixed prices only when the product passes an eligibility review.
- Define what starts, pauses, resumes, and ends each scheduled beta or support
  window.
- Bound remediation by an agreed engineering allowance, build count, issue
  class, or combination of those—not by promising to fix every discovered bug.
- Keep a small validation period before every launch and a small observation
  period after it. Let clients choose where the deeper support is concentrated.
- Keep client products, source repositories, developer accounts, signing
  identities, infrastructure, domains, data, and store records in client-owned
  accounts whenever practical.
- Treat privacy-aware diagnostics as part of release quality. Treat custom
  analytics, remote telemetry ingestion, dashboards, and long-term data storage
  as separately scoped systems.
- Separate response targets from resolution promises. Investigation can be
  time-bounded; a third-party outage or unknown defect cannot always be fixed on
  a guaranteed clock.
- Move feature requests and material scope changes into a follow-up offer or
  custom estimate.

## Offer Architecture

The website should present three related Ship and Support offers:

| Offer | Primary outcome | Can stand alone? | Natural next step |
| --- | --- | --- | --- |
| Instrumented Beta Run | A tested release candidate and prioritized findings | Yes | Launch and Distribution |
| Launch and Distribution | A validated app released through the selected channel | Yes | Ongoing Care |
| Ongoing Care | Reserved post-launch maintenance and release capacity | After an eligibility review | Renewal or custom engagement |

Launch and Distribution is the central offer. It includes a minimum release-
candidate check and a post-launch watch. The client can launch directly or use
part of the standard six-week service window for a deeper external beta:

| Launch path | Pre-launch allocation | Post-launch allocation |
| --- | --- | --- |
| Launch-only | Internal beta or release-candidate verification | Six weeks |
| Two-week beta | Two-week external beta, evidence review, and remediation | Four weeks |
| Four-week beta | Four-week external beta, evidence review, and remediation | Two weeks |

The standalone Instrumented Beta Run is for a product that needs stabilization
or evidence before anyone commits to a launch. It may be credited into or
bundled with a later Launch and Distribution offer if that pricing rule is
approved.

## Common Eligibility Review

Before a fixed-price offer is accepted, confirm:

- Product, target platforms, supported OS versions, and intended users
- Source repository and dependency access
- Whether the current project builds with the agreed released Xcode toolchain
- Current test coverage and known failing tests
- Existing crash, hang, performance, or distribution failures
- Required client-owned Apple Developer and App Store Connect access
- Signing, capabilities, entitlements, extensions, helpers, and nested code
- Backend, third-party service, domain, and infrastructure dependencies
- Sensitive-data categories and applicable privacy constraints
- Target distribution channel and desired launch date
- Existing store metadata, screenshots, privacy details, agreements, tax, and
  banking readiness where relevant
- Person responsible for client decisions, approvals, tester recruitment, legal
  text, and marketing assets

If the product cannot build, has unresolved account or legal prerequisites, or
requires substantial feature development before the selected outcome is
possible, propose a separate readiness/remediation engagement first.

## Offer: Instrumented Beta Run

### Outcome

A time-scoped beta operated around explicit product questions, with tester
feedback and Apple diagnostics triaged into an actionable release decision. The
client receives either a release candidate or a findings report that clearly
identifies what still blocks release.

### Candidate Public Card

> **Instrumented Beta Run**
>
> Put the app in real testers’ hands without flying blind. I’ll configure
> TestFlight, add focused logging and MetricKit diagnostics, monitor crashes and
> performance, organize tester reports, fix issues within the agreed engineering
> budget, and deliver a release candidate with a plain-language findings report.

### Included Baseline

- Define the beta’s target audience, supported devices, product questions, and
  release-blocking criteria.
- Review release configuration and produce the initial beta build.
- Configure TestFlight test information, groups, build access, feedback contact,
  and testing instructions.
- Add or refine focused Apple unified logging for agreed lifecycle transitions
  and failure classes.
- Add MetricKit collection for agreed performance and diagnostic questions when
  the deployment target and product shape support it.
- Review TestFlight sessions, crashes, screenshots, comments, and relevant
  MetricKit evidence on the agreed cadence.
- Normalize incoming reports, reproduce issues when practical, remove
  duplicates, and maintain a prioritized findings list.
- Use the included remediation allowance for agreed defects and distribute no
  more than the included number of replacement builds.
- Deliver a final findings report, disposition remaining issues, and make a
  release, extend-beta, or stop recommendation.

### Telemetry Boundary

The standard beta should use the smallest evidence system that answers the
agreed questions:

- TestFlight and App Store Connect provide tester participation, sessions,
  crashes, screenshots, and written feedback.
- MetricKit provides Apple-captured performance and diagnostic reports.
- Unified logging records a small set of useful lifecycle and classified failure
  events, with interpolated values private unless they are deliberately reviewed
  as safe to expose.
- Signposts are added only when a specific duration or timing question will be
  measured and inspected with Instruments.

A custom upload endpoint, telemetry database, dashboard, analytics platform,
remote log collector, or long-term evidence archive is not part of the standard
beta. If the app needs centralized MetricKit payload ingestion, that becomes a
separate backend option with explicit transport, authentication, retention,
access, deletion, and privacy requirements.

### Client Responsibilities

- Provide an eligible build, repository access, and required account roles.
- Recruit and authorize the agreed tester cohort unless recruitment is added as
  a separate service.
- Supply representative test accounts, data, hardware, or external systems.
- Respond to product and release decisions within the agreed review window.
- Approve any collection, transmission, or retention of diagnostic data.

### Candidate Choices

- Two-week or four-week run
- Internal, invited external, or public-link TestFlight cohort
- Supported platform/device matrix
- Tester-group and cohort-size limit
- Evidence-review cadence
- Included replacement-build count
- Included remediation allowance
- Apple-only evidence or custom MetricKit ingestion add-on
- Release-candidate delivery or findings-only conclusion

### Completion Criteria

- The agreed beta build was available to the intended tester group.
- The agreed diagnostics were verified without knowingly capturing secrets,
  personal content, credentials, or raw sensitive payloads.
- Feedback and diagnostic evidence were reviewed through the closing date.
- Included remediation and build allowances were either used or explicitly
  declined.
- The client received the final build state, findings, deferred issues, and
  release recommendation.

### Excluded Unless Added

- Tester recruitment, compensation, or customer-support staffing
- New product features or material design changes
- Unlimited fixes, builds, devices, or beta extensions
- A general analytics or remote-observability platform
- Legal, privacy-policy, or App Store disclosure authorship
- Physical device-lab procurement
- Guaranteed App Review approval or a guaranteed defect-free release

## Offer: Launch and Distribution

### Outcome

A release-ready Apple-platform product validated and delivered through the
approved App Store or direct Mac distribution channel, followed by a bounded
launch watch.

### Candidate Public Card

> **Launch and Distribution**
>
> Take a finished app through the last hard mile. I’ll prepare and validate the
> release, configure privacy-aware diagnostics, and launch through the App Store
> or signed and notarized direct Mac distribution. Launch directly with six weeks
> of post-launch support, or choose a two- or four-week beta and use the rest of
> that six-week window after launch.

### Included Baseline

- Confirm the release channel, version, supported platforms, ownership, and
  release controls.
- Review distribution configuration, capabilities, entitlements, privacy
  declarations, versioning, and archive readiness.
- Produce and validate the release candidate using the selected channel.
- Configure a focused baseline of privacy-aware logging and available Apple
  diagnostics for launch questions, including MetricKit review and integration
  when the product and deployment targets support it.
- Perform minimum internal beta or release-candidate verification.
- Deliver through one approved distribution channel.
- Monitor agreed evidence and incoming reports during the included launch watch.
- Triage reports and use the included remediation allowance for eligible launch
  defects.
- Provide a release record containing the shipped version, channel, artifact or
  store state, known limitations, and remaining recommendations.

### Path A: Beta-First Launch

Emphasize pre-launch evidence and stabilization:

- Two-week or four-week external TestFlight period
- Tester instructions and feedback management
- Agreed diagnostic-review cadence
- Larger pre-launch remediation allowance
- Agreed replacement-build limit
- Four-week post-launch window after a two-week beta, or a two-week post-launch
  window after a four-week beta

This path is the default recommendation for a new product, a major update, an
unfamiliar codebase, a new distribution channel, or a release with meaningful
account, data, payment, hardware, or migration risk.

### Path B: Launch-Only Watch

Emphasize production observation after a smaller release-candidate check:

- Internal TestFlight or equivalent release-candidate verification
- Store or direct-distribution launch
- Six weeks of post-launch observation and support
- Larger post-launch remediation allowance
- Agreed patch-release limit

This path is eligible only when the product is already stable enough that
skipping an external beta is a deliberate, reviewed tradeoff.

### App Store Delivery

Candidate included work:

- App Store Connect product and version readiness review
- TestFlight or release-candidate build delivery
- Archive validation and upload
- Build selection and submission preparation
- Coordination of client-supplied metadata, screenshots, privacy responses,
  support URL, agreements, and release controls
- Submission and a bounded number of App Review response or resubmission rounds
- Approved manual, automatic, or phased release configuration

The client remains responsible for truthful legal, privacy, tax, banking,
content-rights, age-rating, and business representations unless a qualified
third party is separately engaged.

### Direct Mac Distribution

Candidate included work:

- Confirm the exported artifact shape: app, ZIP, disk image, or installer
  package
- Validate Developer ID signing, hardened runtime, entitlements, embedded
  frameworks, helpers, extensions, and other nested code
- Submit the outermost deliverable for notarization and inspect the result
- Staple and validate the notarization ticket where the package shape supports
  it
- Test the exported deliverable and Gatekeeper launch experience on the agreed
  clean environment
- Produce checksums and release notes where included
- Deliver the approved artifact to the selected website or hosting owner

Successful notarization alone does not prove that an app installs, launches, or
works correctly. Acceptance is based on the exported artifact and its intended
distribution path, not a local Debug build.

### Distribution-Site Choices

Choose one separately priced delivery shape:

1. Supply the release artifact and instructions to the client’s existing site
   owner.
2. Add or update a download page on an eligible existing site.
3. Build a bounded companion distribution site with approved hosting and
   operational ownership.
4. Add separately scoped update feeds, download authorization, licensing,
   checkout, customer entitlements, or release automation.

A new website, redesign, content migration, customer account system, licensing
server, payment system, or updater is not implied merely because direct
distribution was selected.

### Monetization Choices

Monetization is selected and priced independently from the distribution channel:

- App Store paid download
- StoreKit in-app purchases
- StoreKit subscriptions
- Direct Mac sales or licensing
- Companion-site checkout
- Backend entitlement or subscription-state support

Each choice must identify product rules, account ownership, refund/support
ownership, server requirements, and the source of legal and tax terms before a
fixed price is approved.

### Completion Criteria

- The agreed release candidate passed the defined distribution checks.
- The app was submitted, released, or handed over as an accepted notarized
  direct-distribution artifact according to the selected channel.
- The selected website owner received the approved artifact and release details
  when direct distribution was included.
- The launch watch concluded and eligible reports were triaged through its end
  date.
- Included remediation, patch, and review-response allowances were either used
  or explicitly declined.
- The client received the release record and remaining recommendations.

### Excluded Unless Added

- Guaranteed approval, review time, ranking, downloads, revenue, or retention
- Unlimited App Review rounds, patch releases, or defect remediation
- Marketing strategy, advertising, press, or tester/customer acquisition
- Store artwork, screenshots, copywriting, localization, legal text, or policy
  drafting
- New product features discovered during release preparation
- Permanent production operation, emergency on-call coverage, or an unbounded
  support obligation
- Distribution-site work beyond the selected site option

## Offer: Ongoing Care

### Outcome

Reserved post-launch engineering capacity for keeping an eligible product
compatible, diagnosable, and releasable without opening a new project for every
small maintenance need.

### Candidate Public Card

> **Ongoing Care**
>
> Keep the product sharp after launch with compatibility updates, crash and
> performance investigation, release support, and a reserved monthly engineering
> allowance.

### Candidate Included Work

- Triage crash, hang, performance, and user reports
- Compatibility work for supported Apple OS and Xcode releases
- Dependency and framework maintenance
- Small defect fixes within the monthly allowance
- Agreed App Store or direct-distribution maintenance releases
- Backend or distribution-site maintenance only when those components are
  explicitly included
- A concise monthly work and product-health summary

### Candidate Terms

- Launch and Distribution includes six weeks of post-launch care when selected
  without an external beta. A selected two- or four-week beta uses the same
  service window and leaves four or two weeks of post-launch care respectively.
- One-, three-, and six-month care terms may be offered at standard prices.
- Nine-, twelve-, eighteen-, or twenty-four-month terms require custom review
  until longer-term demand and operating cost are understood.
- Every plan defines its monthly engineering allowance, response target,
  supported components, release allowance, communication channel, and business
  hours.
- Response targets acknowledge the report and begin triage; they do not
  guarantee resolution within the same period.

### Decisions Still Needed

- Monthly allowance unit: hours, points, incidents, or a hybrid
- Whether unused allowance expires or rolls forward
- Number of maintenance releases included per term
- Standard response targets and business-hour calendar
- Whether unused term capacity can be applied to small improvements
- Renewal, cancellation, pause, and handoff rules
- Emergency work policy and pricing
- Eligibility of products Gale did not build or launch

### Excluded Unless Added

- New feature development beyond the plan’s improvement allowance
- Major redesigns, migrations, or architecture changes
- Continuous 24/7 monitoring or emergency on-call coverage
- Third-party service charges and vendor outages
- Support for components not named in the accepted plan
- Guaranteed resolution times

## Structured Intake

The website flow should reveal only questions relevant to the selected offer.

### Common Questions

- What product and platform are involved?
- Is this a new product or an existing codebase?
- What outcome do you want from this offer?
- What is the target date, and what makes that date important?
- Where are the source code, developer accounts, and infrastructure owned?
- What currently builds, works, fails, or blocks release?
- What user, account, payment, health, or other sensitive data is involved?
- Who can approve product, account, privacy, and release decisions?

### Beta Questions

- Internal testers, invited external testers, or a public link?
- Who supplies and communicates with testers?
- Which devices, OS versions, accounts, data, and workflows matter?
- What questions should the beta answer?
- What makes an issue release-blocking?
- Is Apple-hosted evidence sufficient, or is centralized MetricKit ingestion
  required?

### Launch Questions

- App Store, direct Mac distribution, or both as separately scoped channels?
- Launch-only, two-week-beta, or four-week-beta path?
- Is App Store Connect already configured and contractually ready?
- Which metadata, artwork, privacy responses, and support resources already
  exist?
- For direct Mac distribution, what package and website path are intended?
- Which monetization model and customer-entitlement rules apply?

### Ongoing-Care Questions

- Which app, backend, website, and distribution components are covered?
- Which reports and diagnostic sources should Gale review?
- What response target and communication channel are expected?
- How much reserved maintenance capacity is useful each month?
- Who approves patches, releases, and work that exceeds the allowance?

## Pricing Model To Approve

Each public fixed price should be assembled from explicit components:

1. Base outcome and eligibility assumptions
2. Duration or support term
3. Platform and distribution channel
4. Tester, device, build, review-round, or release limits
5. Included remediation allowance
6. Telemetry and data-handling option
7. Distribution-site option
8. Monetization option
9. Expedited scheduling, if offered

The displayed price may be fixed for products that meet the published
assumptions. Submission is a request for review, not automatic acceptance. A
product that falls outside those assumptions receives a revised proposal rather
than hidden overage or an impossible promise.

## Commercial Decisions Before Publication

1. Final public names and descriptions for all three offers
2. Whether and how client, App Review, credential, asset, build, or other waits
   pause or extend a beta or support window
3. Tester responsibility, cohort limits, and supported device matrix
4. Included beta builds, patch releases, and App Review rounds
5. Remediation allowance and eligible defect definition
6. Exact MetricKit baseline behavior and custom-ingestion option or pricing
7. App Store and direct Mac distribution baseline prices
8. Direct-distribution package and website options
9. Supported monetization configurations
10. Ongoing-care terms, allowances, response targets, and rollover rules
11. Client cancellation, rescheduling, refund, and handoff rules
12. Invoice schedule, deposit, taxes, third-party charges, and payment timing
13. Source, artifact, credential, account, and data ownership
14. Warranty treatment for defects in work delivered under the offer

## Implementation Sequence

1. Approve the offer names, outcomes, dependencies, exclusions, and composition.
2. Choose the remaining allowances, pause rules, and launch-path boundaries.
3. Price the eligible baseline and each selectable option.
4. Review commercial and legal terms with appropriate professional help where
   needed.
5. Finalize the public card copy in [MESSAGING_REVIEW.md](MESSAGING_REVIEW.md).
6. Design the conditional project-intake fields and review state.
7. Implement invoicing or payment only after the offer and review workflow are
   approved.
8. Validate the complete customer and operator experience before publication.

## Authoritative Apple References

- [TestFlight](https://developer.apple.com/testflight/)
- [TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/)
- [MetricKit](https://developer.apple.com/documentation/metrickit)
- [Distributing apps for beta testing and releases](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases/)
- [Signing Mac software with Developer ID](https://developer.apple.com/developer-id/)
- [Notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
