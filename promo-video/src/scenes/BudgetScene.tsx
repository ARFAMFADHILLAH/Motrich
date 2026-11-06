import React from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { AlertTriangle, PieChart, ShieldCheck } from "lucide-react";
import { Background } from "../components/Background";
import { FloatingChip } from "../components/FloatingChip";
import { Phone } from "../components/Phone";
import { SceneTitle } from "../components/SceneTitle";
import { BudgetScreen } from "../screens/BudgetScreen";
import { COLORS } from "../theme";

export const BudgetScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phoneIn = spring({
    frame: frame - 6,
    fps,
    config: { damping: 18, stiffness: 85 },
  });

  const monthly = interpolate(frame, [28, 84], [0, 0.72], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });
  const daily = interpolate(frame, [40, 98], [0, 1.1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });
  const yearly = interpolate(frame, [52, 108], [0, 0.51], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });

  const over = daily > 1;

  return (
    <Background variant="deep">
      <AbsoluteFill>
        <SceneTitle
          kicker="Anggaran"
          lines={[
            "Atur budget,",
            <span key="accent" style={{ color: COLORS.cyan }}>
              pantau real-time.
            </span>,
          ]}
        />

        <Phone
          width={580}
          rotateY={6 * phoneIn}
          rotateX={3 * (1 - phoneIn)}
          style={{
            position: "absolute",
            left: 250,
            top: 590 + (1 - phoneIn) * 240,
            opacity: phoneIn,
          }}
        >
          <BudgetScreen
            monthlyProgress={monthly}
            dailyProgress={daily}
            yearlyProgress={yearly}
          />
        </Phone>

        <FloatingChip
          icon={<PieChart size={24} color={COLORS.cyan} />}
          label="Bulan ini"
          value={`${Math.round(monthly * 100)}% terpakai`}
          color={COLORS.cyan}
          delay={24}
          rotate={3}
          width={296}
          style={{ top: 730, right: 26 }}
        />

        <FloatingChip
          icon={
            over ? (
              <AlertTriangle size={24} color={COLORS.redAccent} />
            ) : (
              <ShieldCheck size={24} color={COLORS.greenAccent} />
            )
          }
          label="Status"
          value={over ? "Over budget!" : "Aman"}
          color={over ? COLORS.redAccent : COLORS.greenAccent}
          delay={44}
          rotate={-3}
          width={260}
          style={{ top: 1150, left: 24 }}
        />
      </AbsoluteFill>
    </Background>
  );
};
