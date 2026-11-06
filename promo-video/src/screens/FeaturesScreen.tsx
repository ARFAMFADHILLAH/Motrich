import React from "react";
import {
  ArrowDownLeft,
  ArrowUpRight,
  Bell,
  Check,
  Handshake,
  Plus,
  Target,
} from "lucide-react";
import { COLORS, FONT, formatRupiah } from "../theme";
import { StatusBar } from "./StatusBar";

type FeaturesScreenProps = {
  savingsProgress?: number;
  billPaid?: boolean;
};

export const FeaturesScreen: React.FC<FeaturesScreenProps> = ({
  savingsProgress = 0.6,
  billPaid = false,
}) => {
  const saved = 10000000 * savingsProgress;

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
          Fitur Keuangan Lainnya
        </div>
      </div>

      <div
        style={{
          padding: "14px 16px",
          display: "flex",
          flexDirection: "column",
          gap: 10,
        }}
      >
        <SectionHeader emoji="🎯" title="Target Tabungan" />
        <div
          style={{
            background: COLORS.white,
            borderRadius: 16,
            padding: "13px 14px",
            border: `1px solid ${COLORS.grey200}`,
            boxShadow: "0 6px 16px rgba(13,71,161,0.05)",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 9 }}>
            <div
              style={{
                width: 34,
                height: 34,
                borderRadius: 11,
                background: "#EDE7F6",
                display: "grid",
                placeItems: "center",
              }}
            >
              <Target size={17} color={COLORS.purple} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 12, fontWeight: 800 }}>Dana Darurat</div>
              <div style={{ fontSize: 8.5, color: COLORS.grey500, marginTop: 1 }}>
                Terkumpul: {formatRupiah(saved)} dari Rp 10.000.000
              </div>
            </div>
            <div
              style={{
                width: 28,
                height: 28,
                borderRadius: 9,
                background: COLORS.blue100,
                display: "grid",
                placeItems: "center",
              }}
            >
              <Plus size={15} color={COLORS.blue700} />
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
                width: `${Math.min(savingsProgress, 1) * 100}%`,
                height: "100%",
                borderRadius: 4,
                background: `linear-gradient(90deg, ${COLORS.purple}, #B388FF)`,
              }}
            />
          </div>
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              marginTop: 5,
              fontSize: 8.5,
              color: COLORS.grey500,
              fontWeight: 600,
            }}
          >
            <span>{Math.round(savingsProgress * 100)}% tercapai</span>
            <span>Target Rp 10.000.000</span>
          </div>
        </div>

        <SectionHeader emoji="💡" title="Pengingat Tagihan" />
        <div
          style={{
            background: COLORS.white,
            borderRadius: 16,
            padding: "11px 14px",
            border: `1px solid ${billPaid ? COLORS.green + "55" : COLORS.grey200}`,
            display: "flex",
            alignItems: "center",
            gap: 9,
          }}
        >
          <div
            style={{
              width: 34,
              height: 34,
              borderRadius: 11,
              background: "#FFF8E1",
              display: "grid",
              placeItems: "center",
            }}
          >
            <Bell size={17} color="#F9A825" />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 12, fontWeight: 800 }}>Tagihan Listrik</div>
            <div style={{ fontSize: 8.5, color: COLORS.grey500, marginTop: 1 }}>
              Rp 350.000 • Jatuh tempo 10 Nov 2026
            </div>
          </div>
          <div
            style={{
              width: 24,
              height: 24,
              borderRadius: 8,
              border: `1.5px solid ${billPaid ? COLORS.green : COLORS.grey400}`,
              background: billPaid ? COLORS.green : "transparent",
              display: "grid",
              placeItems: "center",
            }}
          >
            {billPaid ? <Check size={14} color={COLORS.white} strokeWidth={3} /> : null}
          </div>
        </div>

        <SectionHeader emoji="🤝" title="Utang & Piutang" />
        <div
          style={{
            background: COLORS.white,
            borderRadius: 16,
            padding: "4px 14px",
            border: `1px solid ${COLORS.grey200}`,
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 9,
              padding: "9px 0",
              borderBottom: `1px solid ${COLORS.grey200}`,
            }}
          >
            <div
              style={{
                width: 30,
                height: 30,
                borderRadius: 10,
                background: "#FFEBEE",
                display: "grid",
                placeItems: "center",
              }}
            >
              <ArrowUpRight size={15} color={COLORS.redDark} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 11.5, fontWeight: 800 }}>Utang Saya</div>
              <div style={{ fontSize: 8.5, color: COLORS.grey500 }}>
                Belum lunas
              </div>
            </div>
            <div style={{ fontSize: 10.5, fontWeight: 800, color: COLORS.redDark }}>
              Rp 500.000
            </div>
          </div>
          <div style={{ display: "flex", alignItems: "center", gap: 9, padding: "9px 0" }}>
            <div
              style={{
                width: 30,
                height: 30,
                borderRadius: 10,
                background: "#E8F5E9",
                display: "grid",
                placeItems: "center",
              }}
            >
              <ArrowDownLeft size={15} color={COLORS.greenDark} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 11.5, fontWeight: 800 }}>Piutang Orang</div>
              <div style={{ fontSize: 8.5, color: COLORS.grey500 }}>
                Belum dibayar
              </div>
            </div>
            <div style={{ fontSize: 10.5, fontWeight: 800, color: COLORS.greenDark }}>
              Rp 250.000
            </div>
          </div>
        </div>

        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            gap: 7,
            marginTop: 2,
            fontSize: 9,
            color: COLORS.grey500,
            fontWeight: 600,
          }}
        >
          <Handshake size={13} /> Semua catatan keuangan, rapi di satu tempat.
        </div>
      </div>
    </div>
  );
};

const SectionHeader: React.FC<{ emoji: string; title: string }> = ({
  emoji,
  title,
}) => (
  <div
    style={{
      display: "flex",
      alignItems: "center",
      gap: 6,
      marginTop: 2,
    }}
  >
    <span style={{ fontSize: 12 }}>{emoji}</span>
    <span style={{ fontSize: 12, fontWeight: 800 }}>{title}</span>
  </div>
);
