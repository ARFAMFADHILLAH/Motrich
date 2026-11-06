import React from "react";
import { CalendarDays, PieChart, TrendingUp } from "lucide-react";
import { COLORS, FONT, formatRupiah } from "../theme";
import { StatusBar } from "./StatusBar";

type BudgetScreenProps = {
  monthlyProgress?: number;
  dailyProgress?: number;
  yearlyProgress?: number;
};

type BudgetRowProps = {
  title: string;
  period: string;
  limit: number;
  progress: number;
  icon: React.ReactNode;
  tint: string;
  tintBg: string;
};

const BudgetRow: React.FC<BudgetRowProps> = ({
  title,
  period,
  limit,
  progress,
  icon,
  tint,
  tintBg,
}) => {
  const over = progress > 1;
  const spent = limit * progress;
  const barWidth = Math.min(progress, 1) * 100;

  return (
    <div
      style={{
        background: COLORS.white,
        borderRadius: 16,
        padding: "13px 14px",
        border: `1px solid ${over ? COLORS.red + "44" : COLORS.grey200}`,
        boxShadow: over
          ? "0 10px 24px rgba(244,67,54,0.12)"
          : "0 6px 16px rgba(13,71,161,0.05)",
      }}
    >
      <div style={{ display: "flex", alignItems: "center", gap: 9 }}>
        <div
          style={{
            width: 34,
            height: 34,
            borderRadius: 11,
            background: tintBg,
            display: "grid",
            placeItems: "center",
            flexShrink: 0,
          }}
        >
          {icon}
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 12, fontWeight: 800 }}>{title}</div>
          <div style={{ fontSize: 8.5, color: COLORS.grey500, marginTop: 1 }}>
            {period}
          </div>
        </div>
        <div
          style={{
            fontSize: 12,
            fontWeight: 800,
            color: over ? COLORS.redDark : tint,
          }}
        >
          {Math.round(progress * 100)}%
        </div>
      </div>

      <div
        style={{
          marginTop: 10,
          height: 8,
          borderRadius: 4,
          background: "#ECEFF1",
          overflow: "hidden",
        }}
      >
        <div
          style={{
            width: `${barWidth}%`,
            height: "100%",
            borderRadius: 4,
            background: over
              ? `linear-gradient(90deg, ${COLORS.redAccent}, ${COLORS.redDark})`
              : `linear-gradient(90deg, ${COLORS.blue500}, ${tint})`,
          }}
        />
      </div>

      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          marginTop: 6,
          fontSize: 9,
          color: COLORS.grey500,
          fontWeight: 600,
        }}
      >
        <span>{formatRupiah(spent)}</span>
        <span>{formatRupiah(limit)}</span>
      </div>

      <div
        style={{
          fontSize: 9,
          marginTop: 5,
          fontWeight: 700,
          color: over ? COLORS.redDark : COLORS.greenDark,
        }}
      >
        {over
          ? "⚠️ Pengeluaran melewati batas budget!"
          : "Aman dalam batas anggaran."}
      </div>
    </div>
  );
};

export const BudgetScreen: React.FC<BudgetScreenProps> = ({
  monthlyProgress = 0.72,
  dailyProgress = 1.1,
  yearlyProgress = 0.51,
}) => {
  return (
    <div
      style={{
        width: 390,
        height: 844,
        background: COLORS.grey100,
        fontFamily: FONT,
        color: COLORS.ink,
        position: "relative",
        overflow: "hidden",
      }}
    >
      <div
        style={{
          background: `linear-gradient(135deg, ${COLORS.blue900}, ${COLORS.blue700})`,
          padding: "0 16px",
          height: 100,
          color: COLORS.white,
        }}
      >
        <StatusBar light />
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            height: 56,
            fontSize: 16,
            fontWeight: 800,
          }}
        >
          Anggaran Pengeluaran
        </div>
      </div>

      <div
        style={{
          padding: "14px 16px",
          display: "flex",
          flexDirection: "column",
          gap: 11,
        }}
      >
        <div
          style={{
            background: `linear-gradient(135deg, ${COLORS.blue900}, ${COLORS.blue700})`,
            borderRadius: 16,
            padding: "13px 15px",
            color: COLORS.white,
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            boxShadow: "0 10px 24px rgba(25,118,210,0.28)",
          }}
        >
          <div>
            <div style={{ fontSize: 9.5, color: "rgba(255,255,255,0.72)" }}>
              Sisa anggaran bulan ini
            </div>
            <div style={{ fontSize: 22, fontWeight: 800, letterSpacing: -0.6 }}>
              Rp 850.000
            </div>
          </div>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 5,
              background: "rgba(255,255,255,0.16)",
              padding: "6px 10px",
              borderRadius: 10,
              fontSize: 9.5,
              fontWeight: 700,
            }}
          >
            <TrendingUp size={13} /> 72%
          </div>
        </div>

        <BudgetRow
          title="Budget Bulanan"
          period="November 2026"
          limit={3000000}
          progress={monthlyProgress}
          icon={<PieChart size={17} color={COLORS.blue700} />}
          tint={COLORS.blue700}
          tintBg={COLORS.blue100}
        />
        <BudgetRow
          title="Budget Harian"
          period="Hari ini"
          limit={150000}
          progress={dailyProgress}
          icon={<CalendarDays size={17} color={COLORS.redDark} />}
          tint={COLORS.redDark}
          tintBg="#FFEBEE"
        />
        <BudgetRow
          title="Budget Tahunan"
          period="Tahun 2026"
          limit={36000000}
          progress={yearlyProgress}
          icon={<PieChart size={17} color={COLORS.purple} />}
          tint={COLORS.purple}
          tintBg="#EDE7F6"
        />
      </div>
    </div>
  );
};
