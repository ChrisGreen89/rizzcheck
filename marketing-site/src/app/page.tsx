"use client"; // Hero animation requires client component

import Image from "next/image";
import { useState } from 'react'; // Import useState
import AnimatedFeatureCard from "@/components/AnimatedFeatureCard";
import AngledDivider from "@/components/AngledDivider";
import { motion, AnimatePresence } from 'framer-motion'; // Import motion and AnimatePresence
// Import necessary icons from Heroicons
import {
  CheckBadgeIcon,
  StarIcon,
  TrophyIcon,
} from "@heroicons/react/24/solid";

export default function Home() {
  // Add state for image hover
  const [isImageHovered, setIsImageHovered] = useState(false);

  return (
    <main className="flex min-h-screen flex-col items-center bg-brand-surface text-brand-text-dark font-sans">
      {/* Hero Section */}
      <section className="w-full flex flex-col justify-center items-center text-center bg-brand-primary pt-12 pb-12 md:pt-16 md:pb-16 px-4 relative overflow-hidden">
         {/* Reduced bottom padding to accommodate divider */}
         {/* Background Lines Container - Adjusting Shape 2 Position */}
         <div className="absolute inset-0 z-0 overflow-hidden">
          {/* Line Shape 1 - Larger */}
          <motion.div 
            animate={{ rotate: [0, 360] }} 
            transition={{ duration: 40, repeat: Infinity, ease: "linear" }}
            className="absolute top-[-10%] left-[2%] w-80 h-80 border-2 border-orange-400/40 rotate-12 opacity-60"
          ></motion.div>
          {/* Line Shape 2 - Repositioned */}
          <motion.div 
            animate={{ rotate: [0, -360] }} 
            transition={{ duration: 50, repeat: Infinity, ease: "linear", delay: 2 }}
            className="absolute bottom-[5%] right-[10%] w-[30rem] h-96 border-2 border-orange-400/30 -rotate-6 opacity-90"
          ></motion.div> {/* Adjusted bottom/right position */}
          {/* Line Shape 3 - Original Position */}
          <motion.div 
            animate={{ rotate: [360, 0] }} 
            transition={{ duration: 60, repeat: Infinity, ease: "linear", delay: 5 }}
            className="absolute top-[25%] left-[40%] w-64 h-64 border-2 border-orange-300/35 opacity-40"
          ></motion.div> {/* Reverted left position back to 40% */}
        </div>

        {/* Integrated Navigation */}
        <nav className="absolute top-0 left-0 right-0 z-20 p-4 md:p-6">
          <div className="max-w-6xl mx-auto flex justify-between items-center">
            <span className="text-2xl font-bold text-white">RizzCheck</span>
            <a href="#waitlist" className="text-white font-medium border border-white/50 rounded-full px-4 py-1.5 text-sm hover:bg-white/10 transition-colors">
              Join Waitlist
            </a>
          </div>
        </nav>

        <div className="z-10 max-w-4xl flex flex-col md:flex-row items-center gap-8 mt-16 md:mt-20">
          {/* Text Content - Adjust width */}
          <div className="md:w-2/3 text-center md:text-left">
            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="text-4xl sm:text-5xl lg:text-6xl font-extrabold mb-4 text-brand-text-primary leading-tight"
            >
              Level Up Your Hygiene Game!
            </motion.h1>
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.4 }}
              className="text-lg sm:text-xl mb-8 text-orange-100 max-w-lg mx-auto md:mx-0"
            >
              RizzCheck helps young dudes build healthy habits, stay fresh, and earn rewards. Get ready for RizzCheck!
            </motion.p>
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.6 }}>
              <a href="#waitlist"
                className="inline-block bg-brand-secondary text-white font-bold py-3 px-8 rounded-full shadow-lg hover:bg-blue-600 transition-all duration-300 transform hover:scale-105">
                Join the Waitlist
              </a>
            </motion.div>
          </div>

          {/* Visual - Refactored for crossfade animation */}
          <div className="md:w-1/3 mt-8 md:mt-0">
            {/* Outer container for hover detection and scaling */}
            <motion.div
              onHoverStart={() => setIsImageHovered(true)}
              onHoverEnd={() => setIsImageHovered(false)}
              animate={{ scale: isImageHovered ? 1.05 : 1 }}
              transition={{ duration: 0.3 }}
              className="relative rounded-lg shadow-xl overflow-hidden" // Added relative, rounded, shadow, overflow
            >
              {/* Base Image (Always Visible) */}
              <Image
                src="/apphome.png"
                alt="RizzCheck App Screenshot"
                width={800}
                height={450}
                className="block object-cover" // Removed rounding/shadow here, apply to parent
                priority
              />
              {/* Animated Overlay Image */}
              <AnimatePresence>
                {isImageHovered && (
                  <motion.div
                    className="absolute inset-0" // Position over the base image
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    transition={{ duration: 0.3 }}
                  >
                    <Image
                      src="/appstore.png"
                      alt="RizzCheck App Screenshot on App Store" 
                      width={800}
                      height={450}
                      className="block object-cover" // Match base image styling
                      // No priority needed
                    />
                  </motion.div>
                )}
              </AnimatePresence>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Angled Divider 1 - Pass correct fill color */}
      <AngledDivider
        bgColorClass="bg-brand-surface" /* Divider container should match section below */
        fillColorClass="text-brand-primary-orange-text" /* SVG fill should match section above */
        direction="down"
      />

      {/* Features Section */}
      <section className="w-full max-w-6xl mx-auto py-16 md:py-24 px-4 text-center bg-brand-surface">
        <h2 className="text-3xl md:text-4xl font-bold mb-12 text-brand-text-dark">Why RizzCheck Rules</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {/* Feature Card 1: Track Habits */}
          <AnimatedFeatureCard index={0}>
            <div className="bg-brand-surface-container p-6 rounded-lg shadow-md h-full flex flex-col items-center">
              <CheckBadgeIcon className="h-12 w-12 text-brand-secondary mb-4" />
              <h3 className="text-xl font-semibold mb-2 text-brand-primary">Track Habits</h3>
              <p className="text-brand-text-medium">Easily track daily hygiene tasks.</p>
            </div>
          </AnimatedFeatureCard>
          {/* Feature Card 2: Earn Points */}
          <AnimatedFeatureCard index={1}>
            <div className="bg-brand-surface-container p-6 rounded-lg shadow-md h-full flex flex-col items-center">
              <StarIcon className="h-12 w-12 text-brand-secondary mb-4" />
              <h3 className="text-xl font-semibold mb-2 text-brand-primary">Earn Points</h3>
              <p className="text-brand-text-medium">Get rewarded for consistency.</p>
            </div>
          </AnimatedFeatureCard>
          {/* Feature Card 3: Unlock Rewards */}
          <AnimatedFeatureCard index={2}>
            <div className="bg-brand-surface-container p-6 rounded-lg shadow-md h-full flex flex-col items-center">
              <TrophyIcon className="h-12 w-12 text-brand-secondary mb-4" />
              <h3 className="text-xl font-semibold mb-2 text-brand-primary">Unlock Rewards</h3>
              <p className="text-brand-text-medium">Redeem points for cool stuff.</p>
            </div>
          </AnimatedFeatureCard>
        </div>

        {/* Punchy Headline Below Features - TEMPORARILY change motion.h3 to h3 */}
        <h3
          className="mt-12 md:mt-16 relative inline-block overflow-visible"
        >
          {/* Background Bar Element - Wider and Offset */}
          <div className="absolute -inset-x-20 -inset-y-0.5 bg-brand-primary rounded-md z-0"></div>
          {/* Text Element */}
          <span className="relative z-10 text-2xl md:text-3xl font-semibold text-brand-text-primary">
            stay fresh. stay sorted.
          </span>
        </h3>

      </section>

      {/* Divider between Features (White) and Problem (Light Grey) - Swap colors */}
      <AngledDivider
        bgColorClass="bg-brand-surface"           // Match section ABOVE (Features)
        fillColorClass="text-brand-surface-container" // Match section BELOW (Problem)
        direction="up"
      />

      {/* Problem Section - Add relative and overflow-hidden */}
      <section className="w-full py-16 md:py-24 px-4 bg-brand-surface-container relative overflow-hidden">
        {/* Faint Background Animated Shape */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true, amount: 0.1 }}
          transition={{ duration: 1, delay: 0.2 }}
          className="absolute inset-0 z-0 flex justify-center items-center"
        >
          <motion.div
            animate={{ rotate: [0, 360] }}
            transition={{ duration: 80, repeat: Infinity, ease: "linear" }}
            className="w-[50rem] h-[50rem] border border-brand-secondary/5 rounded-full"
          ></motion.div>
        </motion.div>

        {/* Animated container for the whole section - Add relative z-10 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.2 }}
          transition={{ duration: 0.6 }}
          className="max-w-5xl mx-auto relative z-10"
        >
          <h2 className="text-3xl md:text-4xl font-bold mb-12 text-center text-brand-text-dark">The Daily Grind vs. The Glow Up</h2>
          
          {/* Refactored to single column layout with enhanced typography */}
          <div className="flex flex-col gap-8 md:gap-12"> 
            {/* Section 1: The Teen Perspective (Revised) */}
            <div className="max-w-3xl mx-auto text-center"> {/* Center container, limit width */}
              <h3 className="text-2xl md:text-3xl font-bold mb-4 text-brand-primary">Another Thing on the List...</h3> {/* Bolder, larger heading */}
              <p className="text-lg text-brand-text-medium mb-4 text-left"> {/* Left-align paragraph */}
                Life&apos;s busy. Between school, sports, friends, and everything else, basic stuff like showering or remembering deodorant can feel like one more hassle you don&apos;t have time for.
              </p>
              <p className="text-lg text-brand-text-medium text-left"> {/* Left-align paragraph */}
                Plus, nobody wants those awkward parent reminders, right?
              </p>
            </div>

            {/* Section 2: The Solution Bridge / Parent Relief (Revised) */}
            {/* Keep background, limit width, center container */}
            <div className="bg-white p-6 rounded-lg shadow-md max-w-3xl mx-auto text-center">
              <h3 className="text-2xl md:text-3xl font-bold mb-4 text-brand-secondary">Streamline Your Routine</h3> {/* Bolder, larger heading */}
              <p className="text-lg text-brand-text-medium mb-4 text-left"> {/* Left-align paragraph */}
                RizzCheck helps you lock down the essentials without the friction. Build the habits, track your progress, earn points for staying consistent.
              </p>
              <p className="text-lg text-brand-text-dark font-medium text-left"> {/* Left-align paragraph */}
                Look sharp, feel confident, and maybe even get your parents off your back. It&apos;s about handling your stuff efficiently.
              </p>
            </div>
          </div>
        </motion.div>
      </section>

      {/* Divider between Problem (Light Grey) and Waitlist (Gradient) */}
      {/* Consider adding another divider here if needed */}
      {/* <AngledDivider
        bgColorClass="bg-gradient-to-br from-blue-50 to-indigo-100" // Match Waitlist bg
        fillColorClass="text-brand-surface-container" // Match Problem section bg
        direction="down"
      /> */}

      {/* Waitlist Signup Section */}
      <section id="waitlist" className="w-full bg-gradient-to-br from-blue-50 to-indigo-100 py-16 md:py-24 px-4">
        <div className="max-w-xl mx-auto text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-4 text-brand-text-dark">Be the First to Know!</h2>
          <p className="text-brand-text-medium mb-8">
            Sign up for our waitlist to get exclusive early access and updates when RizzCheck launches.
          </p>
          <form className="flex flex-col sm:flex-row gap-4 justify-center max-w-md mx-auto">
            <input
              type="email"
              placeholder="Enter your email address"
              required
              className="flex-grow px-4 py-3 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-brand-text-dark shadow-sm transition-all duration-300"
            />
            <button
              type="submit"
              className="bg-brand-secondary text-white font-bold py-3 px-6 rounded-lg shadow-md hover:bg-blue-600 transition-all duration-300 transform hover:scale-105 hover:shadow-xl active:scale-95"
            >
              Notify Me!
            </button>
          </form>
        </div>
      </section>

      {/* Footer */}
      <footer className="w-full p-6 text-center text-brand-text-medium bg-brand-surface-container mt-auto">
        <p>&copy; {new Date().getFullYear()} RizzCheck. Building better habits.</p>
      </footer>
    </main>
  );
}
