#!/data/data/com.termux/files/usr/bin/lua
-- Roblox Auto Rejoin for Termux (Lua 5.3)
-- Membuka deep link resmi Roblox; tidak memakai executor, injection, atau bypass.

local APP_NAME = "Roblox Rejoin Menu for Termux"
local CONFIG_DIR = (os.getenv("HOME") or ".") .. "/.config/roblox-rejoin-menu"
local CONFIG_FILE = CONFIG_DIR .. "/config.conf"

local config = {
  place_id = "",
  refresh_seconds = 90,
  app_package = "com.roblox.client",
  grid_columns = 2,
  auto_grid_columns = 2,
  auto_grid_rows = 2,
}

local color = {
  cyan = "\27[0;36m",
  green = "\27[0;32m",
  yellow = "\27[1;33m",
  red = "\27[0;31m",
  gray = "\27[0;90m",
  white = "\27[0;37m",
  reset = "\27[0m",
}

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\\"'\\\"'") .. "'"
end

local function command_ok(command)
  local ok, _, code = os.execute(command)
  return ok == true or ok == 0 or code == 0
end

local function command_exists(name)
  return command_ok("command -v " .. shell_quote(name) .. " >/dev/null 2>&1")
end

local function sleep(seconds)
  command_ok("sleep " .. tostring(math.floor(seconds)))
end

local function pause()
  io.write("\n  Tekan Enter untuk kembali...")
  io.read("*l")
end

local function prompt(label)
  io.write(label)
  return io.read("*l") or ""
end

local function write_banner()
  command_ok("clear")
  io.write("\n")
  io.write(color.cyan .. "  M   M   OOO   CCCC H   H IIIII W   W\n" .. color.reset)
  io.write(color.cyan .. "  MM MM  O   O C     H   H   I   W   W\n" .. color.reset)
  io.write(color.cyan .. "  M M M  O   O C     HHHHH   I   W W W\n" .. color.reset)
  io.write(color.cyan .. "  M   M  O   O C     H   H   I   WW WW\n" .. color.reset)
  io.write(color.cyan .. "  M   M   OOO   CCCC H   H IIIII W   W\n" .. color.reset)
  io.write(color.gray .. "  Version 1.8.1 | " .. APP_NAME .. "\n\n" .. color.reset)
  io.write(color.gray .. "  --------------------------------------------------------\n\n" .. color.reset)
end

local function valid_place_id(value)
  return type(value) == "string" and value:match("^%d+$") ~= nil
end

local function valid_package_id(value)
  return type(value) == "string" and value:match("^[%w][%w%._]*$") ~= nil
end

local function parse_place_id(value)
  value = value or ""
  if valid_place_id(value) then
    return value
  end
  return value:match("roblox%.com/games/(%d+)")
end

local function load_config()
  local file = io.open(CONFIG_FILE, "r")
  if not file then
    return
  end

  for line in file:lines() do
    local key, value = line:match("^([A-Z_]+)=(.*)$")
    if key == "PLACE_ID" and valid_place_id(value) then
      config.place_id = value
    elseif key == "REFRESH_SECONDS" then
      local seconds = tonumber(value)
      if seconds and seconds >= 30 and seconds == math.floor(seconds) then
        config.refresh_seconds = seconds
      end
    elseif key == "APP_PACKAGE" and valid_package_id(value) then
      config.app_package = value
    elseif key == "GRID_COLUMNS" then
      local columns = tonumber(value)
      if columns and columns >= 1 and columns <= 3 and columns == math.floor(columns) then
        config.grid_columns = columns
      end
    elseif key == "AUTO_GRID_COLUMNS" then
      local columns = tonumber(value)
      if columns and columns >= 1 and columns <= 3 and columns == math.floor(columns) then
        config.auto_grid_columns = columns
      end
    elseif key == "AUTO_GRID_ROWS" then
      local rows = tonumber(value)
      if rows and rows >= 1 and rows <= 3 and rows == math.floor(rows) then
        config.auto_grid_rows = rows
      end
    end
  end
  file:close()
end

local function save_config()
  command_ok("mkdir -p " .. shell_quote(CONFIG_DIR))
  command_ok("chmod 700 " .. shell_quote(CONFIG_DIR))

  local temporary_file = CONFIG_FILE .. ".tmp"
  local file, err = io.open(temporary_file, "w")
  if not file then
    return false, err
  end

  file:write("PLACE_ID=", config.place_id, "\n")
  file:write("REFRESH_SECONDS=", tostring(config.refresh_seconds), "\n")
  file:write("APP_PACKAGE=", config.app_package, "\n")
  file:write("GRID_COLUMNS=", tostring(config.grid_columns), "\n")
  file:write("AUTO_GRID_COLUMNS=", tostring(config.auto_grid_columns), "\n")
  file:write("AUTO_GRID_ROWS=", tostring(config.auto_grid_rows), "\n")
  file:close()
  command_ok("chmod 600 " .. shell_quote(temporary_file))

  local renamed, rename_err = os.rename(temporary_file, CONFIG_FILE)
  if not renamed then
    return false, rename_err
  end
  return true
end

local function build_grid_cell(text)
  return string.format(" %-27.27s |", text)
end

local function draw_grid_dashboard()
  local place_label = config.place_id ~= "" and config.place_id or "Belum diatur"
  local status = config.place_id ~= "" and "Siap dikonfigurasi" or "Perlu Place ID"
  local cards = {
    "PLACE: " .. place_label,
    "PACKAGE: " .. config.app_package,
    "INTERVAL: " .. config.refresh_seconds .. " detik",
    "STATUS: " .. status,
  }
  local border = "  +" .. string.rep(string.rep("-", 29) .. "+", config.grid_columns)

  io.write(color.cyan .. "  GRID DASHBOARD (" .. config.grid_columns .. " kolom)\n" .. color.reset)
  for index = 1, #cards, config.grid_columns do
    io.write(color.cyan .. border .. "\n" .. color.reset)
    io.write(color.gray .. "  |" .. color.reset)
    for column = 0, config.grid_columns - 1 do
      local card = cards[index + column] or ""
      io.write(color.white .. build_grid_cell(card) .. color.reset)
    end
    io.write("\n")
  end
  io.write(color.cyan .. border .. "\n" .. color.reset)
end

local function grid_dashboard_settings()
  while true do
    write_banner()
    draw_grid_dashboard()
    io.write("\n")
    io.write(color.green .. " 1)" .. color.white .. " Ubah jumlah kolom (1-3)\n" .. color.reset)
    io.write(color.green .. " 2)" .. color.white .. " Refresh preview grid\n" .. color.reset)
    io.write(color.red .. " 3)" .. color.white .. " Kembali\n\n" .. color.reset)

    local choice = prompt(color.cyan .. "[?] Pilih [1-3]: " .. color.reset)
    if choice == "1" then
      local input = prompt("  Jumlah kolom baru [1-3] [" .. config.grid_columns .. "]: ")
      local columns = tonumber(input)
      if columns and columns >= 1 and columns <= 3 and columns == math.floor(columns) then
        config.grid_columns = columns
        local saved, err = save_config()
        if saved then
          io.write(color.green .. "  Grid disimpan: " .. columns .. " kolom.\n" .. color.reset)
        else
          io.write(color.red .. "  Gagal menyimpan grid: " .. tostring(err) .. "\n" .. color.reset)
        end
      else
        io.write(color.red .. "  Masukkan angka 1, 2, atau 3.\n" .. color.reset)
      end
      pause()
    elseif choice == "2" then
      -- Preview dirender ulang pada iterasi menu berikutnya.
    elseif choice == "3" then
      return
    else
      io.write(color.red .. "  Pilihan tidak tersedia.\n" .. color.reset)
      sleep(1)
    end
  end
end

local function capture_command(command)
  local process = io.popen(command, "r")
  if not process then
    return ""
  end
  local output = process:read("*a") or ""
  process:close()
  return output
end

local function root_command(command)
  return command_ok("su -c " .. shell_quote(command))
end

local function has_root_access()
  return root_command("id -u | grep -qx 0 >/dev/null 2>&1")
end

local function get_display_size()
  local output = capture_command("wm size 2>/dev/null")
  local width, height
  -- Gunakan ukuran terakhir: Android mencetak override size setelah physical size.
  for found_width, found_height in output:gmatch("(%d+)%s*x%s*(%d+)") do
    width, height = tonumber(found_width), tonumber(found_height)
  end
  return width, height
end

local function get_roblox_tasks()
  local output = capture_command("su -c " .. shell_quote("dumpsys activity activities 2>/dev/null"))
  local tasks, seen = {}, {}

  for line in output:gmatch("[^\r\n]+") do
    local task_id = line:match("Task%{.-#(%d+)")
    local package_id = line:match("A=([%w%._]+)")
    if task_id and package_id then
      local is_configured = package_id == config.app_package
      local is_roblox_named = package_id:lower():find("roblox", 1, true) ~= nil
      if (is_configured or is_roblox_named) and not seen[task_id] then
        seen[task_id] = true
        table.insert(tasks, { id = task_id, package_id = package_id })
      end
    end
  end

  -- Sebagian ROM menulis task seperti:
  -- ActivityRecord{... u0 com.roblox.client/.MainActivity t27}
  -- bukan Task{... A=com.roblox.client}. Baca kedua format tersebut.
  for record in output:gmatch("ActivityRecord%{[^}\r\n]+%}") do
    local task_id = record:match("%st(%d+)%s*}") or record:match("%st(%d+)%s")
    local package_id = record:match("u%d+%s+([%w%._]+)/")
    if task_id and package_id then
      local is_configured = package_id == config.app_package
      local is_roblox_named = package_id:lower():find("roblox", 1, true) ~= nil
      if (is_configured or is_roblox_named) and not seen[task_id] then
        seen[task_id] = true
        table.insert(tasks, { id = task_id, package_id = package_id })
      end
    end
  end
  return tasks
end

local function get_third_party_packages()
  local packages = {}
  if not command_exists("pm") then
    return packages
  end
  local output = capture_command("pm list packages -3 2>/dev/null")
  for package_id in output:gmatch("package:([%w%._]+)") do
    packages[package_id] = true
  end
  return packages
end

local function get_visible_user_tasks()
  local output = capture_command("su -c " .. shell_quote("dumpsys activity activities 2>/dev/null"))
  local user_packages = get_third_party_packages()
  local tasks, seen = {}, {}
  local excluded_packages = {
    ["com.termux"] = true,
    ["com.termux.api"] = true,
  }

  for line in output:gmatch("[^\r\n]+") do
    local task_id = line:match("Task%{.-#(%d+)")
    local package_id = line:match("A=([%w%._]+)")
    local is_visible = line:find(" visible=true", 1, true) ~= nil
      or line:find(" isVisible=true", 1, true) ~= nil
    if task_id and package_id and is_visible
        and user_packages[package_id] and not excluded_packages[package_id]
        and not seen[task_id] then
      seen[task_id] = true
      table.insert(tasks, { id = task_id, package_id = package_id })
    end
  end

  -- Fallback untuk ROM yang hanya mengekspos task melalui ActivityRecord.
  for record in output:gmatch("ActivityRecord%{[^}\r\n]+%}") do
    local task_id = record:match("%st(%d+)%s*}") or record:match("%st(%d+)%s")
    local package_id = record:match("u%d+%s+([%w%._]+)/")
    if task_id and package_id and user_packages[package_id]
        and not excluded_packages[package_id] and not seen[task_id] then
      seen[task_id] = true
      table.insert(tasks, { id = task_id, package_id = package_id })
    end
  end
  return tasks
end

local function show_roblox_tasks(tasks)
  if #tasks == 0 then
    io.write(color.yellow .. "  Task Roblox belum terdeteksi. Buka dulu semua jendela Roblox.\n" .. color.reset)
    io.write(color.gray .. "  Jika package clone tidak memuat kata 'roblox', gunakan input task ID manual.\n" .. color.reset)
    return
  end

  io.write(color.cyan .. "  TASK ROBLOX TERDETEKSI\n" .. color.reset)
  for index, task in ipairs(tasks) do
    io.write(color.green .. string.format("  %2d) Task %-6s %s\n", index, task.id, task.package_id) .. color.reset)
  end
end

local function parse_task_ids(input)
  if not input:match("^%s*%d+%s*(,%s*%d+%s*)*$") then
    return nil
  end

  local ids, seen = {}, {}
  for task_id in input:gmatch("%d+") do
    if not seen[task_id] then
      seen[task_id] = true
      table.insert(ids, task_id)
    end
  end
  return ids
end

local function parse_grid_layout(input)
  local columns, rows = (input or ""):match("^%s*(%d+)%s*[xX]%s*(%d+)%s*$")
  columns, rows = tonumber(columns), tonumber(rows)
  if not columns or not rows or columns < 1 or columns > 3 or rows < 1 or rows > 3 then
    return nil
  end
  return columns, rows
end

local function activity_resize_supported()
  local help = capture_command("su -c " .. shell_quote("cmd activity help 2>&1"))
  return help:find("task", 1, true) ~= nil and help:find("resize", 1, true) ~= nil
end

local function apply_window_grid(task_ids, columns, rows)
  local width, height = get_display_size()
  if not width or not height then
    return false, "Ukuran layar tidak dapat dibaca melalui wm size."
  end
  if #task_ids > columns * rows then
    return false, "Jumlah task melebihi jumlah sel grid."
  end
  if not activity_resize_supported() then
    return false, "ROM ini tidak menyediakan cmd activity task resize."
  end

  for index, task_id in ipairs(task_ids) do
    local cell = index - 1
    local column = cell % columns
    local row = math.floor(cell / columns)
    local left = math.floor(column * width / columns)
    local top = math.floor(row * height / rows)
    local right = math.floor((column + 1) * width / columns)
    local bottom = math.floor((row + 1) * height / rows)
    local bounds = string.format("%d,%d,%d,%d", left, top, right, bottom)

    -- Mode 2 meminta Android menandai task sebagai resizeable sebelum mengatur bounds-nya.
    local command = "cmd activity task resizeable " .. task_id .. " 2; "
      .. "cmd activity task resize " .. task_id .. " " .. bounds
    if not root_command(command) then
      return false, "Gagal mengatur Task " .. task_id .. ". ROM/app mungkin menolak freeform resize."
    end
  end
  return true, string.format("%d task diatur ke grid %dx%d pada %dx%d.", #task_ids, columns, rows, width, height)
end

local function apply_auto_grid(columns, rows)
  if not has_root_access() then
    return false, "Akses root melalui su tidak tersedia atau ditolak."
  end

  -- Beri Android waktu menambahkan task saat aplikasi baru saja dibuka.
  sleep(3)
  local tasks = get_roblox_tasks()
  local source = "task Roblox"
  if #tasks == 0 then
    -- Fallback untuk aplikasi clone/window manager yang package-nya tidak memuat roblox.
    tasks = get_visible_user_tasks()
    source = "task aplikasi pengguna yang terlihat"
  end
  local task_ids = {}
  for _, task in ipairs(tasks) do
    table.insert(task_ids, task.id)
  end
  if #task_ids == 0 then
    return false, "Tidak ada task aplikasi yang terlihat dan bisa dijadikan target grid."
  end
  local success, message = apply_window_grid(task_ids, columns, rows)
  if success then
    message = message .. " Sumber: " .. source .. "."
  end
  return success, message
end

local function root_window_grid()
  write_banner()
  io.write(color.cyan .. "  ROOT WINDOW GRID (EXPERIMENTAL)\n" .. color.reset)
  io.write(color.yellow .. "  Hanya untuk jendela/task Android yang sudah terbuka.\n" .. color.reset)
  io.write(color.gray .. "  Tidak membuat instance Roblox baru dan tidak mengubah data aplikasi.\n" .. color.reset)
  io.write(color.gray .. "  Menata task memakai perintah Android: cmd activity task resize.\n\n" .. color.reset)

  if not has_root_access() then
    io.write(color.red .. "  Akses root melalui su tidak tersedia atau ditolak.\n" .. color.reset)
    pause()
    return
  end

  local tasks = get_roblox_tasks()
  show_roblox_tasks(tasks)
  io.write("\n")

  local detected_ids = {}
  for _, task in ipairs(tasks) do
    table.insert(detected_ids, task.id)
  end
  local default_ids = table.concat(detected_ids, ",")
  local task_input = prompt("  Task ID dipisahkan koma" .. (default_ids ~= "" and " [" .. default_ids .. "]" or "") .. ": ")
  if task_input == "" then
    task_input = default_ids
  end
  local task_ids = parse_task_ids(task_input)
  if not task_ids or #task_ids == 0 then
    io.write(color.red .. "  Format task ID tidak valid. Contoh: 12,18,25\n" .. color.reset)
    pause()
    return
  end

  local columns = tonumber(prompt("  Jumlah kolom grid [1-3] [2]: ") or "") or 2
  local rows = tonumber(prompt("  Jumlah baris grid [1-3] [2]: ") or "") or 2
  if columns < 1 or columns > 3 or rows < 1 or rows > 3
      or columns ~= math.floor(columns) or rows ~= math.floor(rows) then
    io.write(color.red .. "  Kolom dan baris harus angka 1 sampai 3.\n" .. color.reset)
    pause()
    return
  end
  if #task_ids > columns * rows then
    io.write(color.red .. "  Grid " .. columns .. "x" .. rows .. " hanya memuat " .. (columns * rows) .. " task.\n" .. color.reset)
    pause()
    return
  end

  io.write(color.yellow .. "  Jendela Task " .. table.concat(task_ids, ", ") .. " akan diubah ukurannya.\n" .. color.reset)
  if prompt("  Terapkan grid root? ketik YA: ") ~= "YA" then
    return
  end

  local success, message = apply_window_grid(task_ids, columns, rows)
  if success then
    io.write(color.green .. "  " .. message .. "\n" .. color.reset)
  else
    io.write(color.red .. "  " .. message .. "\n" .. color.reset)
  end
  pause()
end

local function run_auto_grid_open_apps()
  write_banner()
  io.write(color.cyan .. "  AUTO GRID JENDELA ROBLOX\n" .. color.reset)
  io.write(color.gray .. "  Menata task Roblox atau aplikasi pengguna yang terlihat dengan root.\n" .. color.reset)
  io.write(color.yellow .. "  Layout tersimpan: " .. config.auto_grid_columns .. "x" .. config.auto_grid_rows
    .. " (maks. " .. (config.auto_grid_columns * config.auto_grid_rows) .. " jendela).\n" .. color.reset)
  io.write(color.gray .. "  Ubah layout melalui menu Auto Grid Settings.\n\n" .. color.reset)

  if prompt("  Tata otomatis ke grid " .. config.auto_grid_columns .. "x" .. config.auto_grid_rows .. "? ketik YA: ") ~= "YA" then
    return
  end

  local success, message = apply_auto_grid(config.auto_grid_columns, config.auto_grid_rows)
  if success then
    io.write(color.green .. "  " .. message .. "\n" .. color.reset)
  else
    io.write(color.red .. "  " .. message .. "\n" .. color.reset)
  end
  pause()
end

local function auto_grid_settings()
  while true do
    write_banner()
    local layout = config.auto_grid_columns .. "x" .. config.auto_grid_rows
    local capacity = config.auto_grid_columns * config.auto_grid_rows
    io.write(color.cyan .. "  AUTO GRID SETTINGS\n" .. color.reset)
    io.write(color.gray .. "  Layout ini dipakai oleh menu 10 dan menu 11.\n" .. color.reset)
    io.write(color.yellow .. "  Layout aktif: " .. layout .. " (maks. " .. capacity .. " jendela)\n\n" .. color.reset)
    io.write(color.green .. " 1)" .. color.white .. " Ubah layout grid (contoh 2x2)\n" .. color.reset)
    io.write(color.green .. " 2)" .. color.white .. " Kembalikan ke 2x2\n" .. color.reset)
    io.write(color.red .. " 3)" .. color.white .. " Kembali\n\n" .. color.reset)

    local choice = prompt(color.cyan .. "[?] Pilih [1-3]: " .. color.reset)
    if choice == "1" then
      local columns, rows = parse_grid_layout(prompt("  Layout baru [1x1 sampai 3x3, contoh 2x2]: "))
      if not columns then
        io.write(color.red .. "  Format tidak valid. Gunakan contoh 2x2, 3x2, atau 3x3.\n" .. color.reset)
      else
        config.auto_grid_columns = columns
        config.auto_grid_rows = rows
        local saved, err = save_config()
        if saved then
          io.write(color.green .. "  Layout Auto Grid disimpan: " .. columns .. "x" .. rows .. ".\n" .. color.reset)
        else
          io.write(color.red .. "  Gagal menyimpan layout: " .. tostring(err) .. "\n" .. color.reset)
        end
      end
      pause()
    elseif choice == "2" then
      config.auto_grid_columns = 2
      config.auto_grid_rows = 2
      local saved, err = save_config()
      if saved then
        io.write(color.green .. "  Layout Auto Grid dikembalikan ke 2x2.\n" .. color.reset)
      else
        io.write(color.red .. "  Gagal menyimpan layout: " .. tostring(err) .. "\n" .. color.reset)
      end
      pause()
    elseif choice == "3" then
      return
    else
      io.write(color.red .. "  Pilihan tidak tersedia.\n" .. color.reset)
      sleep(1)
    end
  end
end

local function show_visible_user_tasks()
  write_banner()
  io.write(color.cyan .. "  DETECT VISIBLE APP TASKS\n" .. color.reset)
  io.write(color.gray .. "  Menampilkan task aplikasi pengguna yang sedang terlihat; tidak mengubah jendela.\n\n" .. color.reset)

  if not has_root_access() then
    io.write(color.red .. "  Akses root melalui su tidak tersedia atau ditolak.\n" .. color.reset)
    pause()
    return
  end

  local tasks = get_visible_user_tasks()
  if #tasks == 0 then
    io.write(color.yellow .. "  Tidak ada task pengguna terlihat yang dapat dibaca dari ROM ini.\n" .. color.reset)
  else
    io.write(color.green .. "  Ditemukan " .. #tasks .. " task terlihat:\n\n" .. color.reset)
    for index, task in ipairs(tasks) do
      io.write(color.green .. string.format("  %2d) Task %-6s %s\n", index, task.id, task.package_id) .. color.reset)
    end
  end
  pause()
end

local function ensure_configured()
  if config.place_id == "" then
    io.write(color.yellow .. "  Belum ada Place ID. Pilih Setup terlebih dahulu.\n" .. color.reset)
    pause()
    return false
  end
  return true
end

local function setup_place()
  write_banner()
  io.write(color.cyan .. "  MASUKKAN PLACE\n" .. color.reset)
  io.write(color.gray .. "  Tempel Place ID atau URL game, contoh:\n" .. color.reset)
  io.write(color.gray .. "  https://www.roblox.com/games/123456789/Nama-Game\n\n" .. color.reset)

  local place_id = parse_place_id(prompt("  Place ID / URL: "))
  if not place_id then
    io.write(color.red .. "  Place ID/URL tidak valid.\n" .. color.reset)
    pause()
    return
  end

  config.place_id = place_id
  local interval = prompt("  Jeda rejoin tes dalam detik [" .. config.refresh_seconds .. "]: ")
  if interval ~= "" then
    local seconds = tonumber(interval)
    if seconds and seconds >= 30 and seconds == math.floor(seconds) then
      config.refresh_seconds = seconds
    else
      io.write(color.yellow .. "  Jeda minimal 30 detik. Nilai lama dipertahankan.\n" .. color.reset)
    end
  end

  local package_id = prompt("  Package Roblox [" .. config.app_package .. "]: ")
  if package_id ~= "" then
    if valid_package_id(package_id) then
      config.app_package = package_id
    else
      io.write(color.yellow .. "  Package ID tidak valid. Nilai lama dipertahankan.\n" .. color.reset)
    end
  end

  local saved, err = save_config()
  if saved then
    io.write(color.green .. "  Tersimpan: Place ID " .. config.place_id .. "\n" .. color.reset)
  else
    io.write(color.red .. "  Gagal menyimpan konfigurasi: " .. tostring(err) .. "\n" .. color.reset)
  end
  pause()
end

local function run_setup_step(label, command)
  io.write(color.cyan .. "\n  [SETUP] " .. label .. "\n" .. color.reset)
  if command_ok(command) then
    io.write(color.green .. "  Selesai.\n" .. color.reset)
    return true
  end
  io.write(color.red .. "  Gagal atau dibatalkan. Periksa output Termux di atas.\n" .. color.reset)
  return false
end

local function setup_termux_dependencies()
  write_banner()
  io.write(color.cyan .. "  SETUP TERMUX & DEPENDENSI\n" .. color.reset)
  io.write(color.gray .. "  Menu ini akan menjalankan:\n" .. color.reset)
  io.write(color.gray .. "  termux-setup-storage\n" .. color.reset)
  io.write(color.gray .. "  pkg update -y && pkg upgrade -y\n" .. color.reset)
  io.write(color.gray .. "  pkg install -y lua53 tsu python figlet android-tools sqlite git\n" .. color.reset)
  io.write(color.gray .. "  Paket Python tambahan tidak dipasang karena tidak diperlukan skrip ini.\n\n" .. color.reset)
  io.write(color.yellow .. "  termux-setup-storage akan meminta izin penyimpanan Android.\n" .. color.reset)
  io.write(color.yellow .. "  tsu dipasang sesuai permintaan, tetapi skrip ini tidak memerlukan root.\n\n" .. color.reset)

  if prompt("  Jalankan instalasi? ketik YA: ") ~= "YA" then
    return
  end

  if not run_setup_step("Meminta izin penyimpanan Android", "termux-setup-storage") then
    pause()
    return
  end
  if not run_setup_step("Memperbarui daftar paket", "pkg update -y") then
    pause()
    return
  end
  if not run_setup_step("Memperbarui paket Termux", "pkg upgrade -y") then
    pause()
    return
  end
  if not run_setup_step(
    "Memasang Lua, Python, Android tools, dan Git",
    "pkg install -y lua53 tsu python figlet android-tools sqlite git"
  ) then
    pause()
    return
  end
  io.write(color.green .. "\n  Semua dependensi berhasil diproses.\n" .. color.reset)
  pause()
end

local function open_game()
  if not ensure_configured() then
    return false
  end

  local deep_link = "roblox://placeId=" .. config.place_id
  local success = false

  -- am adalah cara utama di Android/Termux; package hanya dipakai bila valid.
  if command_exists("am") then
    success = command_ok(
      "am start -a android.intent.action.VIEW -d " .. shell_quote(deep_link)
        .. " -p " .. shell_quote(config.app_package) .. " >/dev/null 2>&1"
    )
    if not success then
      success = command_ok(
        "am start -a android.intent.action.VIEW -d " .. shell_quote(deep_link) .. " >/dev/null 2>&1"
      )
    end
  elseif command_exists("termux-open-url") then
    success = command_ok("termux-open-url " .. shell_quote(deep_link) .. " >/dev/null 2>&1")
  end

  if success then
    io.write(color.green .. "  Mencoba masuk langsung ke game Roblox...\n" .. color.reset)
  else
    io.write(color.red .. "  Deep link Roblox tidak dapat dibuka.\n" .. color.reset)
  end
  return success
end

local function package_is_installed(package_id)
  return valid_package_id(package_id)
    and command_exists("pm")
    and command_ok("pm path " .. shell_quote(package_id) .. " >/dev/null 2>&1")
end

local function get_roblox_packages()
  local detected, seen = {}, {}
  if not command_exists("pm") then
    return detected
  end

  local output = capture_command("pm list packages -3 2>/dev/null")
  for package_id in output:gmatch("package:([%w%._]+)") do
    local normalized = package_id:lower()
    -- Mencakup aplikasi Roblox resmi serta sebagian besar package clone yang umum.
    if (normalized:find("roblox", 1, true) or normalized:find("mercy", 1, true))
        and not seen[package_id] then
      seen[package_id] = true
      table.insert(detected, package_id)
    end
  end

  -- Package yang disetel di menu konfigurasi selalu ikut bila masih terpasang.
  if package_is_installed(config.app_package) and not seen[config.app_package] then
    table.insert(detected, 1, config.app_package)
  end
  table.sort(detected)
  return detected
end

local function launch_game_for_package(package_id)
  local deep_link = "roblox://placeId=" .. config.place_id
  if command_exists("am") then
    local targeted = command_ok(
      "am start -a android.intent.action.VIEW -d " .. shell_quote(deep_link)
        .. " -p " .. shell_quote(package_id) .. " >/dev/null 2>&1"
    )
    if targeted then
      return true
    end
    return command_ok(
      "am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p "
        .. shell_quote(package_id) .. " >/dev/null 2>&1"
    )
  end
  return false
end

local function run_auto_detected_apps()
  local delay_seconds = 60
  write_banner()
  if not ensure_configured() then
    return
  end

  local packages = get_roblox_packages()
  io.write(color.cyan .. "  AUTO-DETECT ROBLOX APPS\n" .. color.reset)
  io.write(color.gray .. "  Membuka aplikasi satu per satu dengan jeda " .. delay_seconds .. " detik.\n" .. color.reset)
  io.write(color.yellow .. "  Pastikan semua clone Roblox sudah terpasang sebelum memulai.\n\n" .. color.reset)

  if #packages == 0 then
    io.write(color.red .. "  Tidak ada package Roblox yang terdeteksi.\n" .. color.reset)
    io.write(color.gray .. "  Package yang namanya tidak mengandung roblox/mercy dapat diatur lewat menu 2.\n" .. color.reset)
    pause()
    return
  end

  for index, package_id in ipairs(packages) do
    io.write(color.green .. string.format("  %2d) %s\n", index, package_id) .. color.reset)
  end
  io.write("\n")
  local use_auto_grid = prompt(
    "  Terapkan Auto Grid tersimpan (" .. config.auto_grid_columns .. "x" .. config.auto_grid_rows
      .. ") setelah semua terbuka? ketik YA / Enter = lewati: "
  ) == "YA"
  if prompt("  Buka " .. #packages .. " aplikasi dengan jeda 60 detik? ketik YA: ") ~= "YA" then
    return
  end

  for index, package_id in ipairs(packages) do
    if launch_game_for_package(package_id) then
      io.write(color.green .. string.format("  [%d/%d] Membuka %s\n", index, #packages, package_id) .. color.reset)
    else
      io.write(color.red .. string.format("  [%d/%d] Gagal membuka %s\n", index, #packages, package_id) .. color.reset)
    end
    if index < #packages then
      io.write(color.gray .. "  Menunggu " .. delay_seconds .. " detik untuk aplikasi berikutnya (Ctrl+C untuk berhenti)...\n" .. color.reset)
      sleep(delay_seconds)
    end
  end

  if use_auto_grid then
    io.write(color.gray .. "\n  Mendeteksi task untuk auto grid " .. config.auto_grid_columns .. "x" .. config.auto_grid_rows .. "...\n" .. color.reset)
    local success, message = apply_auto_grid(config.auto_grid_columns, config.auto_grid_rows)
    if success then
      io.write(color.green .. "  " .. message .. "\n" .. color.reset)
    else
      io.write(color.red .. "  " .. message .. "\n" .. color.reset)
    end
  end
  io.write(color.green .. "\n  Semua aplikasi terdeteksi telah diproses.\n" .. color.reset)
  pause()
end

local function show_detected_roblox_apps()
  write_banner()
  local packages = get_roblox_packages()
  io.write(color.cyan .. "  DETECT ROBLOX APPS\n" .. color.reset)
  io.write(color.gray .. "  Scan ini hanya menampilkan package; aplikasi tidak akan dibuka.\n\n" .. color.reset)

  if #packages == 0 then
    io.write(color.yellow .. "  Tidak ada package dengan nama roblox atau mercy yang terdeteksi.\n" .. color.reset)
    io.write(color.gray .. "  Package Roblox utama dapat diatur manual melalui menu 2.\n" .. color.reset)
  else
    io.write(color.green .. "  Ditemukan " .. #packages .. " aplikasi/package:\n\n" .. color.reset)
    for index, package_id in ipairs(packages) do
      io.write(color.green .. string.format("  %2d) %s\n", index, package_id) .. color.reset)
    end
  end
  pause()
end

local function open_fallback_link()
  if not ensure_configured() then
    return false
  end

  local game_url = "https://www.roblox.com/games/start?placeId=" .. config.place_id
  local success = false
  if command_exists("termux-open-url") then
    success = command_ok("termux-open-url " .. shell_quote(game_url) .. " >/dev/null 2>&1")
  elseif command_exists("am") then
    success = command_ok("am start -a android.intent.action.VIEW -d " .. shell_quote(game_url) .. " >/dev/null 2>&1")
  end

  if success then
    io.write(color.green .. "  Membuka tautan cadangan Roblox...\n" .. color.reset)
  else
    io.write(color.red .. "  Tautan cadangan tidak dapat dibuka.\n" .. color.reset)
  end
  return success
end

local function roblox_is_running()
  if not command_exists("pidof") or not valid_package_id(config.app_package) then
    return false
  end
  local process = io.popen("pidof " .. shell_quote(config.app_package) .. " 2>/dev/null", "r")
  if not process then
    return false
  end
  local output = process:read("*a")
  process:close()
  return output:match("%S") ~= nil
end

local function run_monitor()
  local check_interval = 5
  write_banner()
  if not ensure_configured() then
    return
  end
  if not command_exists("pidof") then
    io.write(color.red .. "  Perintah pidof tidak tersedia di perangkat ini.\n" .. color.reset)
    pause()
    return
  end

  io.write(color.cyan .. "  MONITOR ROBLOX & AUTO-OPEN\n" .. color.reset)
  io.write(color.gray .. "  Memeriksa proses Roblox setiap " .. check_interval .. " detik.\n" .. color.reset)
  io.write(color.yellow .. "  Monitor hanya mendeteksi aplikasi yang tertutup, bukan disconnect di dalam game.\n" .. color.reset)
  io.write(color.gray .. "  Hentikan kapan pun dengan Ctrl+C.\n\n" .. color.reset)
  if prompt("  Mulai monitor? ketik YA: ") ~= "YA" then
    return
  end

  while true do
    if roblox_is_running() then
      io.write(color.green .. "  [ONLINE] Roblox sedang berjalan.\n" .. color.reset)
    else
      io.write(color.yellow .. "  [TERTUTUP] Roblox tidak berjalan. Membuka game...\n" .. color.reset)
      open_game()
      sleep(10)
    end
    sleep(check_interval)
  end
end

local function run_auto_rejoin_test()
  write_banner()
  if not ensure_configured() then
    return
  end

  io.write(color.cyan .. "  AUTO-REJOIN TEST\n" .. color.reset)
  io.write(color.gray .. "  Membuka ulang halaman Place pada interval yang dipilih.\n" .. color.reset)
  io.write(color.yellow .. "  Gunakan hanya untuk menguji pengalaman milik Anda sendiri.\n" .. color.reset)
  io.write(color.gray .. "  Hentikan kapan pun dengan Ctrl+C.\n\n" .. color.reset)

  local input = prompt("  Jumlah rejoin (1-10) [3]: ")
  local cycles = input == "" and 3 or tonumber(input)
  if not cycles or cycles < 1 or cycles > 10 or cycles ~= math.floor(cycles) then
    io.write(color.red .. "  Jumlah harus 1 sampai 10.\n" .. color.reset)
    pause()
    return
  end
  if prompt("  Mulai? ketik YA: ") ~= "YA" then
    return
  end

  for cycle = 1, cycles do
    io.write("\n" .. color.cyan .. "  Rejoin " .. cycle .. " dari " .. cycles .. "\n" .. color.reset)
    open_game()
    if cycle < cycles then
      io.write(color.gray .. "  Menunggu " .. config.refresh_seconds .. " detik...\n" .. color.reset)
      sleep(config.refresh_seconds)
    end
  end
  io.write(color.green .. "\n  Sesi auto-rejoin selesai.\n" .. color.reset)
  pause()
end

local function show_help()
  write_banner()
  io.write(color.cyan .. "  BANTUAN\n" .. color.reset)
  io.write(color.gray .. "  - Skrip ini hanya membuka deep link resmi Roblox ke Place ID pilihan.\n" .. color.reset)
  io.write(color.gray .. "  - Termux tidak dapat membaca status koneksi di dalam aplikasi Roblox.\n" .. color.reset)
  io.write(color.gray .. "  - Monitor membuka game jika proses aplikasi telah tertutup.\n" .. color.reset)
  io.write(color.gray .. "  - Auto-rejoin test membuka ulang game berdasarkan timer, bukan mendeteksi kick.\n" .. color.reset)
  io.write(color.gray .. "  - Pastikan Roblox terpasang dan akun sudah masuk.\n" .. color.reset)
  io.write(color.gray .. "  - Root Window Grid mengatur task Roblox; bila tidak terbaca, skrip mencoba\n" .. color.reset)
  io.write(color.gray .. "    task aplikasi pengguna yang sedang terlihat (bukan Termux/komponen sistem).\n" .. color.reset)
  io.write(color.gray .. "    Jika ROM menolak resize, aktifkan freeform window pada pengaturan ROM Anda.\n" .. color.reset)
  io.write(color.gray .. "  - Auto Detect Roblox Apps menemukan package dengan nama roblox/mercy, lalu\n" .. color.reset)
  io.write(color.gray .. "    membuka tiap aplikasi dengan jeda 60 detik dan dapat menerapkan Auto Grid tersimpan.\n" .. color.reset)
  io.write(color.gray .. "  - Detect Roblox Apps hanya melakukan scan package tanpa membuka aplikasi.\n" .. color.reset)
  io.write(color.gray .. "  - Auto Grid Settings menyimpan layout 1x1 sampai 3x3 untuk menu Auto Grid.\n" .. color.reset)
  io.write(color.gray .. "  - Untuk rejoin dari pengalaman Anda sendiri, gunakan TeleportService di Roblox Studio.\n" .. color.reset)
  pause()
end

load_config()

while true do
  write_banner()
  local place_label = config.place_id ~= "" and config.place_id or "belum diatur"
  io.write(color.cyan .. "What would you like to do?\n" .. color.reset)
  io.write(color.green .. " 1)" .. color.white .. " Setup Termux & Dependencies (First Run)\n" .. color.reset)
  io.write(color.green .. " 2)" .. color.white .. " Setup / Edit Configuration\n" .. color.reset)
  io.write(color.green .. " 3)" .. color.white .. " Join Game Now\n" .. color.reset)
  io.write(color.green .. " 4)" .. color.white .. " Monitor Roblox & Auto-Open\n" .. color.reset)
  io.write(color.green .. " 5)" .. color.white .. " Run Auto-Rejoin Test (Timer)\n" .. color.reset)
  io.write(color.green .. " 6)" .. color.white .. " Open Join Link (Fallback)\n" .. color.reset)
  io.write(color.green .. " 7)" .. color.white .. " Help & Information\n" .. color.reset)
  io.write(color.green .. " 8)" .. color.white .. " Grid Dashboard & Settings\n" .. color.reset)
  io.write(color.green .. " 9)" .. color.white .. " Root Window Grid (Experimental)\n" .. color.reset)
  io.write(color.green .. "10)" .. color.white .. " Auto Detect Roblox Apps (60 sec delay)\n" .. color.reset)
  io.write(color.green .. "11)" .. color.white .. " Auto Grid Open App Windows\n" .. color.reset)
  io.write(color.green .. "12)" .. color.white .. " Detect Roblox Apps (Scan Only)\n" .. color.reset)
  io.write(color.green .. "13)" .. color.white .. " Detect Visible App Tasks (Scan Only)\n" .. color.reset)
  io.write(color.green .. "14)" .. color.white .. " Auto Grid Settings (Layout)\n" .. color.reset)
  io.write(color.red .. "15)" .. color.white .. " Exit\n\n" .. color.reset)
  io.write(color.gray .. " Place ID: " .. place_label .. " | Interval: " .. config.refresh_seconds
    .. " sec | Auto Grid: " .. config.auto_grid_columns .. "x" .. config.auto_grid_rows .. "\n\n" .. color.reset)

  local choice = prompt(color.cyan .. "[?] Enter your choice [1-15]: " .. color.reset)
  if choice == "1" then
    setup_termux_dependencies()
  elseif choice == "2" then
    setup_place()
  elseif choice == "3" then
    write_banner()
    open_game()
    pause()
  elseif choice == "4" then
    run_monitor()
  elseif choice == "5" then
    run_auto_rejoin_test()
  elseif choice == "6" then
    write_banner()
    open_fallback_link()
    pause()
  elseif choice == "7" then
    show_help()
  elseif choice == "8" then
    grid_dashboard_settings()
  elseif choice == "9" then
    root_window_grid()
  elseif choice == "10" then
    run_auto_detected_apps()
  elseif choice == "11" then
    run_auto_grid_open_apps()
  elseif choice == "12" then
    show_detected_roblox_apps()
  elseif choice == "13" then
    show_visible_user_tasks()
  elseif choice == "14" then
    auto_grid_settings()
  elseif choice == "15" then
    os.exit(0)
  else
    io.write(color.red .. "  Pilihan tidak tersedia.\n" .. color.reset)
    sleep(1)
  end
end
