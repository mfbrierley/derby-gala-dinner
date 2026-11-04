# Placeholder and unconfirmed content

All page copy is copied word-for-word from Will's Figma file (`dgd`). This list tracks
anything that is a placeholder in the Figma, anything written for the build that isn't in
the Figma, and open questions. Update it as items are resolved.

## Placeholders in the Figma (copied as-is)

### Home
- [x] Proceeds text (was "…supporting X families…") replaced with the Family support fund wording supplied by Matt.
- [x] Sir Bradley Wiggins' subtitle is now "Olympic gold medallist and first British Tour de France winner." (was a copy of Bassit's).
- [ ] "PLAY / This will be for a video once created." (below the footer in the Figma). **Not built yet**, waiting for the video.
- [ ] The "See how the Derby Gala Dinner 2026 unfolded." strip only has 3 photos in the Figma. They loop. (It uses its own 3 photos in `src/components/GalleryStrip.astro`, separate from the gallery folder.)

### Book a table
- [ ] Price formatting differs between the cards: "£2,500 +VAT" and "£3,500 + vat".
- [ ] The tile says "Welcome drinks sponsor" but the heading beside it says "Welcome drink sponsor".
- [ ] Mixed spelling: "event program" (Welcome drink and VIP lounge) vs "event programme" (Headline and Supporting).
- [ ] Availability ("1 remaining", "3 remaining", "Available") needs updating as packages sell. It's in the `packages` list at the top of `src/pages/book-a-table.astro`.

### Event details
- [x] "Intinery" heading corrected to "Itinerary".
- [ ] Itinerary and Menu both say "Coming soon...".
- [ ] The map in the Figma is a screenshot. The build uses a live Google map that only loads after cookies are accepted; until then the screenshot is shown dimmed behind the consent message.

### Your hosts
- [ ] Sir Bradley Wiggins and The Distractions bios are lorem ipsum.
- [ ] Spelling: the heading says "BASSIT SIDDIQUI" but his bio says "Baasit" (twice). Which is right?
- [x] Sir Bradley Wiggins' subtitle updated to match the home page.

### 2026 gallery
- [ ] **Needs the real 2026 photos.** The Figma grid repeats the same 3 photos (24 tiles), and the build does the same for now. Add the photos to `src/assets/gallery/` and set `PREVIEW_REPEAT` to `1` in `src/pages/gallery.astro` (see the README in that folder).
- [ ] Photo descriptions are generic ("Derby Gala Dinner 2026, photo 5 of 24"). Fine for a gallery, but they could be more specific.
- [x] Gallery page: the Bridge the Gap spotlight and the gold "See how…" photo strip have been removed (Matt). The page now goes straight from the photo grid to the footer.

### Sponsors (hero and footer, from the "dgd - matt" Figma)
- [ ] Logos and labels come from the Figma: Headline sponsor = Stratstone Land Rover Derby, Supporting sponsor = Enigma Seven, plus "A Volt7 production". They're set in one place, `src/data/sponsors.ts`, which feeds both the home hero and the footer. The logos don't link anywhere (Matt).
- [ ] The Enigma Seven logo is exported from the footer version in the Figma (the hero one is the same artwork, drawn slightly smaller).

### Not built
- [ ] Sponsors: the whole page is marked "THIS PAGE WILL COME LATER WHEN WE HAVE THE SPONSORS SORTED" (lorem ipsum, "xx"). Not linked from anywhere in the Figma nav.

## Copy written for the build (not in the Figma), needs approval

- [x] **Reserve a table and Sponsorship enquiry forms:** two separate forms, with heading, intro, fields and terms supplied by Matt. Required: name and email on both, plus a table type (booking) or at least one sponsorship type (sponsorship). Everything else is optional.
- [ ] **Contact form (general enquiries):** intro "Please complete the form below and a member of our team will contact you within 24hrs." The message box label is "Message:". It uses the same "Enquiry Form / GET IN TOUCH. GET INVOLVED." heading as the Figma.
- [ ] **Form messages:** "Please fill in the highlighted fields.", "Please choose a table type.", "Please choose at least one type of sponsorship.", "Please complete the captcha check.", "Sorry, your enquiry couldn't be sent. Please try again in a moment.", "Sending…", plus the line under Submit: "We'll only use your details to respond to your enquiry. See our privacy policy."
- [ ] **Form options:** table type and sponsorship type are picture buttons, from the form mockups in the "dgd - matt" Figma (only those parts of the mockups were used). Differences from the mockups:
  - A small "Table type" / "Type of sponsorship enquiry:" heading above the pictures (the mockups have none).
  - "Welcome drink sponsor" rather than the mockup's "Drinks sponsor", to match the rest of the site.
  - An extra, shorter "Other sponsorship" picture under the four in the mockup, because Other is in Matt's list and on the Book a table page.
  - Chosen: gold outline, gold name and a tick. The mockups show the gold outline for tables only.
  - Title list on the general contact form (Mr, Mrs, Ms, Miss, Mx, Dr).
- [ ] **Cookie banner:** all copy.
- [ ] **Map (before cookies are accepted):** "The live map is provided by Google, which sets cookies." with the buttons "Accept cookies and show map" and "Open in Google Maps".
- [ ] **Privacy policy page:** the whole page is a draft for the organiser to check (not legal advice). Needs:
  - [x] Organiser name: VOLT7
  - [x] Organiser address: 8 Mallard Way, Pride Park, Derby DE24 8GX
  - [x] Privacy contact email: hello@volt7.agency
  - [ ] Retention periods: [12 months] for enquiries, [6 years] for invoices
  - [ ] Confirm whether enquiry details are shared with Bridge the Gap (the draft says they aren't mentioned)
- [ ] **Footer:** added "Privacy policy" and "Cookie settings" links (needed for the policy and the cookie banner). They sit on the right of the black "A Volt7 production" bar on wide screens and below it on narrower ones.
- [ ] **404 page:** "Page not found", "Sorry, we couldn't find that page.", "Back to home".
- [ ] **Image alt text and the site meta description.**

## Design decisions to confirm with Will

- [ ] The new footer (sponsors plus the black Volt7 bar) is used on every page (Matt). It no longer has the "Fundraising for Bridge the Gap" lockup, as in the new Figma.
- [x] The "Fundraising for Bridge the Gap" lockup has been removed from the header and the phone menu on every page (Matt).
- [ ] The header from the Home / Book a table frames is used on every page, including Your hosts and Gallery (those frames still have the old TICKETS / ABOUT / CONTACT header) and Event details (that frame leaves out the YOUR HOSTS / 2026 GALLERY links). The logo sits at the content edge (188px) as on 5 of the 6 frames; the Home frame has it further left (85px).
- [ ] In the nav, bold means the current page. On Home, BOOK A TABLE is bold, as in the Figma.
- [ ] YOUR HOSTS and 2026 GALLERY appear as a dropdown under EVENT DETAILS on hover.
- [ ] The home hero's "Book a table" opens the Reserve a table form. "Sponsor the event" and the "Find out more" buttons go to the Book a table page.
- [ ] Book a table page: each "Book a table" button opens Reserve a table with that table type selected; each "Secure your sponsorship now" opens Sponsorship enquiry with that type ticked.
- [ ] Mobile and tablet layouts are adapted from the desktop design (there are no mobile frames).
- [ ] Home hero fills the screen with its content centred below the header (matches the Figma at 1728 × 996). On short screens the hero's text and sponsor logos scale down so it all stays above the fold. A phone held sideways is the one case where it scrolls.
- [ ] The thank-you pop-up is shorter than the Figma panel (1050px tall).
- [ ] Pop-ups scale down (to as little as half size) to fit the screen height. Both forms fit on screens 800px tall or more (e.g. MacBooks); on shorter screens they scroll inside the pop-up.
- [ ] All text is 10% smaller than the Figma sizes (Matt), set by `--type-scale` in `src/styles/global.css`. Body text stays at least 16px.
- [ ] Gallery: clicking a photo opens it full-size in a viewer (arrows, swipe, Esc to close). Not in the Figma.
- [ ] Gallery rows are evenly spaced; the Figma has one row gap that's smaller than the rest.
- [ ] Favicon: the DGD logo on a black square. Will may want to supply a proper one.
- [ ] No social sharing image (og:image) yet.

## Accessibility points from the full check (design decisions for Will)

Automated checks (axe-core, Lighthouse) pass apart from these, which all come from the design:

- [ ] **Gold on white headings** ("IT'S TIME TO MAKE A DIFFERENCE.", "BRIDGE THE GAP"): contrast 2.3:1. The guideline for large text is 3:1. A slightly deeper gold for headings on white (around `#9A7B33`) would pass.
- [ ] **White nav text on the gold header band** (inner pages): contrast 2.3:1. The guideline for small text is 4.5:1. Black nav text on the gold band would pass easily.
- [ ] **Desktop footer links** are stacked 16px apart. The guideline asks for 24px tap targets. More line spacing would fix it. (The phone footer already passes.)

## Assets to request

- [ ] **Bridge the Gap logo as SVG.** It's built from masked layers in the Figma, so it's exported as a 225px PNG and looks slightly soft on high-resolution screens.
- [ ] **Bridge the Gap spotlight photo:** it's a screenshot (about 924px wide). An original would be sharper.
- (The other photos came out of the Figma at full resolution, so they're fine.)

## Setup to-dos

- [x] Web3Forms dashboard: hCaptcha switched on.
- [ ] Send a test enquiry from the preview to confirm submissions arrive (needs a person to tick the hCaptcha box).
- [ ] Adobe Fonts (Will's web project `hfo7qtb`): optionally set font-display to `swap`. No italics are used so far, so they could be removed from the project.
