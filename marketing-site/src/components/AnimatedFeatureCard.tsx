"use client"; // Mark as a Client Component

import { motion } from 'framer-motion';
import React from 'react';

interface AnimatedFeatureCardProps {
  children: React.ReactNode;
  index: number; // To stagger animations
}

const cardVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: (i: number) => ({
    opacity: 1,
    y: 0,
    transition: {
      delay: i * 0.1, // Stagger delay based on index
      duration: 0.5,
    },
  }),
};

const AnimatedFeatureCard: React.FC<AnimatedFeatureCardProps> = ({ children, index }) => {
  return (
    <motion.div
      initial="hidden"
      whileInView="visible" // Trigger animation when in view
      viewport={{ once: true, amount: 0.3 }} // Trigger once, when 30% visible
      custom={index} // Pass index to variants for staggering
      variants={cardVariants}
    >
      {children}
    </motion.div>
  );
};

export default AnimatedFeatureCard; 