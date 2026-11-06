import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Background } from "../components/Background";
import { Logo } from "../components/Logo";
import { Reveal } from "../components/Reveal";
import { COLORS, FONT } from "../theme";

export const OpeningScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const logoIn = spring({
    frame,
    fps,
    config: { damping: 14, stiffness: 90 },
  });

  const ring = interpolate(frame, [0, 100], [0.55, 1.9]);
  const ringOpacity = interpolate(frame, [0, 30, 100], [0, 0.55, 0]);
  const float = Math.sin(frame / 22) * 5;

  return (
    <Background variant="blue">
      <AbsoluteFill
        style={{
          alignItems: "center",
          justifyContent: "center",
          fontFamily: FONT,
        }}
      >
        <div
          style={{
            position: "absolute",
            width: 560,
            height: 560,
            borderRadius: "50%",
            border: `2px solid ${COLORS.cyan}`,
            opacity: ringOpacity,
            transform: `scale(${ring})`,
          }}
        />
        <div
          style={{
            position: "absolute",
            width: 420,
            height: 420,
            borderRadius: "50%",
            border: `2px solid ${COLORS.blue300}`,
            opacity: ringOpacity * 0.8,
            transform: `scale(${ring * 0.9})`,
          }}
        />

        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            marginTop: -30,
          }}
        >
          <div
            style={{
              transform: `translateY(${float}px) scale(${logoIn})`,
              opacity: logoIn,
            }}
          >
            <Logo size={230} />
          </div>

          <Reveal delay={12} distance={40}>
            <div
              style={{
                fontSize: 132,
                fontWeight: 800,
                color: COLORS.white,
                letterSpacing: -5,
                marginTop: 34,
                lineHeight: 1,
              }}
            >
              Motrich
            </div>
          </Reveal>

          <Reveal delay={20} distance={30}>
            <div
              style={{
                fontSize: 40,
                color: "rgba(255,255,255,0.78)",
                fontWeight: 500,
                marginTop: 18,
                letterSpacing: 0.2,
              }}
            >
              Pencatat keuangan pribadi
            </div>
          </Reveal>

          <Reveal delay={30} distance={26}>
            <div
              style={{
                marginTop: 34,
                padding: "14px 28px",
                borderRadius: 999,
                background: "rgba(77,208,225,0.12)",
                border: "1px solid rgba(77,208,225,0.4)",
                color: COLORS.cyanSoft,
                fontSize: 30,
                fontWeight: 700,
                letterSpacing: 0.5,
              }}
            >
              Uangmu, kendali penuh.
            </div>
          </Reveal>
        </div>
      </AbsoluteFill>
    </Background>
  );
};
