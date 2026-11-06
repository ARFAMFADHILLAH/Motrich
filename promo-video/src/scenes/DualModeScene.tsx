import React from "react";
import {
  AbsoluteFill,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Check, Cloud, Smartphone } from "lucide-react";
import { Background } from "../components/Background";
import { Reveal } from "../components/Reveal";
import { SceneTitle } from "../components/SceneTitle";
import { COLORS, FONT } from "../theme";

type ModeCardProps = {
  icon: React.ReactNode;
  title: string;
  subtitle: string;
  bullets: string[];
  accent: string;
  accentBg: string;
  side: "left" | "right";
  delay: number;
  tag: string;
};

const ModeCard: React.FC<ModeCardProps> = ({
  icon,
  title,
  subtitle,
  bullets,
  accent,
  accentBg,
  side,
  delay,
  tag,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const progress = spring({
    frame: frame - delay,
    fps,
    config: { damping: 18, stiffness: 90 },
  });

  return (
    <div
      style={{
        position: "absolute",
        top: 500,
        left: side === "left" ? 70 : 580,
        width: 430,
        height: 720,
        borderRadius: 34,
        padding: "38px 34px",
        background: "rgba(255,255,255,0.055)",
        border: "1px solid rgba(255,255,255,0.14)",
        boxShadow: "0 40px 100px rgba(0,0,0,0.42)",
        backdropFilter: "blur(20px)",
        opacity: progress,
        transform: `translateX(${(side === "left" ? -1 : 1) * (1 - progress) * 140}px)`,
        display: "flex",
        flexDirection: "column",
        fontFamily: FONT,
      }}
    >
      <div
        style={{
          width: 88,
          height: 88,
          borderRadius: 26,
          background: accentBg,
          border: `1px solid ${accent}55`,
          display: "grid",
          placeItems: "center",
        }}
      >
        {icon}
      </div>

      <div
        style={{
          fontSize: 42,
          fontWeight: 800,
          color: COLORS.white,
          letterSpacing: -1.2,
          marginTop: 26,
        }}
      >
        {title}
      </div>
      <div
        style={{
          fontSize: 23,
          fontWeight: 500,
          color: "rgba(255,255,255,0.6)",
          marginTop: 8,
          lineHeight: 1.35,
        }}
      >
        {subtitle}
      </div>

      <div
        style={{
          height: 1,
          background: "rgba(255,255,255,0.13)",
          margin: "26px 0 20px",
        }}
      />

      <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
        {bullets.map((bullet) => (
          <div
            key={bullet}
            style={{ display: "flex", alignItems: "center", gap: 12 }}
          >
            <div
              style={{
                width: 28,
                height: 28,
                borderRadius: 9,
                background: accentBg,
                display: "grid",
                placeItems: "center",
                flexShrink: 0,
              }}
            >
              <Check size={16} color={accent} strokeWidth={3} />
            </div>
            <span
              style={{
                fontSize: 24,
                fontWeight: 600,
                color: "rgba(255,255,255,0.86)",
              }}
            >
              {bullet}
            </span>
          </div>
        ))}
      </div>

      <div
        style={{
          marginTop: "auto",
          alignSelf: "flex-start",
          padding: "8px 16px",
          borderRadius: 999,
          background: accentBg,
          border: `1px solid ${accent}44`,
          color: accent,
          fontSize: 20,
          fontWeight: 800,
          letterSpacing: 0.4,
        }}
      >
        {tag}
      </div>
    </div>
  );
};

export const DualModeScene: React.FC = () => {
  return (
    <Background variant="deep">
      <AbsoluteFill style={{ fontFamily: FONT }}>
        <SceneTitle
          top={128}
          fontSize={78}
          lines={[
            "Mau offline?",
            <span key="accent" style={{ color: COLORS.blue300 }}>
              Atau cloud sync?
            </span>,
          ]}
        />

        <ModeCard
          icon={<Smartphone size={40} color={COLORS.amber} />}
          title="Mode Tamu"
          subtitle="Langsung pakai, tanpa login."
          bullets={["Tanpa login", "Data 100% lokal", "Langsung pakai"]}
          accent={COLORS.amber}
          accentBg="rgba(255,193,7,0.14)"
          side="left"
          delay={8}
          tag="Offline-first"
        />

        <ModeCard
          icon={<Cloud size={40} color={COLORS.cyan} />}
          title="Cloud Sync"
          subtitle="Login email, data aman di cloud."
          bullets={["Login via email", "Auto backup", "Aman ganti HP"]}
          accent={COLORS.cyan}
          accentBg="rgba(77,208,225,0.14)"
          side="right"
          delay={14}
          tag="Supabase + RLS"
        />

        <div
          style={{
            position: "absolute",
            top: 828,
            left: 508,
            width: 64,
            height: 64,
            borderRadius: "50%",
            background: COLORS.bgDeep,
            border: "1px solid rgba(255,255,255,0.2)",
            display: "grid",
            placeItems: "center",
            fontSize: 21,
            fontWeight: 800,
            color: "rgba(255,255,255,0.55)",
            boxShadow: "0 12px 30px rgba(0,0,0,0.4)",
          }}
        >
          atau
        </div>

        <div
          style={{
            position: "absolute",
            bottom: 120,
            left: 80,
            right: 80,
            textAlign: "center",
          }}
        >
          <Reveal delay={26} distance={24}>
            <div
              style={{
                fontSize: 36,
                fontWeight: 600,
                color: "rgba(255,255,255,0.5)",
              }}
            >
              Dua-duanya bisa. Kamu yang pilih.
            </div>
          </Reveal>
        </div>
      </AbsoluteFill>
    </Background>
  );
};
