import '../routes.dart';

/// Mengubah `data` payload FCM menjadi rute internal.
///
/// Fungsi murni tanpa dependensi Firebase agar bisa diunit-test. Aturan:
/// - `route` kosong atau tidak ada -> beranda.
/// - `route` tanpa garis miring di depan -> ditambahkan otomatis.
String routeFromMessage(Map<String, dynamic> data) {
  final raw = (data['route'] ?? '').toString().trim();
  if (raw.isEmpty) return AppRoutes.home;
  return raw.startsWith('/') ? raw : '/$raw';
}

/// Mengambil id pengumuman dari payload.
///
/// Diprioritaskan dari field `id`, dan bila tidak ada, diambil dari segmen
/// terakhir rute `/pengumuman/<id>`.
String? announcementIdFromMessage(Map<String, dynamic> data) {
  final id = data['id']?.toString().trim();
  if (id != null && id.isNotEmpty) return id;

  final segments = routeFromMessage(data)
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .toList();
  return segments.isEmpty ? null : segments.last;
}
