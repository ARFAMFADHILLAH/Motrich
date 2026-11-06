import React from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { ArrowDownLeft, Wallet } from "lucide-react";
import { Background } from "../components/Background";
import { FloatingChip } from "../components/FloatingChip";
import { Phone } from "../components/Phone";
import { SceneTitle } from "../components/SceneTitle";
import { DashboardScreen } from "../screens/DashboardScreen";
import { COLORS, formatRupiah } from "../theme";

export const DashboardScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phoneIn = spring({
    frame: frame - 8,
    fps,
    config: { damping: 18, stiffness: 80 },
  });

  const balance = interpolate(frame, [35, 95], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });

  return (
    <Background variant="deep">
      <AbsoluteFill>
        <SceneTitle
          kicker="Dashboard"
          fontSize={80}
          lines={[
            "Semua keuanganmu,",
            <span key="accent" style={{ color: COLORS.blue300 }}>
              dalam satu aplikasi.
            </span>,
          ]}
        />

        <Phone
          width={580}
          rotateY={12 * (1 - phoneIn)}
          rotateX={4 * (1 - phoneIn)}
          style={{
            position: "absolute",
            left: 250,
            top: 590 + (1 - phoneIn) * 260,
            opacity: phoneIn,
          }}
        >
          <DashboardScreen balanceProgress={balance} />
        </Phone>

        <FloatingChip
          icon={<Wallet size={24} color={COLORS.cyan} />}
          label="Total saldo"
          value={formatRupiah(12450000 * balance)}
          color={COLORS.cyan}
          delay={24}
          rotate={3}
          width={270}
          style={{ top: 690, right: 32 }}
        />

        <FloatingChip
          icon={<ArrowDownLeft size={24} color={COLORS.greenAccent} />}
          label="Bulan ini"
          value="+Rp 8.500.000"
          color={COLORS.greenAccent}
          delay={34}
          rotate={-3}
          width={280}
          style={{ top: 1120, left: 28 }}
        />
      </AbsoluteFill>
    </Background>
  );
};
