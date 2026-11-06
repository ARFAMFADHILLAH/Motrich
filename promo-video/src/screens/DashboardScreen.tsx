import React from "react";
import {
  ArrowDownLeft,
  ArrowUpRight,
  Banknote,
  BarChart3,
  FolderOpen,
  HelpCircle,
  Home,
  Landmark,
  LogOut,
  Moon,
  PieChart,
  Smartphone,
  User,
  Wallet,
} from "lucide-react";
import { COLORS, FONT, formatRupiah } from "../theme";
import { StatusBar } from "./StatusBar";

type DashboardScreenProps = {
  balanceProgress?: number;
};

const wallets = [
  {
    name: "Dompet Utama",
    type: "Cash",
    balance: 4500000,
    icon: Wallet,
    tint: COLORS.blue700,
    bg: COLORS.blue100,
  },
  {
    name: "BCA",
    type: "Bank",
    balance: 6200000,
    icon: Landmark,
    tint: "#00897B",
    bg: "#E0F2F1",
  },
  {
    name: "GoPay",
    type: "E-Wallet",
    balance: 1750000,
    icon: Smartphone,
    tint: COLORS.purple,
    bg: "#EDE7F6",
  },
];

const transactions = [
  {
    name: "Gaji Bulanan",
    category: "Pemasukan",
    amount: 8500000,
    income: true,
    icon: Banknote,
  },
  {
    name: "Makan Siang",
    category: "Makanan",
    amount: 45000,
    income: false,
    icon: ArrowUpRight,
  },
  {
    name: "Transport",
    category: "Transportasi",
    amount: 25000,
    income: false,
    icon: ArrowUpRight,
  },
  {
    name: "Belanja",
    category: "Belanja",
    amount: 320000,
    income: false,
    icon: ArrowUpRight,
  },
];

const navItems = [
  { label: "Utama", icon: Home, active: true },
  { label: "Laporan", icon: BarChart3, active: false },
  { label: "Budget", icon: PieChart, active: false },
  { label: "Lainnya", icon: FolderOpen, active: false },
  { label: "Profil", icon: User, active: false },
  { label: "Panduan", icon: HelpCircle, active: false },
];

export const DashboardScreen: React.FC<DashboardScreenProps> = ({
  balanceProgress = 1,
}) => {
  const totalBalance = 12450000 * balanceProgress;
  const totalIncome = 8500000 * Math.min(balanceProgress * 1.15, 1);
  const totalExpense = 2050000 * Math.min(balanceProgress * 1.15, 1);

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
          <div style={{ fontSize: 15.5, fontWeight: 800, letterSpacing: -0.2 }}>
            Motrich Financial Manager
          </div>
          <div style={{ display: "flex", gap: 14, opacity: 0.92 }}>
            <Moon size={17} />
            <LogOut size={17} />
          </div>
        </div>
      </div>

      <div
        style={{
          padding: "14px 16px 78px",
          display: "flex",
          flexDirection: "column",
          gap: 13,
          height: 744,
          overflow: "hidden",
        }}
      >
        <div
          style={{
            borderRadius: 20,
            padding: "15px 18px 14px",
            background: `linear-gradient(135deg, ${COLORS.blue900} 0%, ${COLORS.blue700} 62%, ${COLORS.blue500} 100%)`,
            boxShadow: "0 12px 26px rgba(25,118,210,0.32)",
            color: COLORS.white,
          }}
        >
          <div style={{ fontSize: 11.5, color: "rgba(255,255,255,0.74)" }}>
            Total Saldo Keseluruhan
          </div>
          <div
            style={{
              fontSize: 27,
              fontWeight: 800,
              letterSpacing: -0.8,
              marginTop: 1,
            }}
          >
            {formatRupiah(totalBalance)}
          </div>
          <div
            style={{
              height: 1,
              background: "rgba(255,255,255,0.22)",
              margin: "11px 0 10px",
            }}
          />
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
              <ArrowDownLeft size={16} color={COLORS.greenAccent} />
              <div>
                <div style={{ fontSize: 8.5, color: "rgba(255,255,255,0.72)" }}>
                  Masuk
                </div>
                <div style={{ fontSize: 11.5, fontWeight: 800 }}>
                  {formatRupiah(totalIncome)}
                </div>
              </div>
            </div>
            <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
              <ArrowUpRight size={16} color={COLORS.redAccent} />
              <div>
                <div style={{ fontSize: 8.5, color: "rgba(255,255,255,0.72)" }}>
                  Keluar
                </div>
                <div style={{ fontSize: 11.5, fontWeight: 800 }}>
                  {formatRupiah(totalExpense)}
                </div>
              </div>
            </div>
          </div>
        </div>

        <div
          style={{
            background: COLORS.white,
            borderRadius: 16,
            padding: "12px 14px",
            display: "flex",
            alignItems: "center",
            gap: 12,
            boxShadow: "0 4px 14px rgba(13,71,161,0.06)",
          }}
        >
          <div
            style={{
              width: 42,
              height: 42,
              borderRadius: 13,
              background: COLORS.blue100,
              display: "grid",
              placeItems: "center",
              fontSize: 20,
            }}
          >
            ☀️
          </div>
          <div>
            <div style={{ fontSize: 15, fontWeight: 800, letterSpacing: -0.2 }}>
              Selamat Pagi, User! 👋
            </div>
            <div style={{ fontSize: 10, color: COLORS.grey500, marginTop: 2 }}>
              Semangat mengatur keuangan hari ini!
            </div>
          </div>
        </div>

        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <div style={{ fontSize: 13, fontWeight: 800 }}>Dompet &amp; Rekening</div>
          <div
            style={{
              display: "flex",
              gap: 8,
              fontSize: 9.5,
              fontWeight: 700,
              color: COLORS.blue700,
            }}
          >
            <span>+ Kategori</span>
            <span>+ Dompet</span>
          </div>
        </div>

        <div style={{ display: "flex", gap: 8 }}>
          {wallets.map((wallet) => {
            const Icon = wallet.icon;
            return (
              <div
                key={wallet.name}
                style={{
                  flex: 1,
                  borderRadius: 14,
                  background: COLORS.white,
                  border: `1px solid ${COLORS.grey200}`,
                  padding: "9px 8px 8px",
                  boxShadow: "0 4px 12px rgba(13,71,161,0.05)",
                }}
              >
                <div
                  style={{
                    width: 25,
                    height: 25,
                    borderRadius: 8,
                    background: wallet.bg,
                    display: "grid",
                    placeItems: "center",
                  }}
                >
                  <Icon size={13} color={wallet.tint} />
                </div>
                <div
                  style={{
                    fontSize: 9.5,
                    fontWeight: 800,
                    marginTop: 6,
                    whiteSpace: "nowrap",
                    overflow: "hidden",
                    textOverflow: "ellipsis",
                  }}
                >
                  {wallet.name}
                </div>
                <div
                  style={{
                    fontSize: 10,
                    fontWeight: 800,
                    color: COLORS.blue700,
                    marginTop: 1,
                    whiteSpace: "nowrap",
                  }}
                >
                  {formatRupiah(wallet.balance)}
                </div>
                <div style={{ fontSize: 7.5, color: COLORS.grey400, marginTop: 1 }}>
                  {wallet.type}
                </div>
              </div>
            );
          })}
        </div>

        <div style={{ fontSize: 13, fontWeight: 800, marginTop: 1 }}>
          Transaksi Terbaru
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 2 }}>
          {transactions.map((transaction) => {
            const Icon = transaction.icon;
            return (
              <div
                key={transaction.name}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 9,
                  padding: "5px 0",
                }}
              >
                <div
                  style={{
                    width: 31,
                    height: 31,
                    borderRadius: 10,
                    background: transaction.income ? "#E8F5E9" : "#FFEBEE",
                    display: "grid",
                    placeItems: "center",
                    flexShrink: 0,
                  }}
                >
                  <Icon
                    size={14}
                    color={transaction.income ? COLORS.greenDark : COLORS.redDark}
                  />
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 11, fontWeight: 800 }}>
                    {transaction.name}
                  </div>
                  <div style={{ fontSize: 8.5, color: COLORS.grey500, marginTop: 1 }}>
                    {transaction.category} • 05 Nov
                  </div>
                </div>
                <div
                  style={{
                    fontSize: 10.5,
                    fontWeight: 800,
                    color: transaction.income ? COLORS.greenDark : COLORS.redDark,
                    whiteSpace: "nowrap",
                  }}
                >
                  {transaction.income ? "+" : "-"}
                  {formatRupiah(transaction.amount)}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          bottom: 0,
          height: 64,
          background: COLORS.white,
          borderTop: `1px solid ${COLORS.grey200}`,
          display: "flex",
          alignItems: "center",
          justifyContent: "space-around",
          padding: "0 6px",
        }}
      >
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <div
              key={item.label}
              style={{
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: 2,
                color: item.active ? COLORS.blue700 : COLORS.grey400,
                flex: 1,
              }}
            >
              <Icon size={16} strokeWidth={item.active ? 2.6 : 2} />
              <span style={{ fontSize: 7.2, fontWeight: item.active ? 800 : 600 }}>
                {item.label}
              </span>
            </div>
          );
        })}
      </div>
    </div>
  );
};
