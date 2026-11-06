import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

type BackgroundProps = {
  variant?: "deep" | "blue" | "cta";
  children?: React.ReactNode;
};

const GRADIENTS: Record<NonNullable<BackgroundProps["variant"]>, string> = {
  deep: `linear-gradient(165deg, ${COLORS.bgDeep} 0%, ${COLORS.bgNavy} 48%, #082449 100%)`,
  blue: `linear-gradient(150deg, #03101F 0%, #071F45 40%, ${COLORS.blue900} 100%)`,
  cta: `linear-gradient(160deg, #071B3A 0%, ${COLORS.blue900} 55%, ${COLORS.blue800} 100%)`,
};

export const Background: React.FC<BackgroundProps> = ({
  variant = "deep",
  children,
}) => {
  const frame = useCurrentFrame();
  const driftA = Math.sin(frame / 95) * 46;
  const driftB = Math.cos(frame / 120) * 38;
  const driftC = Math.sin(frame / 70 + 1.4) * 26;

  return (
    <AbsoluteFill style={{ background: GRADIENTS[variant], overflow: "hidden" }}>
      <AbsoluteFill
        style={{
          backgroundImage:
            "linear-gradient(rgba(255,255,255,0.035) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.035) 1px, transparent 1px)",
          backgroundSize: "76px 76px",
          maskImage:
            "radial-gradient(circle at 50% 42%, rgba(0,0,0,0.9) 0%, transparent 78%)",
          WebkitMaskImage:
            "radial-gradient(circle at 50% 42%, rgba(0,0,0,0.9) 0%, transparent 78%)",
        }}
      />

      <div
        style={{
          position: "absolute",
          width: 1050,
          height: 1050,
          borderRadius: "50%",
          top: -360 + driftA,
          left: -320 + driftB,
          background:
            "radial-gradient(circle, rgba(33,150,243,0.55) 0%, rgba(33,150,243,0) 68%)",
        }}
      />
      <div
        style={{
          position: "absolute",
          width: 880,
          height: 880,
          borderRadius: "50%",
          top: 900 + driftB,
          right: -380 + driftA,
          background:
            "radial-gradient(circle, rgba(77,208,225,0.34) 0%, rgba(77,208,225,0) 70%)",
        }}
      />
      <div
        style={{
          position: "absolute",
          width: 620,
          height: 620,
          borderRadius: "50%",
          bottom: -260 + driftC,
          left: 120 + driftC,
          background:
            "radial-gradient(circle, rgba(124,77,255,0.22) 0%, rgba(124,77,255,0) 70%)",
        }}
      />

      <AbsoluteFill
        style={{
          background:
            "radial-gradient(circle at 50% 45%, transparent 32%, rgba(0,0,0,0.5) 100%)",
        }}
      />
      {children}
    </AbsoluteFill>
  );
};
