-- ==========================================
-- 1. TABEL-TABEL UTAMA (Dengan user_id & UUID)
-- ==========================================

-- Hapus tabel lama jika ada (untuk migrasi bersih)
drop table if exists transactions cascade;
drop table if exists wallets cascade;
drop table if exists savings cascade;
drop table if exists bills cascade;
drop table if exists debts cascade;

-- A. Tabel Dompet & Rekening
create table if not exists wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null default auth.uid(),
  name text not null,
  type text not null, -- Cash, Bank, E-Wallet
  balance numeric not null default 0,
  created_at timestamptz not null default now()
);

-- B. Tabel Transaksi (Pemasukan & Pengeluaran)
create table if not exists transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null default auth.uid(),
  title text not null,
  amount numeric not null,
  is_income boolean not null default false,
  category text not null,
  wallet_id uuid references wallets(id) on delete cascade not null,
  date timestamptz not null default now(),
  created_at timestamptz not null default now()
);

-- C. Tabel Target Tabungan
create table if not exists savings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null default auth.uid(),
  title text not null,
  target_amount numeric not null,
  current_amount numeric not null default 0,
  created_at timestamptz not null default now()
);

-- D. Tabel Pengingat Tagihan
create table if not exists bills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null default auth.uid(),
  title text not null,
  amount numeric not null,
  due_date timestamptz not null,
  is_paid boolean not null default false,
  created_at timestamptz not null default now()
);

-- E. Tabel Utang & Piutang
create table if not exists debts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null default auth.uid(),
  name text not null,
  amount numeric not null,
  is_payable boolean not null default true, -- true = Utang, false = Piutang
  is_settled boolean not null default false,
  created_at timestamptz not null default now()
);


-- ==========================================
-- 2. ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- Aktifkan RLS pada semua tabel
alter table wallets enable row level security;
alter table transactions enable row level security;
alter table savings enable row level security;
alter table bills enable row level security;
alter table debts enable row level security;

-- Hapus policy lama jika ada
drop policy if exists "Users can manage their own wallets" on wallets;
drop policy if exists "Users can manage their own transactions" on transactions;
drop policy if exists "Users can manage their own savings" on savings;
drop policy if exists "Users can manage their own bills" on bills;
drop policy if exists "Users can manage their own debts" on debts;

-- Buat policy agar user hanya bisa membaca, menulis, mengubah, dan menghapus data miliknya sendiri
create policy "Users can manage their own wallets" on wallets
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users can manage their own transactions" on transactions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users can manage their own savings" on savings
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users can manage their own bills" on bills
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users can manage their own debts" on debts
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);


-- ==========================================
-- 3. TRIGGER OTOMATIS UPDATE SALDO DOMPET
-- ==========================================

drop trigger if exists trigger_update_wallet_balance on transactions;
drop function if exists update_wallet_balance_fn();

create or replace function update_wallet_balance_fn()
returns trigger as $$
begin
  -- Jika INSERT transaksi baru
  if (TG_OP = 'INSERT') then
    if new.is_income = true then
      update wallets set balance = balance + new.amount where id = new.wallet_id;
    else
      update wallets set balance = balance - new.amount where id = new.wallet_id;
    end if;
    return new;

  -- Jika UPDATE transaksi
  elsif (TG_OP = 'UPDATE') then
    -- Batalkan efek transaksi lama
    if old.is_income = true then
      update wallets set balance = balance - old.amount where id = old.wallet_id;
    else
      update wallets set balance = balance + old.amount where id = old.wallet_id;
    end if;

    -- Terapkan efek transaksi baru
    if new.is_income = true then
      update wallets set balance = balance + new.amount where id = new.wallet_id;
    else
      update wallets set balance = balance - new.amount where id = new.wallet_id;
    end if;
    return new;

  -- Jika DELETE transaksi
  elsif (TG_OP = 'DELETE') then
    if old.is_income = true then
      update wallets set balance = balance - old.amount where id = old.wallet_id;
    else
      update wallets set balance = balance + old.amount where id = old.wallet_id;
    end if;
    return old;
  end if;
  return null;
end;
$$ language plpgsql security definer;

-- Pasangkan trigger ke tabel transactions
create trigger trigger_update_wallet_balance
  after insert or update or delete on transactions
  for each row execute function update_wallet_balance_fn();