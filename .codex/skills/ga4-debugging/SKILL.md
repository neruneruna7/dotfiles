---
  name: ga4-debugging
  description: GA4, Firebase Analytics, Google Tag Manager, gtag, DebugView, oranalytics event delivery troubleshooting. Use when Codex needs to investigatewhy GA4 events are not visible in Network, Realtime, DebugView, or reports,especially in local development environments.
---

  # GA4 Analytics Debugging

  Use this skill when investigating GA4/Firebase Analytics/GTM event delivery.

  ## Core Rule

  Distinguish three facts:

  1. App code reached the analytics call.
  2. Browser sent a network request.
  3. GA4 received and displayed the event.

  A console log emitted after `logEvent()` or `gtag()` only proves the app code
  reached the call. It does not prove the browser sent the request or GA4
  received it.

  ## Local Debugging Checklist

  When Console logs show the app sent an analytics event but Network and
  DebugView show nothing, check browser-side blocking first.

  Common blockers:

  - Ad blockers such as uBlock Origin, AdGuard, or similar extensions
  - Brave Shields or privacy-focused browser protections
  - DNS filtering
  - Corporate proxies or network-level tracking protection
  - Cookie blocking
  - IndexedDB unavailable or blocked
  - Incognito settings that disable required storage or extensions
  inconsistently

  Recommended verification environment:

  - Use Chrome with privacy/ad-blocking extensions disabled.
  - Alternatively use a clean Chrome profile.
  - Disable Brave Shields if using Brave.
  - Confirm `navigator.cookieEnabled === true`.
  - Confirm `indexedDB` is available.
  - Confirm `window.gtag` is a function and `window.dataLayer` is an array when
  using gtag/Firebase Analytics.

  ## Network Checks

  Do not only filter by one request name. Search Network for:

  ```txt
  firebase
  google
  gtag
  collect
  g/collect
  googletagmanager
  google-analytics

  Expected requests may include:

  https://www.googletagmanager.com/gtag/js
  https://firebase.googleapis.com/v1alpha/projects/-/apps/.../webConfig
  https://www.google-analytics.com/g/collect

  For GA4 events, g/collect query parameters may include:

  en=<event_name>

  For example:

  en=audio_first_listen

  ## Firebase Analytics Notes

  For Firebase Analytics Web SDK, verify both of these:

  - Local config has the expected measurementId.
  - The Firebase appId is linked to the expected GA4 Web data stream.

  Do not assume that a correct .env Measurement ID alone proves the SDK is
  sending to the DebugView currently being inspected. Firebase Analytics may
  fetch dynamic web config based on the app ID.

  ## DebugView Notes

  debug_mode: true can make events appear in GA4 DebugView, but it should not be
  sent in production. In production, omit the debug_mode field entirely.

  Use DebugView as the strongest confirmation that GA4 received the event.
  Console is only app-level confirmation. Network is browser-send confirmation.
