import { loadFont } from "@remotion/google-fonts/PlusJakartaSans";

const { fontFamily } = loadFont("normal", {
  weights: ["400", "500", "600", "700", "800"],
  subsets: ["latin"],
});

export const FONT = fontFamily;

export const COLORS = {
  blue900: "#0D47A1",
  blue800: "#1565C0",
  blue700: "#1976D2",
  blue500: "#2196F3",
  blue300: "#64B5F6",
  blue100: "#E3F2FD",
  cyan: "#4DD0E1",
  cyanSoft: "#8EF0F5",
  green: "#4CAF50",
  greenDark: "#2E7D32",
  greenAccent: "#69F0AE",
  red: "#F44336",
  redDark: "#D32F2F",
  redAccent: "#FF5252",
  amber: "#FFC107",
  amberSoft: "#FFD54F",
  purple: "#7C4DFF",
  ink: "#0B1B33",
  grey100: "#F4F6FA",
  grey200: "#E7EDF5",
  grey400: "#90A4AE",
  grey500: "#78909C",
  grey600: "#607D8B",
  bgDeep: "#04101F",
  bgNavy: "#071B3A",
  bgBlue: "#0A2C5E",
  white: "#FFFFFF",
} as const;

export const formatNumber = (value: number) =>
  Math.round(value)
    .toString()
    .replace(/\B(?=(\d{3})+(?!\d))/g, ".");

export const formatRupiah = (value: number) => `Rp ${formatNumber(value)}`;
