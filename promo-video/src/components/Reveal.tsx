import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";

type Direction = "up" | "down" | "left" | "right" | "none";

type RevealProps = {
  children: React.ReactNode;
  delay?: number;
  distance?: number;
  direction?: Direction;
  style?: React.CSSProperties;
  damping?: number;
  stiffness?: number;
};

const offsetFor = (direction: Direction, distance: number) => {
  switch (direction) {
    case "up":
      return `translateY(${distance}px)`;
    case "down":
      return `translateY(-${distance}px)`;
    case "left":
      return `translateX(${distance}px)`;
    case "right":
      return `translateX(-${distance}px)`;
    default:
      return "translateX(0px)";
  }
};

export const Reveal: React.FC<RevealProps> = ({
  children,
  delay = 0,
  distance = 46,
  direction = "up",
  style,
  damping = 200,
  stiffness = 110,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const progress = spring({
    frame: frame - delay,
    fps,
    config: { damping, stiffness },
  });

  const opacity = interpolate(frame - delay, [0, 14], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        opacity,
        transform: `${offsetFor(direction, distance * (1 - progress))}`,
        ...style,
      }}
    >
      {children}
    </div>
  );
};
