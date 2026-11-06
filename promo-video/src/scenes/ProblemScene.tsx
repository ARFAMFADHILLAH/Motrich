import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { Bike, Coffee, Repeat, ShoppingBag } from "lucide-react";
import { Background } from "../components/Background";
import { FloatingChip } from "../components/FloatingChip";
import { Reveal } from "../components/Reveal";
import { COLORS, FONT } from "../theme";

export const ProblemScene: React.FC = () => {
  const frame = useCurrentFrame();
  const pulse = 1 + Math.sin(frame / 14) * 0.03;

  return (
    <Background variant="deep">
      <AbsoluteFill style={{ fontFamily: FONT }}>
        <div
          style={{
            position: "absolute",
            top: 190,
            left: 80,
            right: 80,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            textAlign: "center",
          }}
        >
          <Reveal delay={0} distance={24}>
            <div
              style={{
                fontSize: 27,
                fontWeight: 800,
                letterSpacing: 6,
                color: COLORS.amber,
                textTransform: "uppercase",
                marginBottom: 22,
              }}
            >
              Masalahnya
            </div>
          </Reveal>

          <Reveal delay={5} distance={48}>
            <div
              style={{
                fontSize: 104,
                fontWeight: 800,
                lineHeight: 1,
                letterSpacing: -3.5,
                color: COLORS.white,
              }}
            >
              Ke mana
            </div>
          </Reveal>
          <Reveal delay={11} distance={48}>
            <div
              style={{
                fontSize: 104,
                fontWeight: 800,
                lineHeight: 1.05,
                letterSpacing: -3.5,
                color: COLORS.white,
              }}
            >
              <span style={{ color: COLORS.amber }}>uangmu</span> pergi?
            </div>
          </Reveal>

          <Reveal delay={20} distance={30}>
            <div
              style={{
                fontSize: 40,
                color: "rgba(255,255,255,0.66)",
                marginTop: 26,
                fontWeight: 500,
              }}
            >
              Uang habis, tapi catatan nggak ada.
            </div>
          </Reveal>
        </div>

        <div
          style={{
            position: "absolute",
            top: 820,
            left: "50%",
            transform: `translateX(-50%) scale(${pulse})`,
            width: 280,
            height: 280,
            borderRadius: "50%",
            border: `2px dashed rgba(255,193,7,0.5)`,
            background: "rgba(255,193,7,0.06)",
            display: "grid",
            placeItems: "center",
            boxShadow: "0 0 90px rgba(255,193,7,0.18)",
          }}
        >
          <div
            style={{
              fontSize: 150,
              fontWeight: 800,
              color: "rgba(255,193,7,0.82)",
              lineHeight: 1,
            }}
          >
            ?
          </div>
        </div>

        <FloatingChip
          icon={<Coffee size={24} color={COLORS.amber} />}
          label="Kopi"
          value="Rp 25.000"
          color={COLORS.amber}
          delay={6}
          rotate={-6}
          width={248}
          style={{ top: 760, left: 42 }}
        />
        <FloatingChip
          icon={<Bike size={24} color={COLORS.blue300} />}
          label="Ongkir"
          value="Rp 18.000"
          color={COLORS.blue300}
          delay={10}
          rotate={5}
          width={248}
          style={{ top: 700, right: 38 }}
        />
        <FloatingChip
          icon={<Repeat size={24} color={COLORS.redAccent} />}
          label="Langganan"
          value="Rp 99.000"
          color={COLORS.redAccent}
          delay={14}
          rotate={4}
          width={280}
          style={{ top: 1240, left: 62 }}
        />
        <FloatingChip
          icon={<ShoppingBag size={24} color={COLORS.cyan} />}
          label="Jajan"
          value="Rp 40.000"
          color={COLORS.cyan}
          delay={18}
          rotate={-4}
          width={248}
          style={{ top: 1330, right: 54 }}
        />

        <div
          style={{
            position: "absolute",
            bottom: 120,
            left: 80,
            right: 80,
            textAlign: "center",
          }}
        >
          <Reveal delay={30} distance={24}>
            <div
              style={{
                fontSize: 34,
                fontWeight: 600,
                color: "rgba(255,255,255,0.45)",
              }}
            >
              Tanpa catatan, uangmu cepat hilang.
            </div>
          </Reveal>
        </div>
      </AbsoluteFill>
    </Background>
  );
};
