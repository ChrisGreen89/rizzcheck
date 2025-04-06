import React from 'react';

interface AngledDividerProps {
  bgColorClass: string; // Background of the divider's container div
  fillColorClass: string; // Fill color for the SVG polygon
  direction?: 'up' | 'down'; // Controls the angle direction
}

const AngledDivider: React.FC<AngledDividerProps> = ({
  bgColorClass = 'bg-white',
  fillColorClass = 'text-white', // Default fill
  direction = 'down'
}) => {
  const pathD = direction === 'down'
    ? "M0,0 L100,0 L100,100 Q50,100 0,0 Z" // Curve bulges down
    : "M0,100 Q50,0 100,0 L100,100 L0,100 Z"; // Curve bulges up

  return (
    <div className={`relative w-full h-20 md:h-28 lg:h-36 ${bgColorClass} -mb-px`}> {/* Negative margin to overlap slightly */}
      <svg
        className="absolute bottom-0 w-full h-full"
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 100 100"
        preserveAspectRatio="none"
      >
        <path d={pathD} className={`fill-current ${fillColorClass}`} />
      </svg>
    </div>
  );
};

export default AngledDivider; 