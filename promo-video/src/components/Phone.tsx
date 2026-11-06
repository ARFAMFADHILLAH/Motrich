import React from "react";
import { COLORS } from "../theme";

type PhoneProps = {
  children: React.ReactNode;
  width?: number;
  rotateX?: number;
  rotateY?: number;
  rotateZ?: number;
  glow?: string;
  style?: React.CSSProperties;
};

export const Phone: React.FC<PhoneProps> = ({
  children,
  width = 580,
  rotateX = 0,
  rotateY = 0,
  rotateZ = 0,
  glow = "rgba(33,150,243,0.5)",
  style,
}) => {
  const bezel = width * 0.034;
  const screenWidth = width - bezel * 2;
  const scale = screenWidth / 390;
  const screenHeight = 844 * scale;
  const height = screenHeight + bezel * 2;

  return (
    <div
      style={{
        width,
        height,
        borderRadius: width * 0.135,
        padding: bezel,
        background:
          "linear-gradient(150deg, #3C424F 0%, #0B0E14 34%, #05070B 70%, #252A35 100%)",
        boxShadow: `0 70px 150px rgba(0,0,0,0.68), 0 0 0 2px rgba(255,255,255,0.09) inset, 0 0 110px ${glow}`,
        transform: `perspective(1700px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) rotateZ(${rotateZ}deg)`,
        transformStyle: "preserve-3d",
        position: "relative",
        ...style,
      }}
    >
      <div
        style={{
          width: "100%",
          height: "100%",
          borderRadius: width * 0.104,
          overflow: "hidden",
          background: COLORS.grey100,
          position: "relative",
        }}
      >
        <div
          style={{
            position: "absolute",
            top: 0,
            left: 0,
            width: 390,
            height: 844,
            transform: `scale(${scale})`,
            transformOrigin: "top left",
          }}
        >
          {children}
        </div>

        <div
          style={{
            position: "absolute",
            top: width * 0.021,
            left: "50%",
            transform: "translateX(-50%)",
            width: width * 0.3,
            height: width * 0.086,
            borderRadius: 999,
            background: "#05070B",
            zIndex: 60,
            boxShadow: "0 2px 8px rgba(0,0,0,0.45)",
          }}
        />

        <div
          style={{
            position: "absolute",
            inset: 0,
            background:
              "linear-gradient(118deg, rgba(255,255,255,0.15) 0%, rgba(255,255,255,0.035) 26%, transparent 48%)",
            pointerEvents: "none",
            zIndex: 50,
          }}
        />
      </div>
    </div>
  );
};
