import React from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { ArrowUpRight, Check, Utensils } from "lucide-react";
import { Background } from "../components/Background";
import { FloatingChip } from "../components/FloatingChip";
import { Phone } from "../components/Phone";
import { SceneTitle } from "../components/SceneTitle";
import { TransactionScreen } from "../screens/TransactionScreen";
import { COLORS, FONT, formatRupiah } from "../theme";

export const TransactionScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phoneIn = spring({
    frame: frame - 6,
    fps,
    config: { damping: 18, stiffness: 85 },
  });

  const amount = interpolate(frame, [34, 82], [0, 45000], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });

  const saved = spring({
    frame: frame - 96,
    fps,
    config: { damping: 14, stiffness: 140 },
  });

  const savedOpacity = interpolate(frame - 96, [0, 10], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <Background variant="deep">
      <AbsoluteFill>
        <SceneTitle
          kicker="Catat transaksi"
          fontSize={76}
          lines={[
            "Catat transaksi,",
            <span key="accent" style={{ color: COLORS.cyan }}>
              dalam hitungan detik.
            </span>,
          ]}
        />

        <Phone
          width={580}
          rotateY={-7 * phoneIn}
          rotateX={3 * (1 - phoneIn)}
          style={{
            position: "absolute",
            left: 250,
            top: 590 + (1 - phoneIn) * 240,
            opacity: phoneIn,
          }}
        >
          <TransactionScreen amount={amount} />
        </Phone>

        <FloatingChip
          icon={<ArrowUpRight size={24} color={COLORS.redAccent} />}
          label="Pengeluaran"
          value={`-${formatRupiah(amount)}`}
          color={COLORS.redAccent}
          delay={22}
          rotate={3}
          width={286}
          style={{ top: 760, right: 28 }}
        />

        <FloatingChip
          icon={<Utensils size={24} color={COLORS.amber} />}
          label="Kategori"
          value="Makanan"
          color={COLORS.amber}
          delay={34}
          rotate={-3}
          width={250}
          style={{ top: 1130, left: 26 }}
        />

        <div
          style={{
            position: "absolute",
            top: 1640,
            left: "50%",
            transform: `translateX(-50%) translateY(${(1 - saved) * 40}px) scale(${
              0.85 + saved * 0.15
            })`,
            opacity: savedOpacity,
            display: "flex",
            alignItems: "center",
            gap: 10,
            padding: "14px 24px",
            borderRadius: 999,
            background: "rgba(76,175,80,0.18)",
            border: "1px solid rgba(105,240,174,0.55)",
            color: COLORS.greenAccent,
            fontFamily: FONT,
            fontSize: 28,
            fontWeight: 800,
            boxShadow: "0 20px 50px rgba(0,0,0,0.45)",
          }}
        >
          <Check size={26} strokeWidth={3} /> Transaksi tersimpan
        </div>
      </AbsoluteFill>
    </Background>
  );
};
