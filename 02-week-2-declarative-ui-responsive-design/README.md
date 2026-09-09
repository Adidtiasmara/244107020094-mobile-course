# 02 Week 2: Declarative UI and Responsive Design

## Tujuan Praktikum

- Membangun dashboard akademik sederhana menggunakan Flutter.
- Menyusun tampilan menggunakan `Row`, `Column`, `Container`, dan `Expanded`.
- Membuat layout responsif untuk layar sempit dan layar lebar.
- Menampilkan kartu informasi akademik secara rapi dan mudah dipahami.
- Menerapkan pergantian light theme dan dark theme menggunakan `CupertinoSwitch`.
- Menambahkan `Semantics` agar informasi penting lebih mudah diakses screen reader.
- Membandingkan penggunaan `GridView` dengan `LayoutBuilder + Column`.
- Memahami cara mencegah overflow pada widget `Row` dan `Expanded`.
- Menguji tampilan aplikasi menggunakan ukuran layar yang berbeda.

## Praktikum: Layout Sederhana (Warm-up)

<table>
  <tr>
    <td align="center">
      <strong>Warm-up</strong><br><br>
      <img
        src="screenshots/warmup.jpeg"
        width="260"
        alt="Screenshot warm-up"
      >
    </td>
  </tr>
</table>

### Eksperimen Warm-up

<table>
  <tr>
    <td align="center">
      <strong>Expanded</strong><br><br>
      <img
        src="screenshots/expanded.jpeg"
        width="220"
        alt="Eksperimen Expanded"
      >
    </td>
    <td align="center">
      <strong>Main Axis</strong><br><br>
      <img
        src="screenshots/mainaxis.jpeg"
        width="220"
        alt="Eksperimen Main Axis"
      >
    </td>
    <td align="center">
      <strong>Email</strong><br><br>
      <img
        src="screenshots/email.jpeg"
        width="180"
        alt="Eksperimen Email"
      >
    </td>
  </tr>
</table>

## Praktikum: Dashboard Responsif

### Eksperimen Layout

<table>
  <tr>
    <td align="center">
      <strong>Profil+Cuppertino</strong><br><br>
      <img
        src="screenshots/profil+cuppertino.jpeg"
        width="260"
        alt="profil+cuppertino"
      >
    </td>
    <td align="center">
      <strong>Layar Lebar</strong><br><br>
      <img
        src="screenshots/ukuran-layar.jpeg"
        width="420"
        alt="Dashboard layar lebar"
      >
    </td>
  </tr>
</table>

## Tugas Utama: Academic Overview

Pada tugas utama, dashboard dikembangkan menjadi halaman **Academic Overview** yang menampilkan informasi akademik mahasiswa secara sederhana dan responsif.

### Fitur yang Diimplementasikan

- Menampilkan header profil mahasiswa.
- Menampilkan nama mahasiswa, program studi, dan semester.
- Menampilkan empat kartu informasi akademik:
  - Assignments
  - Attendance
  - GPA
  - Current Week
- Menggunakan widget `Row` untuk menyusun elemen secara horizontal.
- Menggunakan widget `Column` untuk menyusun informasi secara vertikal.
- Menggunakan `Expanded` agar elemen dapat menyesuaikan ruang yang tersedia.
- Menggunakan `Container` untuk membentuk area header profil.
- Menggunakan `LayoutBuilder` untuk menyesuaikan tampilan berdasarkan ukuran layar.
- Menampilkan satu kolom pada layar sempit.
- Menampilkan dua kolom pada layar lebar.
- Menyediakan light theme dan dark theme.
- Menambahkan toggle tema menggunakan `CupertinoSwitch`.
- Menambahkan label aksesibilitas menggunakan `Semantics`.

Hasil Implementasi
<table>
  <tr>
    <td align="center">
      <strong>Academic Overviewt</strong><br><br>
      <img
        src="screenshots/academic.jpeg"
        width="300"
        alt="Academic Overview "
      >
      <br><br>
      Satu kolom
    </td>
    <td align="center">
      <strong>Academic Layar Lebar</strong><br><br>
      <img
        src="screenshots/academic-lebar.jpeg"
        width="500"
        alt="Academic Overview pada layar lebar"
      >
      <br><br>
      Dua kolom
    </td>
  </tr>
</table>
