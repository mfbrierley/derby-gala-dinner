# Placeholder and unconfirmed content

All page copy is copied word-for-word from Will's Figma file (`dgd`). This list tracks
anything that is a placeholder in the Figma, anything written for the build that isn't in
the Figma, and open questions. Update it as items are resolved.

## Placeholders in the Figma (copied as-is)

### Home
- [x] Proceeds text (was "…supporting X families…") replaced with the Family support fund wording supplied by Matt.
- [x] Sir Bradley Wiggins' subtitle is now "Olympic gold medallist and first British Tour de France winner." (was a copy of Baasit's).
- [ ] "PLAY / This will be for a video once created." (below the footer in the Figma). **Not built yet**, waiting for the video.
- [ ] The "See how the Derby Gala Dinner 2026 unfolded." strip only has 3 photos in the Figma. They loop. (It uses its own 3 photos in `src/components/GalleryStrip.astro`, separate from the gallery folder.)

### Section backgrounds
- [x] The black body sections use a faded band of gold bars along the very top and very bottom, with plain black in between (Matt). Cut from "Bars 01" in the 06.Backgrounds Drive folder into a top and a bottom strip, at half strength; each band about 400px on a laptop (the bars reach about 350px in), at least 200px on phones. The footer has the bottom band only. Same image on every page.
- [x] Home and Your hosts: the top band fades to black on the left (behind the host photos), so the photos' dark backdrop boxes sit on plain black with no visible edge; the bars show on the right, behind the text. The backdrop's black was also matched to the page black (#080808). This replaces the stretched stripes image from the Figma.

### Home hero background
- [x] The hero background is now the "Gala Bars Final 1920x1080" video from the 06.Backgrounds Drive folder (Matt). Re-encoded from 22 MB to 4.6 MB at visually lossless quality (PSNR 52 dB on the bars), no sound, loops seamlessly. Its first frame is the still image shown while it loads.
- [ ] No pause / play button (removed at Matt's request). Accessibility guidelines ask for a way to pause anything that moves for more than 5 seconds, so this is a known gap; visitors who ask their device for reduced motion still get the still image.
- [ ] Visitors whose device asks for reduced motion see the still image, and the video isn't downloaded.

### Table photos
- [x] The Evening Table and VIP Table photos are the two from the green note in the "dgd - matt" Figma, everywhere they appear: the home page cards, the Book a table page and the booking pop-up. On the tall home page cards the photos are cropped around the guests.

### Book a table
- [x] White "Tables" and "Sponsors" headings added above the two gold intros, from the "dgd - matt" Figma. The Figma's gap under each heading differs slightly (20px and 6px); the build uses the same gap for both.
- [ ] Price formatting differs between the cards: "£2,500 +VAT" and "£3,500 + vat".
- [ ] The tile says "Welcome drinks sponsor" but the heading beside it says "Welcome drink sponsor".
- [ ] Mixed spelling: "event program" (Welcome drink and VIP lounge) vs "event programme" (Headline and Supporting).
- [ ] Availability ("1 remaining", "3 remaining", "Available") needs updating as packages sell. It's in the `packages` list at the top of `src/pages/book-a-table.astro`.

### Event details
- [x] Top section updated to the "dgd - matt" Figma: Date and Venue (address in white), gold lines between sections, Timings for VIP and Evening Guests, and Menu. Itinerary has been removed, as in the Figma.
- [x] Times are written with colons throughout (17:30, 18:00), as agreed with Matt; the Figma mixes "17.30" and "19:00".
- [ ] Menu still says "Coming soon...".
- [x] Event details: the "Date and Venue" box from the "dgd - matt" Figma is at the top of the page: date, Vaillant Live logo, address and a "View on maps" link on the left, the venue photo fading in from the right, in a white border. It replaces the old date, address and embedded Google map (Matt). "View on maps" opens Google Maps in a new tab.
- [x] With the embedded map gone the site needs no cookie consent, so the cookie banner, the "Cookie settings" footer link and the cookie-choice wording in the privacy policy are removed (Matt). The privacy policy's Cookies section now only covers hCaptcha (the spam check on the forms) and the Google Maps link.
- [x] Event details timings: "VIP" is now "VIP Guests" (Matt's green note in the Figma).
- [ ] On phones the Date and Venue box puts the photo across the top and the details underneath (not in the Figma, which is laptop only).

### Your hosts
- [x] Sir Bradley Wiggins bio supplied by Matt.
- [x] The Distractions bio supplied by Matt.
- [x] Spelling: it's "Baasit Siddiqui" (Matt). The Figma heading says "BASSIT"; the site now says Baasit everywhere.
- [x] Sir Bradley Wiggins' subtitle updated to match the home page.
- [x] Sir Bradley Wiggins' photo is the new one from Matt (smiling, helmet and sunglasses), on the home page and Your hosts. The file supplied is 670px wide where he appears, which is a little soft on high-resolution screens; a larger original would be sharper.
- [x] Host photo stripes (home and Your hosts): the Figma's stripes picture, in its Figma place, now fades out towards each of its edges so it melts into the black instead of stopping at a cropped edge (Matt). Same for all three rows.
- [x] The Distractions: the photo is the transparent cut-out from Matt, so it now has the stripes behind it like the other two. Most of the stripes sit behind the two performers; they show between and above them. The small part of the jacket that runs off the left of the picture fades out.

### 2026 gallery
- [x] The gallery is cut down to 9 photos, in the order of the "dgd - matt" Figma (Matt): `AVI00204`, `_DSC9770`, `AVI00381`, `AVI00309`, `_DSC9934`, `AVI00543`, `AVI00502`, `_DSC9952`, `AVI00208`. `AVI00502` fills the slot the Figma leaves empty (first in the third row). On phones the photos are two to a row, so the ninth sits on its own in the last row.
- [ ] `_DSC9952` (the guest with the microphone) is mirrored left to right, as it is in the Figma.
- [x] All 516 photos are still in `src/assets/gallery/`, so a photo can be swapped without finding the originals again; only the ones listed in `src/pages/gallery.astro` are uploaded to the website. Each photo now has its own description for screen readers.
- [x] **Film above the photos** ("I'll send you last years video to go here" in the Figma): `BRIDGE_THE_GAP_V3.mp4` from Matt (3 minutes 30, 1080p). It is hosted on the site itself, on IONOS, with no YouTube or other outside player (Matt). Compressed from 417 MB to 65 MB, the same size and frame rate, sound kept; nothing is downloaded until play is pressed. The file is `src/assets/video/gallery-2026.mp4`.
- [ ] The still image shown before play is a frame from the film, 1 minute 48 seconds in (the room and stage from the back). Not chosen by Matt; any frame or photo can be used instead (`src/assets/images/gallery-2026-poster.jpg`).
- [ ] The player is the site's own (`src/components/VideoPlayer.astro`), not in the Figma: a gold play button over the still image, then a control bar with play / pause, time, a gold progress line, sound on / off and full screen. The bar fades away while the film plays. It is 16:9 and as wide as the photo grid (the Figma's box is a wider, shallower shape), and never taller than the screen. On iPhones, full screen uses Apple's own player, the only kind they allow.
- [ ] **The film has speech throughout but no subtitles**, so deaf and hard-of-hearing visitors, and anyone watching with the sound off, miss what's said. Subtitles can be added to the player from a subtitle file (.vtt or .srt).
- [x] Gallery page: the Bridge The Gap spotlight and the gold "See how…" photo strip have been removed (Matt). The page now goes straight from the photo grid to the footer.

### Sponsors (hero and footer, from the "dgd - matt" Figma)
- [ ] Logos and labels come from the Figma: Headline sponsor = Stratstone Land Rover Derby; Supporting sponsors = Enigma Seven and Volt7; plus "A [Volt7 logo] production". They're set in one place, `src/data/sponsors.ts`, which feeds both the home hero and the footer. The logos don't link anywhere (Matt).
- [x] Home page "Sponsor Packages": the four tiles are links to their package on the Book a table page (Headline, Supporting, Welcome drinks, VIP lounge) and get a gold border on hover, the same line as a chosen tile in the enquiry form (Matt).
- [x] Home page "Book a table": the Evening Table and VIP Table cards zoom their photo slightly on hover, like the sponsor tiles, and the whole card is clickable, not only its button (Matt).
- [x] The charity's name is written "Bridge The Gap" everywhere (Matt).
- [x] Book a table: a gold-bordered "Considering sponsorship? All sponsor packages include a table for 10 guests." box sits between the intro and the Evening Table, from Matt's mockup. Not in the mockup: the whole box is a link down to the Sponsors section of the same page.
- [x] Book a table: a "Donate a seat" section sits between the VIP Table and the Sponsors section, from Matt's mockup. Its "Book a table" button opens the table booking form with no table chosen.
- [ ] The booking form has no "donate a seat or table" option, so someone donating has to say so in their message. Worth adding?
- [x] The gold is `#BA9863` everywhere (Matt): one value, `--gold` in `src/styles/global.css`, plus the gold line and gold table icon. The "Headline sponsor" label in the hero and footer is gold, like its lines; "Supporting sponsors" stays white. The gold bars in the background images and hero video are photographs and keep their own colour.
- [ ] The hero shows the headline sponsor and, under it, the supporting sponsors without Volt7 (so Enigma Seven for now), because "A Volt7 production" is the next line down, as in the Figma. The footer shows both rows in full.
- [ ] **More supporting sponsors are coming.** The Figma leaves a gap under them for now; the build closes it (the space under the logos matches the space at the top of the footer). Add each new sponsor to `SUPPORTING_SPONSORS` in `src/data/sponsors.ts` and the rows in the hero and the footer grow. The hero fills the screen with one supporting sponsor; with several more it will get taller than the screen on small laptops and phones, so its spacing will want another look then.

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
- [x] **Cookie banner and embedded map:** removed (Matt). See Event details below.
- [x] **Enquiry forms (Matt, from the Figma notes):** the table booking form asks for a contact number instead of a VAT number (optional, like the VAT field was); each table type shows its price under its name (£2,500 + VAT, £3,500 + VAT, the same as the Book a table page); the line under Submit on all three forms now reads "We'll only use your details to respond to your enquiry and communicate for future events and promotions. See our privacy policy."
- [x] **How the forms send (Matt):** the three forms no longer use Web3Forms. They post to the site's own endpoint on the IONOS hosting, which sends the email through Resend from a Zap Digital address, with replies going to the enquirer. The spam check is Cloudflare Turnstile in place of hCaptcha. See README > Enquiry forms.
- [ ] **Privacy policy:** now names Resend (and that Zap Digital manages the Resend account) and Cloudflare Turnstile in place of Web3Forms and hCaptcha, and mentions the scrambled record used to limit repeat enquiries. Needs checking with the rest of the policy.
- [ ] **Marketing wording needs checking.** The privacy policy used to say "We will not use your details for marketing unless you ask us to". It now says details are also used to tell people about future events and promotions, with a way to opt out by email, so it matches the forms. UK rules on marketing emails usually expect people to be given a clear choice at the point they hand over their details (for example a tick box), so this is worth checking with whoever signs off the policy.
- [ ] **Privacy policy page:** the whole page is a draft for the organiser to check (not legal advice). Needs:
  - [x] Organiser name: VOLT7
  - [x] Organiser address: 8 Mallard Way, Pride Park, Derby DE24 8GX
  - [x] Privacy contact email: hello@volt7.agency
  - [ ] Retention periods: [12 months] for enquiries, [6 years] for invoices
  - [ ] Confirm whether enquiry details are shared with Bridge The Gap (the draft says they aren't mentioned)
- [ ] **Footer:** added a "Privacy policy" link. It sits on the right of the black "A Volt7 production" bar on wide screens and below it on narrower ones. (The "Cookie settings" link went with the cookie banner.)
- [ ] **404 page:** "Page not found", "Sorry, we couldn't find that page.", "Back to home".
- [ ] **Image alt text and the site meta description.**

## Design decisions to confirm with Will

- [ ] The footer from the latest "dgd - matt" Figma is used on every page (Matt): logo, nav, gold divider and "Fundraising for Bridge The Gap" along the top, then the sponsors, then the black Volt7 bar.
- [x] The "Fundraising for Bridge The Gap" lockup has been removed from the header and the phone menu on every page (Matt). It now appears in the footer only.
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

- [ ] **Gold on white headings** ("IT'S TIME TO MAKE A DIFFERENCE.", "BRIDGE THE GAP"): contrast 2.7:1. The guideline for large text is 3:1. A slightly deeper gold for headings on white (around `#9A7B33`) would pass.
- [ ] **White nav text on the gold header band** (inner pages): contrast 2.7:1. The guideline for small text is 4.5:1. Black nav text on the gold band would pass easily.
- [ ] **Desktop footer links** are stacked 16px apart. The guideline asks for 24px tap targets. More line spacing would fix it. (The phone footer already passes.)

## Assets to request

- [ ] **Bridge The Gap logo as SVG.** It's built from masked layers in the Figma, so it's exported as a 225px PNG and looks slightly soft on high-resolution screens.
- [ ] **Bridge The Gap spotlight photo:** it's a screenshot (about 924px wide). An original would be sharper.
- (The other photos came out of the Figma at full resolution, so they're fine.)

## Setup to-dos

- [ ] Send a test enquiry from each form on the live site to confirm they arrive and that replying goes to the enquirer. The forms can't send from the Vercel previews or `npm run dev` (no PHP there); README > Enquiry forms has a way to try them on your own machine.
- [ ] Once the new forms are live: delete the old Web3Forms access key.
- [ ] Adobe Fonts (Will's web project `hfo7qtb`): optionally set font-display to `swap`. No italics are used so far, so they could be removed from the project.
