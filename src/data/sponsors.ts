import stratstone from '../assets/sponsors/stratstone-land-rover-derby.svg?url';
import enigmaSeven from '../assets/sponsors/enigma-seven.svg?url';

/**
 * Event sponsors, shown in the home page hero and in the footer on every page.
 * Logos are white SVGs from the Figma. Widths are in Figma px (scaled with the page).
 */
export const SPONSORS = {
  headline: {
    label: 'Headline sponsor',
    name: 'Stratstone Land Rover Derby',
    logo: stratstone,
    width: 203,
    height: 79,
    heroWidth: 203,
  },
  supporting: {
    label: 'Supporting sponsor',
    name: 'Enigma Seven',
    logo: enigmaSeven,
    width: 203,
    height: 28,
    heroWidth: 176,
  },
} as const;

export const PRODUCTION_CREDIT = 'A Volt7 production';
