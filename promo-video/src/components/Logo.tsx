import React from "react";
import { Img, staticFile } from "remotion";

type LogoProps = {
  size: number;
  radius?: number;
  glow?: string;
  style?: React.CSSProperties;
};

export const Logo: React.FC<LogoProps> = ({
  size,
  radius,
  glow = "rgba(33,150,243,0.55)",
  style,
}) => {
  return (
    <Img
      src={staticFile("logo.png")}
      style={{
        width: size,
        height: size,
        borderRadius: radius ?? size * 0.24,
        boxShadow: `0 30px 80px rgba(0,0,0,0.45), 0 0 80px ${glow}`,
        objectFit: "cover",
        ...style,
      }}
    />
  );
};
