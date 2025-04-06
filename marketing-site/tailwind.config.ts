import type { Config } from 'tailwindcss';
import defaultTheme from 'tailwindcss/defaultTheme'; // Use default import

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      fontFamily: {
        // Set sans to Nunito, falling back to default sans
        sans: ['var(--font-nunito)', ...(defaultTheme.fontFamily?.sans ?? [])],
      },
      colors: {
        brand: {
          primary: '#FF5722', // Deep Orange
          secondary: '#00272B', // Charcoal Gray (was Blue)
          surface: '#FFFFFF', // White
          'surface-container': '#F5F5F5', // Very Light Grey (Cards)
          'text-primary': '#FFFFFF', // Text on primary/secondary
          'text-dark': '#333333', // Dark Grey
          'text-medium': '#666666', // Medium Grey
          'primary-orange-text': '#FF5722', // Deep Orange (for text/fill)
        },
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic':
          'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
      },
      // Define animation keyframes and utility
      keyframes: {
        'pulse-slow': {
          '0%, 100%': { opacity: '0.7' },
          '50%': { opacity: '0.4' },
        },
      },
      animation: {
        'pulse-slow': 'pulse-slow 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
    },
  },
  plugins: [],
};
export default config;
