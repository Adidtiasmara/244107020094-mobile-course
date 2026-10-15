/// Pengumuman kampus yang ditampilkan di beranda dan halaman detail.
///
/// Data ini statis karena backend kampus belum tersedia. Bentuknya sengaja
/// menyerupai respons `GET /announcements/:id` agar penggantian ke repository
/// jaringan hanya mengubah sumber data, bukan model atau UI.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.summary,
    required this.body,
  });

  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String summary;
  final String body;

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Tanggal ringkas, mis. `27 Sep 2026`.
  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${_monthNames[date.month - 1]} ${date.year}';
  }

  static Announcement fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Tanpa judul').toString(),
      category: (json['category'] ?? 'Umum').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      summary: (json['summary'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
    );
  }
}

class AnnouncementRepository {
  const AnnouncementRepository();

  static final List<Announcement> _items = [
    Announcement(
      id: '3',
      title: 'Jadwal kuliah berubah',
      category: 'Akademik',
      date: DateTime(2026, 9, 27, 13, 0),
      summary: 'Kelas Mobile pindah ke Ruang A2 jam 13.00.',
      body:
          'Kelas Pemrograman Mobile untuk kelas TI-2D dipindahkan ke Ruang A2 '
          'mulai pukul 13.00 WIB. Mohon hadir tepat waktu dan membawa laptop '
          'beserta proyek minggu berjalan. Perubahan berlaku sampai pemberitahuan '
          'berikutnya.',
    ),
    Announcement(
      id: '7',
      title: 'Batas unggah laporan praktikum',
      category: 'Praktikum',
      date: DateTime(2026, 9, 25, 9, 30),
      summary: 'Unggah laporan minggu 5 paling lambat Jumat 23.59 WIB.',
      body:
          'Laporan praktikum minggu 5 diunggah ke repositori portofolio masing-masing '
          'paling lambat Jumat pukul 23.59 WIB. Sertakan screenshot bukti dan '
          'pastikan `flutter analyze` bersih sebelum dikumpulkan.',
    ),
    Announcement(
      id: '12',
      title: 'Seminar keamanan aplikasi mobile',
      category: 'Kegiatan',
      date: DateTime(2026, 9, 20, 8, 0),
      summary: 'Seminar daring gratis, Sabtu 10.00 WIB, kuota 100 mahasiswa.',
      body:
          'Jurusan Teknologi Informasi mengadakan seminar daring bertema keamanan '
          'aplikasi mobile. Materi mencakup penyimpanan token, OWASP Mobile Top 10, '
          'dan studi kasus kebocoran data. Pendaftaran melalui koordinator kelas.',
    ),
  ];

  List<Announcement> all() => List.unmodifiable(_items);

  Announcement? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
