import React from "react";
import { COLORS, FONT } from "../theme";

export const StatusBar: React.FC<{ light?: boolean }> = ({ light = false }) => {
  const color = light ? COLORS.white : COLORS.ink;
  return (
    <div
      style={{
        height: 44,
        padding: "0 20px",
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        color,
        fontFamily: FONT,
        fontSize: 12,
        fontWeight: 700,
      }}
    >
      <span>9:41</span>
      <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
        <svg width="15" height="12" viewBox="0 0 15 12" fill={color}>
          <rect x="0" y="7" width="3" height="5" rx="1" />
          <rect x="4" y="5" width="3" height="7" rx="1" />
          <rect x="8" y="3" width="3" height="9" rx="1" />
          <rect x="12" y="0" width="3" height="12" rx="1" />
        </svg>
        <svg width="15" height="12" viewBox="0 0 16 12" fill="none">
          <path
            d="M8 11.2 1.2 4.4a9.6 9.6 0 0 1 13.6 0L8 11.2Z"
            fill={color}
          />
        </svg>
        <svg width="22" height="11" viewBox="0 0 24 12" fill="none">
          <rect
            x="0.6"
            y="0.6"
            width="20"
            height="10.8"
            rx="3"
            stroke={color}
            strokeWidth="1.2"
            opacity="0.55"
          />
          <rect x="2.4" y="2.4" width="16.4" height="7.2" rx="1.8" fill={color} />
          <path d="M22.6 4v4a2.2 2.2 0 0 0 0-4Z" fill={color} opacity="0.6" />
        </svg>
      </div>
    </div>
  );
};
