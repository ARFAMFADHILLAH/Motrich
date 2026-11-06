import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { ArrowRight, Globe, Smartphone } from "lucide-react";
import { Background } from "../components/Background";
import { Logo } from "../components/Logo";
import { Reveal } from "../components/Reveal";
import { COLORS, FONT } from "../theme";

const sparkles = [
  { x: 120, y: 240, size: 10, delay: 0 },
  { x: 940, y: 300, size: 14, delay: 8 },
  { x: 200, y: 520, size: 8, delay: 16 },
  { x: 880, y: 640, size: 10, delay: 4 },
  { x: 90, y: 980, size: 12, delay: 22 },
  { x: 980, y: 1080, size: 8, delay: 12 },
  { x: 160, y: 1420, size: 10, delay: 30 },
  { x: 920, y: 1520, size: 14, delay: 18 },
  { x: 300, y: 1720, size: 8, delay: 6 },
  { x: 780, y: 1760, size: 10, delay: 26 },
  { x: 500, y: 160, size: 8, delay: 20 },
  { x: 620, y: 1800, size: 8, delay: 34 },
];

export const CtaScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const logoIn = spring({
    frame,
    fps,
    config: { damping: 15, stiffness: 90 },
  });

  const pulse = 1 + Math.sin(frame / 8) * 0.014;

  return (
    <Background variant="cta">
      <AbsoluteFill style={{ fontFamily: FONT }}>
        {sparkles.map((sparkle, index) => {
          const twinkle = interpolate(
            Math.sin((frame - sparkle.delay) / 18),
            [-1, 1],
            [0.15, 0.9],
          );
          return (
            <div
              key={index}
              style={{
                position: "absolute",
                left: sparkle.x,
                top: sparkle.y,
                width: sparkle.size,
                height: sparkle.size,
                borderRadius: "50%",
                background: COLORS.cyanSoft,
                opacity: twinkle,
                boxShadow: `0 0 ${sparkle.size * 2.4}px ${COLORS.cyan}`,
              }}
            />
          );
        })}

        <AbsoluteFill
          style={{
            alignItems: "center",
            justifyContent: "center",
            flexDirection: "column",
            marginTop: -40,
          }}
        >
          <div
            style={{
              transform: `scale(${logoIn})`,
              opacity: logoIn,
            }}
          >
            <Logo size={210} />
          </div>

          <Reveal delay={8} distance={40}>
            <div
              style={{
                fontSize: 128,
                fontWeight: 800,
                color: COLORS.white,
                letterSpacing: -5,
                lineHeight: 1,
                marginTop: 28,
              }}
            >
              Motrich
            </div>
          </Reveal>

          <Reveal delay={16} distance={30}>
            <div
              style={{
                fontSize: 42,
                fontWeight: 600,
                color: COLORS.cyanSoft,
                marginTop: 14,
                letterSpacing: 0.3,
              }}
            >
              Uangmu, kendali penuh.
            </div>
          </Reveal>

          <Reveal delay={24} distance={30}>
            <div
              style={{
                marginTop: 40,
                display: "flex",
                alignItems: "center",
                gap: 16,
                padding: "22px 46px",
                borderRadius: 999,
                background: COLORS.white,
                color: COLORS.blue900,
                fontSize: 38,
                fontWeight: 800,
                letterSpacing: -0.5,
                boxShadow: "0 24px 60px rgba(0,0,0,0.35)",
                transform: `scale(${pulse})`,
              }}
            >
              Coba Gratis Sekarang
              <ArrowRight size={34} strokeWidth={2.8} />
            </div>
          </Reveal>

          <Reveal delay={32} distance={24}>
            <div
              style={{
                display: "flex",
                gap: 16,
                marginTop: 30,
              }}
            >
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 10,
                  padding: "12px 22px",
                  borderRadius: 999,
                  background: "rgba(255,255,255,0.08)",
                  border: "1px solid rgba(255,255,255,0.2)",
                  color: "rgba(255,255,255,0.88)",
                  fontSize: 24,
                  fontWeight: 700,
                }}
              >
                <Smartphone size={24} /> Android
              </div>
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 10,
                  padding: "12px 22px",
                  borderRadius: 999,
                  background: "rgba(255,255,255,0.08)",
                  border: "1px solid rgba(255,255,255,0.2)",
                  color: "rgba(255,255,255,0.88)",
                  fontSize: 24,
                  fontWeight: 700,
                }}
              >
                <Globe size={24} /> Web App
              </div>
            </div>
          </Reveal>

          <Reveal delay={40} distance={20}>
            <div
              style={{
                marginTop: 26,
                fontSize: 25,
                fontWeight: 500,
                color: "rgba(255,255,255,0.55)",
              }}
            >
              Gratis. Tanpa ribet. Cari Motrich di Play Store.
            </div>
          </Reveal>
        </AbsoluteFill>
      </AbsoluteFill>
    </Background>
  );
};
