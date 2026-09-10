# Website Messaging Review

## Status

Draft website plan for final copy review. The positioning and structural
decisions recorded below are approved; the candidate wording still needs a
final review before implementation.

This document covers `galewilliams.com`. Upwork profile wording, portfolio
ordering, skills, and rates are intentionally out of scope and should be handled
in a separate document and external-edit pass.

## Approved Direction

Present Gale Williams as an independent software engineer who designs and builds
Apple-platform products end to end. Lead with native software for iPhone, iPad,
and Mac. Describe system software, Swift backends, web surfaces, integrations,
and audio engineering as supporting depth within that focus.

The site should make the primary work understandable before naming frameworks,
hosting choices, or other implementation details.

Approved positioning decisions:

- Use **independent software engineer** as the primary identity.
- Use **iOS and macOS** in compact titles. Name iPhone, iPad, and Mac in visible
  page copy where space allows.
- Present end-to-end product ownership as a core strength: product definition,
  architecture, interface or command-line implementation, system services,
  supporting backends, testing, and release preparation.
- Focus the service catalog on Swift and Apple platforms.
- Include graphical apps, command-line tools, background services, and other
  system software within the Apple-platform focus.
- Present application backends and web surfaces as supporting parts of an
  Apple-platform product. Gale builds these in Swift with Hummingbird or Vapor
  and deploys them to AWS, including Lambda, or to a VPS when appropriate.
- Present audio, speech, MIDI, and media engineering as a visible supporting
  specialization, not as an equal top-level business identity.
- Replace the personal/SMB service split with one complete `/services` page.
- Keep the current contact page structure and copy during this messaging pass.
  Upwork remains the primary path for new software projects; the protected
  secondary form remains for other professional inquiries.
- Do not market standalone Android or general-purpose web-app delivery on this
  site. Mention web work where it supports an Apple-platform product.

## Positioning Statements

Primary statement:

> I design and build native software for iPhone, iPad, and Mac.

Supporting statement:

> I take Apple-platform products all the way from idea to launch, including the app, backend APIs, App Store or direct Mac distribution, and monetization.

Short professional label:

> Independent iOS and macOS software engineer

This positioning is deliberately direct. It tells prospective clients what
Gale builds, how much of the product Gale can own, and where the supporting
technical specialties fit.

## Voice And Vocabulary

Use:

- First-person, direct language: “I design,” “I build,” and “I can help.”
- Familiar product names in prominent copy: iPhone, iPad, and Mac.
- Platform names in compact or technical contexts: iOS, iPadOS, and macOS.
- Concrete work: new products, existing-app improvements, graphical
  interfaces, command-line tools, background services, integrations,
  accessibility, debugging, performance, testing, and release preparation.
- “Independent software engineer” when describing Gale or the business.
- “Swift backends,” “APIs,” or “web surfaces” when describing server-side work
  that supports an app.
- Audio, speech, MIDI, and media software where that specialization is
  relevant.

De-emphasize:

- Agentic, agents, AI workflows, RAG, and automation in headlines or global
  descriptions.
- Plugins as a top-level business category. Describe the app, system service,
  integration, or user outcome instead.
- Broad personal-versus-business segmentation when both audiences need the
  same Apple-platform engineering capabilities.
- Standalone Android development and general-purpose website or web-app work.
- “Flat-rate” or other pricing language until a bounded offer, scope, and price
  have been approved.
- Repeated adjectives such as “thoughtful,” “clear,” “reliable,” and “useful”
  when a concrete capability or outcome can say more.

AI and automation do not need to be disowned. They can remain accurate project
details, implementation options, or portfolio evidence when a particular
product benefits from them.

## Credibility And External Links

Credibility should ultimately come from verifiable work and history rather than
unsupported marketing claims. Likely sources include:

- GitHub projects
- Released App Store software
- Public TestFlight betas where appropriate
- LinkedIn and relevant industry history
- Focused project or product descriptions

A reusable header or footer component may later present a concise row of icons
linking to GitHub, LinkedIn, the App Store, and other approved profiles. That is
deferred until after the current higher-priority site work and is not part of
this messaging implementation.

## Services Structure

Make `/services` the complete services page. Permanently redirect
`/services/personal` and `/services/business` to `/services`, and remove the old
pages from the HTML and XML sitemaps.

Keep these redirects in the Vapor application rather than relying on
Cloudflare configuration. Two application routes are small, portable, visible
in the repository, and directly covered by tests. Cloudflare redirects would
add external configuration without materially simplifying the site.

Organize the page into build, ship/support, and specialized engineering, so the
hierarchy matches the positioning. 

Build:

1. New iPhone and iPad products
2. Mac apps, command-line tools, and background services
3. Existing-app improvements and modernization

Ship and support:

1. Instrumented Beta Run
2. Launch and Distribution
3. Ongoing Care

Specialized engineering:

1. iOS 27 modernization, App Intents and Siri AI integration, Core AI and MLX, and adaptive interfaces for the foldable iPhone Duo
2. AI and Agents, Siri AI and Apple Private Cloud Compute (PCC), Core AI and MLX, Core ML
3. Swift backends, APIs, and web surfaces
4. Audio, speech, transcription, MIDI, and media software

The first implementation should present these as clear service capabilities.
The structure should leave room for future bounded offers without pretending
that prices, choices, or fulfillment rules have already been approved.

### Future Structured Project Start

The intended later services experience is a low-friction, productized flow:

1. Pick a bounded project option.
2. Make a small number of relevant choices.
3. Supply the minimum useful project details.
4. Submit the request for Gale’s review.
5. Receive an invoice or a request for clarification.

That future flow is distinct from the live secondary contact form. It will need
approved offers, scope boundaries, prices, intake fields, review rules, payment
handling, and fulfillment expectations before implementation. None of those
commercial mechanics are part of this messaging pass.

## Site Copy Matrix

| Surface | Candidate direction |
| --- | --- |
| Home title | “Gale Williams \| iOS and macOS software engineer” |
| Home eyebrow | “Independent software engineer” |
| Home heading | “Software for iPhone, iPad, and Mac.” |
| Home summary | “I design and build native Apple-platform products end to end, from screens and features to the system services and backends they depend on.” |
| Home card 1 | **iPhone and iPad** — “Native apps made for humans. Fast, efficient, thoroughly polished.” |
| Home card 2 | **Mac** — “Apps, command-line tools, and background services that feel at home on macOS.” |
| Home card 3 | **Full-stack support** — “Swift backends, APIs, integrations, and web surfaces built to support the grandest of plans.” |
| Services title | “iOS and macOS Software Services \| Gale Williams” |
| Services eyebrow | “Services” |
| Services heading| “Apple-platform software, built end to end.” |
| Services summary | “I build native iPhone, iPad, and Mac apps, system tools, and the Swift services behind them.” |
| About summary | “I’m an independent software engineer focused on native apps and system software for Apple platforms.” |
| About body | "Most of my work ties deeply into the Swift language and Apple’s platforms. I enjoy working on each layer of a project, from the interface people see to the system services doing the heavy lifting, and the backend that keeps everything connected. I like owning the whole product because the pieces work better when they’re designed together. I care about software that feels clean, cohesive, and intuitive, whether it's being used by a person, their assistive technology, or an AI agent. Clear structure, meaningful labels, and predictable interactions make software more accessible to all three."             |
| Apps heading | “Apps and releases” |
| Apps summary | “Released apps, TestFlight betas, downloads, and support links will appear here as they become available.” |
| Apps empty state | “No public releases are listed yet.”  |
| Contact page | Keep the current Upwork-primary project path and secondary professional-inquiry form as written. Do not turn the secondary form back into project intake. |
| Footer | “iPhone, iPad, and Mac software by Gale Williams.” |
| Social card | “Apps · Systems · Swift” |
| HTML sitemap | Describe the unified services page and remove the personal and business service entries. |
| XML sitemap | Remove the retired service URLs. Keep `/services` as the canonical service URL. |
| Global project CTA | Keep “Start a project.” It leads to the Upwork-primary contact page. |

## Draft Services Copy

### Build

#### New iPhone and iPad products

> Turn an idea or an existing workflow into native software for iPhone or iPad. I can help define the first release and carry it through architecture,
> interface design, implementation, testing, and distribution with monetization.

#### Mac apps and system software

> Build software that takes full advantage of the Mac, including menu bar utilities, command-line tools, background services, system framework integrations, and local AI inference.

#### Existing-app improvements and modernization

> Improve, modernize, or extend your existing software. Add new screens and features, adopt Swift concurrency, update frameworks, improve accessibility and performance, fix the bugs nobody else wants to touch, or prepare for the next release.

### Ship and Support

#### Instrumented Beta Run

>Put the app in real testers’ hands so you can lift off confidently instead of flying blind. I’ll configure TestFlight, add focused logging and MetricKit diagnostics, monitor crashes and performance, organize tester reports, fix issues within the agreed engineering budget, and deliver a release candidate with a findings report.

#### Launch and Distribution

> Take a finished app through the last hard mile. I’ll prepare and validate the release, configure privacy-aware diagnostics, and launch through the App Store or signed and notarized direct Mac distribution. Launch directly with six weeks of post-launch support, or choose a two- or four-week beta and use the rest of that six-week window after launch.

#### Ongoing Care

> Keep your product sharp after launch with compatibility updates, crash and performance investigation, release support, and a reserved monthly engineering allowance.

### Specialized Engineering

#### Latest and greatest

> Adaptive interfaces for everything from the foldable iPhone Duo to the fan-favorite iPad mini and cult-classic iPhone mini.

#### AI and intelligent system integration

> Siri AI, and Private Cloud Compute (PCC) integrations for sleek, secure integrations with Apple's hybrid intelligence systems.
> Core AI and MLX for high-performance, local AI and agents.
> Evaluation of existing Core ML or MLX workloads, modernizing with Core AI where it provides a concrete product or performance benefit.

#### Swift backends and web surfaces

> When an Apple-platform product needs a backend API, third-party integrations, or companion website, I can build the supporting layer in Swift and deploy it to AWS or a VPS. My server-side stack includes Hummingbird, Vapor, Lambda, DynamoDB, and Lightsail.

#### Audio and media software

> I bring specialized experience with audio software engineering, including speech synthesis and transcription, MIDI, recording and playback, and media processing pipelines. I work directly with AVFoundation, Core Audio, and Core Media to deliver the performance and deep platform integration Apple users expect.

## Metadata Drafts

Homepage description:

> Gale Williams designs and builds native iPhone, iPad, and Mac apps, system
> software, and supporting Swift services.

Services description:

> End-to-end iOS and macOS software development, including native apps, Mac
> system software, Swift backends, integrations, and audio products.

About description:

> Learn about Gale Williams, an independent iOS and macOS software engineer
> focused on end-to-end Apple-platform products.

Apps description:

> Apps, TestFlight betas, downloads, and support information from Gale Williams.

## Implementation Coverage

Once the candidate copy is approved, update the website in one coherent pass:

- Page titles, descriptions, Open Graph metadata, and Twitter metadata
- Homepage introduction and three capability cards
- Unified services page content and hierarchy
- Permanent application redirects for the two retired service routes
- About page introduction and body
- Apps page introduction and empty state
- Footer wording
- Dedicated social-preview card wording and asset
- HTML sitemap summaries and entries
- XML sitemap URLs
- README route and public-surface descriptions where they become inaccurate
- Route, redirect, canonical URL, sitemap, metadata, and representative-copy
  tests

The contact page does not need a messaging rewrite in this pass.
