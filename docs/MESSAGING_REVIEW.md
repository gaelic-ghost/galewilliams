# Messaging Review

## Status

Draft for review. This document proposes a direction and candidate copy; it
does not authorize a public-site or Upwork rewrite by itself.

## Objective

Present Gale Williams primarily as an experienced iOS and macOS software
engineer. Lead with understandable Apple-platform development services and
outcomes. Treat audio, integrations, automation, and AI as supporting
capabilities or project-specific experience rather than the identity of the
business.

The contact page is already moving in this direction: Upwork is the primary
path for new software projects, while the protected secondary form is reserved
for other professional inquiries.

## Recommended Positioning

Primary statement:

> I design and build thoughtful, reliable software for iPhone, iPad, and Mac.

Supporting statement:

> From a focused utility to a production app and its supporting services, I can
> help shape the product, build the interface and underlying systems, connect
> the services it depends on, and prepare it for release.

Short professional label:

> iOS and macOS software engineer

This direction is deliberately traditional and legible. It tells a prospective
client what Gale builds before discussing implementation techniques.

## Voice And Vocabulary

Use:

- First-person, direct language: “I design,” “I build,” and “I can help.”
- Platform names people recognize: iPhone, iPad, Mac, iOS, iPadOS, and macOS.
- Concrete work: new apps, existing-app improvements, integrations, debugging,
  performance, accessibility, testing, and release preparation.
- “Independent software engineer” or “independent software studio” depending
  on whether the page is describing Gale personally or the business surface.
- Audio, speech, MIDI, and media software where that expertise is relevant.

De-emphasize:

- Agentic, agents, AI workflows, RAG, and automation in headlines or global
  descriptions.
- Plugins as a top-level business category; describe the actual app or
  integration outcome instead.
- Broad “personal versus business” segmentation when both audiences need the
  same Apple-platform engineering capabilities.
- “Flat-rate” until a bounded offer, scope, and price have been approved.

AI and automation do not need to be disowned. They can remain accurate
portfolio details, skills, or implementation options when a specific project
benefits from them.

## Proposed Site Structure

Recommended: make `/services` the complete services page and retire the
personal/SMB split. Redirect `/services/personal` and `/services/business` to
`/services` so existing links continue to work.

Suggested service groups:

1. New iPhone, iPad, and Mac apps
2. Existing-app improvements and modernization
3. App integrations and supporting services
4. Audio, speech, MIDI, and media software

This is a small information-architecture change, not merely a wording change.
It should be approved before implementation because it changes routes and how
prospective clients understand the service catalog.

## Site Copy Matrix

| Surface | Current emphasis | Proposed copy |
| --- | --- | --- |
| Home title | “Agentic apps, plugins, and integrations” | “Gale Williams \| iOS and macOS software engineer” |
| Home eyebrow | “Independent software studio” | Keep as written |
| Home heading | “Software that makes work easier.” | “Thoughtful software for iPhone, iPad, and Mac.” |
| Home summary | Apps, automations, and integrations | “I design and build Apple-platform apps that are clear, capable, and made for the people using them.” |
| Home card 1 | Agents | “iPhone and iPad” — “Native apps built around a focused, useful experience.” |
| Home card 2 | Apps | “Mac” — “Purpose-built Mac software that feels at home on the platform.” |
| Home card 3 | Integrations | “Supporting services” — “APIs, cloud services, and integrations that help the app do its job.” |
| Services intro | Automation-to-app range | “New apps, improvements to existing software, and the services that support them.” |
| About summary | Apps, automations, integrations | “I’m an independent software engineer focused on thoughtful, reliable software for Apple platforms.” |
| About body | Apple platforms, web services, automation, and AI | “My work spans native Apple-platform development, supporting web services and integrations, and audio or speech systems. I care about practical architecture, honest tradeoffs, accessibility, and software that does not make people fight it.” |
| Footer | Agentic apps, plugins, integrations | “iPhone, iPad, and Mac software by Gale Williams.” |
| Global project CTA | “Start a project” | Keep; it now leads to the Upwork-primary contact page |

## Draft Services Copy

### Page introduction

Eyebrow:

> Services

Heading:

> Apple-platform software, built with care.

Summary:

> I build new apps, improve existing software, and connect the services an app
> needs behind the scenes.

### New apps

> Turn an idea or an existing workflow into a native iPhone, iPad, or Mac app.
> We’ll define the useful first release, choose the right platform shape, and
> build toward software that can grow without becoming confusing.

### Existing apps

> Improve, modernize, or extend an app that already exists. This can include
> new features, interface work, Swift and framework updates, performance,
> accessibility, difficult bugs, or release preparation.

### Integrations and supporting services

> Connect an app to APIs, cloud services, local tools, accounts, data, or other
> systems it depends on. The app remains the product; the integration exists to
> make it useful and reliable.

### Audio and media software

> Build or improve software involving audio, speech, MIDI, playback, recording,
> media processing, or Apple’s audio frameworks.

## Upwork Review

### Current mismatch

The current profile title and opening overview place AI agents and automation
beside macOS and iOS as equal specialties. The strongest-lanes list, portfolio
titles, and skills repeat that emphasis. A visitor sent from the revised contact
page will therefore encounter the old positioning immediately.

### Proposed title

> iOS & macOS Software Engineer | Swift, SwiftUI, Audio

### Proposed overview

> Heya! I design and build software for iPhone, iPad, and Mac.
>
> I’m a strong fit when you need one experienced engineer to take an
> Apple-platform app from an early idea through architecture, interface design,
> implementation, integration, testing, and release.
>
> My strongest areas are:
>
> - Native iOS, iPadOS, and macOS apps in Swift, SwiftUI, UIKit, and AppKit.
> - Existing-app improvements, modernization, debugging, and performance work.
> - APIs, cloud services, and integrations that support the app.
> - Audio, speech, MIDI, and media software.
>
> I work directly, communicate clearly, and leave you with software you can
> understand and maintain.
>
> Thanks for reading!

### Portfolio treatment

- Keep SpeakSwiftly prominent, but describe it as a macOS speech and voice
  service rather than leading with AI.
- Keep SwiftASB as evidence of SDK and integration architecture, while moving
  “AI Agent” out of the title if the revised description remains accurate.
- Keep SwiftlyFetch as evidence of local search and knowledge-system work, but
  do not make RAG terminology the first thing a general software client sees.
- Prefer future portfolio entries that show shipped iOS/macOS interfaces,
  platform integration, audio, accessibility, or release outcomes.

### Skills ordering

Place Swift, macOS, iOS, SwiftUI, UIKit, AppKit, Xcode, software architecture,
desktop application development, API integration, and audio/media skills first.
Keep accurate AI and automation skills lower in the list rather than removing
useful evidence of experience.

## Decisions Needed Before Implementation

1. Use “independent software engineer” or “independent software studio” as the
   dominant identity?
2. Keep iPad explicit everywhere, or use “iOS and macOS” as shorthand in titles?
3. Keep audio/media as a visible fourth service, or treat it as portfolio-only
   specialization?
4. Replace the personal/SMB service routes with one services page, as
   recommended, or preserve the two-audience structure?
5. Keep “Heya!” in the Upwork overview, or use a more formal opening there?
6. Should the site mention Android or web-app delivery at all, or present those
   only as supporting work around an Apple-platform product?
7. Is the existing public hourly rate part of this positioning review, or
   intentionally out of scope?

## Approval And Implementation Sequence

1. Review the positioning statement, vocabulary, service structure, and seven
   decisions above.
2. Revise this document until the copy is approved.
3. Implement the approved site copy, route redirects, metadata, sitemap, and
   tests in one coherent pass.
4. Review the rendered site before release.
5. Update the Upwork profile to match. Treat this as a separate external edit
   requiring explicit authorization at the time it is performed.
