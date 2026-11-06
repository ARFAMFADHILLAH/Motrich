import React from "react";
import {
  ArrowLeft,
  CalendarDays,
  Check,
  ChevronDown,
  Utensils,
  Wallet,
} from "lucide-react";
import { COLORS, FONT, formatRupiah } from "../theme";
import { StatusBar } from "./StatusBar";

type TransactionScreenProps = {
  amount?: number;
  selectedCategory?: string;
};

const categories = [
  "Makanan",
  "Transportasi",
  "Belanja",
  "Gaji",
  "Hiburan",
  "Lainnya",
];

const categoryIcons = [Utensils, Wallet, Check, Wallet, Check, Check];

export const TransactionScreen: React.FC<TransactionScreenProps> = ({
  amount = 45000,
  selectedCategory = "Makanan",
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
            justifyContent: "space-between",
            height: 56,
          }}
        >
          <ArrowLeft size={20} />
          <div style={{ fontSize: 16, fontWeight: 800 }}>Catat Transaksi</div>
          <div style={{ width: 20 }} />
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
        <div
          style={{
            fontSize: 9,
            fontWeight: 800,
            letterSpacing: 1.4,
            color: COLORS.grey500,
            textTransform: "uppercase",
          }}
        >
          Tipe Transaksi
        </div>
        <div style={{ display: "flex", gap: 8 }}>
          <div
            style={{
              flex: 1,
              height: 38,
              borderRadius: 11,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 6,
              background: "#FFEBEE",
              border: `1px solid ${COLORS.red}55`,
              color: COLORS.redDark,
              fontSize: 12,
              fontWeight: 800,
            }}
          >
            <span style={{ fontSize: 14 }}>↑</span> Pengeluaran
          </div>
          <div
            style={{
              flex: 1,
              height: 38,
              borderRadius: 11,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 6,
              background: COLORS.white,
              border: `1px solid ${COLORS.grey200}`,
              color: COLORS.grey500,
              fontSize: 12,
              fontWeight: 700,
            }}
          >
            <span style={{ fontSize: 14 }}>↓</span> Pemasukan
          </div>
        </div>

        <FieldLabel>Dompet / Rekening</FieldLabel>
        <Field>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <div
              style={{
                width: 26,
                height: 26,
                borderRadius: 8,
                background: COLORS.blue100,
                display: "grid",
                placeItems: "center",
              }}
            >
              <Wallet size={14} color={COLORS.blue700} />
            </div>
            <span style={{ fontSize: 12, fontWeight: 700 }}>Dompet Utama (Cash)</span>
          </div>
          <ChevronDown size={16} color={COLORS.grey400} />
        </Field>

        <FieldLabel>Keterangan</FieldLabel>
        <Field>
          <span style={{ fontSize: 12, fontWeight: 700 }}>Makan Siang</span>
        </Field>

        <FieldLabel>Jumlah</FieldLabel>
        <div
          style={{
            background: COLORS.white,
            border: `1.5px solid ${COLORS.blue700}66`,
            borderRadius: 13,
            padding: "10px 14px",
            boxShadow: "0 6px 18px rgba(25,118,210,0.10)",
          }}
        >
          <div
            style={{
              fontSize: 27,
              fontWeight: 800,
              color: COLORS.blue700,
              letterSpacing: -0.8,
            }}
          >
            {formatRupiah(amount)}
          </div>
        </div>

        <FieldLabel>Kategori</FieldLabel>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 6 }}>
          {categories.map((category, index) => {
            const Icon = categoryIcons[index];
            const active = category === selectedCategory;
            return (
              <div
                key={category}
                style={{
                  height: 30,
                  padding: "0 10px",
                  borderRadius: 9,
                  display: "flex",
                  alignItems: "center",
                  gap: 5,
                  background: active ? COLORS.blue700 : COLORS.white,
                  border: `1px solid ${active ? COLORS.blue700 : COLORS.grey200}`,
                  color: active ? COLORS.white : COLORS.grey600,
                  fontSize: 10,
                  fontWeight: 700,
                }}
              >
                <Icon size={12} />
                {category}
              </div>
            );
          })}
        </div>

        <FieldLabel>Tanggal</FieldLabel>
        <Field>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <CalendarDays size={15} color={COLORS.blue700} />
            <span style={{ fontSize: 12, fontWeight: 700 }}>05 Nov 2026</span>
          </div>
          <ChevronDown size={16} color={COLORS.grey400} />
        </Field>

        <div
          style={{
            marginTop: 4,
            height: 48,
            borderRadius: 13,
            background: `linear-gradient(135deg, ${COLORS.blue700}, ${COLORS.blue500})`,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color: COLORS.white,
            fontSize: 13.5,
            fontWeight: 800,
            boxShadow: "0 12px 26px rgba(25,118,210,0.32)",
          }}
        >
          Simpan Transaksi
        </div>
      </div>
    </div>
  );
};

const FieldLabel: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div
    style={{
      fontSize: 9,
      fontWeight: 800,
      letterSpacing: 1.4,
      color: COLORS.grey500,
      textTransform: "uppercase",
      marginTop: 2,
    }}
  >
    {children}
  </div>
);

const Field: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div
    style={{
      background: COLORS.white,
      border: `1px solid ${COLORS.grey200}`,
      borderRadius: 12,
      padding: "11px 12px",
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
    }}
  >
    {children}
  </div>
);
