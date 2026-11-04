import stratstone from '../assets/sponsors/stratstone-land-rover-derby.svg?url';
import enigmaSeven from '../assets/sponsors/enigma-seven.svg?url';
import volt7 from '../assets/sponsors/volt7.svg?url';

/**
 * Sponsors, shown in the home page hero (headline only) and in the footer on every page.
 * Logos are white SVGs from the Figma. `width` / `height` are the SVG's own size; `footerWidth`
 * is how wide the logo is in the footer at the Figma's 1728px width (it scales with the page).
 *
 * To add a supporting sponsor: put a white SVG logo in src/assets/sponsors/, import it here and
 * add an entry to SUPPORTING_SPONSORS. The footer row grows to fit.
 */
export type Sponsor = { name: string; logo: string; width: number; height: number; footerWidth: number };

export const HEADLINE_SPONSOR: Sponsor = {
  name: 'Stratstone Land Rover Derby',
  logo: stratstone,
  width: 203,
  height: 79,
  footerWidth: 321,
};

export const SUPPORTING_SPONSORS: Sponsor[] = [
  { name: 'Enigma Seven', logo: enigmaSeven, width: 203, height: 28, footerWidth: 245 },
  { name: 'Volt7', logo: volt7, width: 162, height: 37, footerWidth: 162 },
];

/** "A [Volt7 logo] production", in the hero and the footer's black bar. */
export const PRODUCER = { name: 'Volt7', logo: volt7, width: 162, height: 37 };
