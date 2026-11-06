import React from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { CheckCircle2, Target } from "lucide-react";
import { Background } from "../components/Background";
import { FloatingChip } from "../components/FloatingChip";
import { Phone } from "../components/Phone";
import { SceneTitle } from "../components/SceneTitle";
import { FeaturesScreen } from "../screens/FeaturesScreen";
import { COLORS } from "../theme";

export const FeaturesScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phoneIn = spring({
    frame: frame - 6,
    fps,
    config: { damping: 18, stiffness: 85 },
  });

  const savings = interpolate(frame, [28, 90], [0, 0.6], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });

  const billPaid = frame > 96;

  return (
    <Background variant="deep">
      <AbsoluteFill>
        <SceneTitle
          kicker="Fitur lainnya"
          fontSize={74}
          lines={[
            "Tabungan, tagihan,",
            <span key="accent" style={{ color: COLORS.blue300 }}>
              utang-piutang. Beres.
            </span>,
          ]}
        />

        <Phone
          width={580}
          rotateY={-5 * phoneIn}
          rotateX={3 * (1 - phoneIn)}
          style={{
            position: "absolute",
            left: 250,
            top: 590 + (1 - phoneIn) * 240,
            opacity: phoneIn,
          }}
        >
          <FeaturesScreen savingsProgress={savings} billPaid={billPaid} />
        </Phone>

        <FloatingChip
          icon={<Target size={24} color="#B388FF" />}
          label="Target tabungan"
          value={`${Math.round(savings * 100)}% tercapai`}
          color="#B388FF"
          delay={26}
          rotate={3}
          width={300}
          style={{ top: 750, right: 24 }}
        />

        <FloatingChip
          icon={
            <CheckCircle2
              size={24}
              color={billPaid ? COLORS.greenAccent : COLORS.amber}
            />
          }
          label="Tagihan listrik"
          value={billPaid ? "Lunas" : "Belum lunas"}
          color={billPaid ? COLORS.greenAccent : COLORS.amber}
          delay={44}
          rotate={-3}
          width={282}
          style={{ top: 1160, left: 22 }}
        />
      </AbsoluteFill>
    </Background>
  );
};
