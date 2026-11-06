import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { COLORS, FONT } from "../theme";

type FloatingChipProps = {
  icon: React.ReactNode;
  label: string;
  value: string;
  color?: string;
  delay?: number;
  rotate?: number;
  width?: number;
  style?: React.CSSProperties;
};

export const FloatingChip: React.FC<FloatingChipProps> = ({
  icon,
  label,
  value,
  color = COLORS.cyan,
  delay = 0,
  rotate = 0,
  width,
  style,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const progress = spring({
    frame: frame - delay,
    fps,
    config: { damping: 16, stiffness: 120 },
  });

  const opacity = interpolate(frame - delay, [0, 12], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const float = Math.sin((frame - delay) / 24) * 7;

  return (
    <div
      style={{
        position: "absolute",
        display: "flex",
        alignItems: "center",
        gap: 13,
        padding: "16px 19px",
        borderRadius: 22,
        background: "rgba(8,22,46,0.86)",
        border: "1px solid rgba(255,255,255,0.14)",
        boxShadow: "0 26px 60px rgba(0,0,0,0.48)",
        backdropFilter: "blur(18px)",
        fontFamily: FONT,
        opacity,
        transform: `translateY(${(1 - progress) * 44 + float}px) rotate(${rotate}deg) scale(${
          0.9 + 0.1 * progress
        })`,
        width,
        ...style,
      }}
    >
      <div
        style={{
          width: 50,
          height: 50,
          borderRadius: 15,
          display: "grid",
          placeItems: "center",
          background: `${color}22`,
          border: `1px solid ${color}55`,
          flexShrink: 0,
        }}
      >
        {icon}
      </div>
      <div style={{ minWidth: 0 }}>
        <div
          style={{
            fontSize: 17,
            letterSpacing: 2.2,
            color: "rgba(255,255,255,0.6)",
            fontWeight: 800,
            textTransform: "uppercase",
            whiteSpace: "nowrap",
          }}
        >
          {label}
        </div>
        <div
          style={{
            fontSize: 28,
            fontWeight: 800,
            color,
            letterSpacing: -0.6,
            whiteSpace: "nowrap",
            marginTop: 1,
          }}
        >
          {value}
        </div>
      </div>
    </div>
  );
};
