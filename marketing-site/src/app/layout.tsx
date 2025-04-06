import type { Metadata } from "next";
import { Nunito } from "next/font/google";
import "./globals.css";

const nunito = Nunito({
  subsets: ["latin"],
  display: 'swap',
  variable: '--font-nunito',
});

export const metadata: Metadata = {
  title: "RizzCheck - Level Up Your Hygiene Game",
  description: "The app that helps young dudes build healthy habits, stay fresh, and earn rewards.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${nunito.variable} font-sans`}>{children}</body>
    </html>
  );
}
