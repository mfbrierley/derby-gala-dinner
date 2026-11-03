# Placeholder and unconfirmed content

All page copy is copied word-for-word from Will's Figma file (`dgd`). This list tracks
anything that is a placeholder in the Figma, anything written for the build that isn't in
the Figma, and open questions. Update it as items are resolved.

## Placeholders in the Figma (copied as-is)

### Home
- [ ] "Derby Gala Dinner proceeds have contributed to supporting **X** families with Bridge the Gap." — needs the real number.
- [ ] Sir Bradley Wiggins' subtitle is "TV personality and passionate educator.", the same as Bassit Siddiqui's. Probably a copy-paste in the Figma.
- [ ] "PLAY / This will be for a video once created." (below the footer in the Figma). **Not built yet**, waiting for the video.
- [ ] The "See how the Derby Gala Dinner 2026 unfolded." strip only has 3 photos in the Figma. They loop. (It uses its own 3 photos in `src/components/GalleryStrip.astro`, separate from the gallery folder.)

### Book a table
- [ ] Price formatting differs between the cards: "£2,500 +VAT" and "£3,500 + vat".
- [ ] The tile says "Welcome drinks sponsor" but the heading beside it says "Welcome drink sponsor".
- [ ] Mixed spelling: "event program" (Welcome drink and VIP lounge) vs "event programme" (Headline and Supporting).
- [ ] Availability ("1 remaining", "3 remaining", "Available") needs updating as packages sell. It's in the `packages` list at the top of `src/pages/book-a-table.astro`.

### Event details
- [ ] The heading "Intinery" is a typo for "Itinerary". It's kept as-is until confirmed.
- [ ] Itinerary and Menu both say "Coming soon...".
- [ ] The map in the Figma is a screenshot. The build uses a live Google map that only loads after cookies are accepted; until then the screenshot is shown dimmed behind the consent message.

### Your hosts
- [ ] Sir Bradley Wiggins and The Distractions bios are lorem ipsum.
- [ ] Spelling: the heading says "BASSIT SIDDIQUI" but his bio says "Baasit" (twice). Which is right?
- [ ] Sir Bradley Wiggins' subtitle is again "TV personality and passionate educator." (same as Bassit's).

### 2026 gallery
- [ ] **Needs the real 2026 photos.** The Figma grid repeats the same 3 photos (24 tiles), and the build does the same for now. Add the photos to `src/assets/gallery/` and set `PREVIEW_REPEAT` to `1` in `src/pages/gallery.astro` (see the README in that folder).
- [ ] Photo descriptions are generic ("Derby Gala Dinner 2026, photo 5 of 24"). Fine for a gallery, but they could be more specific.
- [ ] The photo strip at the bottom of the gallery page has a "View Gallery" button that links to the same page, as in the Figma. Keep it, or drop the strip on this page?

### Not built
- [ ] Sponsors: the whole page is marked "THIS PAGE WILL COME LATER WHEN WE HAVE THE SPONSORS SORTED" (lorem ipsum, "xx"). Not linked from anywhere in the Figma nav.

## Copy written for the build (not in the Figma), needs approval

- [ ] **Enquiry form, sponsorship intro:** "Please complete the form below to enquire about sponsorship. A member of our team will contact you within 24hrs to discuss." (The table version is verbatim from the Figma.)
- [ ] **Contact form (general enquiries):** intro "Please complete the form below and a member of our team will contact you within 24hrs." The message box label is "Message:". It uses the same "Enquiry Form / GET IN TOUCH. GET INVOLVED." heading as the Figma.
- [ ] **Form messages:** "Please fill in the highlighted fields.", "Please choose Evening Table, VIP Table or Sponsorship.", "Please complete the captcha check.", "Sorry, your enquiry couldn't be sent. Please try again in a moment.", "Sending…", plus the line under Submit: "We'll only use your details to respond to your enquiry. See our privacy policy."
- [ ] **Form options:** Title list (Mr, Mrs, Ms, Miss, Mx, Dr). Sponsorship package list (Headline sponsorship, Supporting sponsorship, Welcome drink sponsor, VIP lounge sponsor, Other sponsorship), taken from the Book a table frame.
- [ ] **Cookie banner:** all copy.
- [ ] **Map (before cookies are accepted):** "The live map is provided by Google, which sets cookies." with the buttons "Accept cookies and show map" and "Open in Google Maps".
- [ ] **Privacy policy page:** the whole page is a draft for the organiser to check (not legal advice). Needs:
  - [ ] [Organiser name]
  - [ ] [Organiser address]
  - [ ] [Privacy contact email]
  - [ ] Retention periods: [12 months] for enquiries, [6 years] for invoices
  - [ ] Confirm whether enquiry details are shared with Bridge the Gap (the draft says they aren't mentioned)
- [ ] **Footer:** added "Privacy policy" and "Cookie settings" links (needed for the policy and the cookie banner).
- [ ] **404 page:** "Page not found", "Sorry, we couldn't find that page.", "Back to home".
- [ ] **Image alt text and the site meta description.**

## Design decisions to confirm with Will

- [ ] The header from the Home / Book a table frames is used on every page, including Your hosts and Gallery (those frames still have the old TICKETS / ABOUT / CONTACT header) and Event details (that frame leaves out "Fundraising for Bridge the Gap" and the YOUR HOSTS / 2026 GALLERY links). The logo sits at the content edge (188px) as on 5 of the 6 frames; the Home frame has it further left (85px).
- [ ] In the nav, bold means the current page. On Home, BOOK A TABLE is bold, as in the Figma.
- [ ] YOUR HOSTS and 2026 GALLERY appear as a dropdown under EVENT DETAILS on hover.
- [ ] The home hero's "Book a table" opens the enquiry form. "Sponsor the event" and the "Find out more" buttons go to the Book a table page.
- [ ] Book a table page: each "Book a table" / "Secure your sponsorship now" button opens the enquiry form with that table or package already selected.
- [ ] Mobile and tablet layouts are adapted from the desktop design (there are no mobile frames).
- [ ] The thank-you pop-up is shorter than the Figma panel (1050px tall).
- [ ] Gallery: clicking a photo opens it full-size in a viewer (arrows, swipe, Esc to close). Not in the Figma.
- [ ] Gallery rows are evenly spaced; the Figma has one row gap that's smaller than the rest.
- [ ] Favicon: the DGD logo on a black square. Will may want to supply a proper one.
- [ ] No social sharing image (og:image) yet.

## Assets to request

- [ ] **Bridge the Gap logo as SVG.** It's built from masked layers in the Figma, so it's exported as a 225px PNG and looks slightly soft on high-resolution screens.
- [ ] **Bridge the Gap spotlight photo:** it's a screenshot (about 924px wide). An original would be sharper.
- (The other photos came out of the Figma at full resolution, so they're fine.)

## Setup to-dos

- [x] Web3Forms dashboard: hCaptcha switched on.
- [ ] Send a test enquiry from the preview to confirm submissions arrive (needs a person to tick the hCaptcha box).
- [ ] Adobe Fonts (Will's web project `hfo7qtb`): optionally set font-display to `swap`. No italics are used so far, so they could be removed from the project.
