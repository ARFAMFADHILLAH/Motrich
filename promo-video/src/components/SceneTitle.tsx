import React from "react";
import { COLORS, FONT } from "../theme";
import { Reveal } from "./Reveal";

type SceneTitleProps = {
  kicker?: string;
  lines: React.ReactNode[];
  top?: number;
  align?: "left" | "center";
  accentColor?: string;
  fontSize?: number;
};

export const SceneTitle: React.FC<SceneTitleProps> = ({
  kicker,
  lines,
  top = 148,
  align = "left",
  accentColor = COLORS.cyan,
  fontSize = 84,
}) => {
  return (
    <div
      style={{
        position: "absolute",
        top,
        left: 80,
        right: 80,
        display: "flex",
        flexDirection: "column",
        alignItems: align === "center" ? "center" : "flex-start",
        textAlign: align,
        fontFamily: FONT,
      }}
    >
      {kicker ? (
        <Reveal delay={0} distance={24}>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 14,
              marginBottom: 20,
            }}
          >
            <div
              style={{
                width: 42,
                height: 4,
                borderRadius: 2,
                background: accentColor,
                boxShadow: `0 0 18px ${accentColor}`,
              }}
            />
            <span
              style={{
                fontSize: 27,
                fontWeight: 800,
                letterSpacing: 5.5,
                color: accentColor,
                textTransform: "uppercase",
              }}
            >
              {kicker}
            </span>
          </div>
        </Reveal>
      ) : null}

      {lines.map((line, index) => (
        <Reveal key={index} delay={5 + index * 6} distance={52}>
          <div
            style={{
              fontSize,
              lineHeight: 1.03,
              fontWeight: 800,
              letterSpacing: -2.6,
              color: COLORS.white,
              textShadow: "0 12px 40px rgba(0,0,0,0.35)",
            }}
          >
            {line}
          </div>
        </Reveal>
      ))}
    </div>
  );
};
