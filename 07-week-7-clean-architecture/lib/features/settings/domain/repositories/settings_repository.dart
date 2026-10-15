/// Kontrak penyimpanan preferensi (key-value).
///
/// Operasi ini sengaja **tidak** memakai pembungkus `Failure`: nilainya primitif
/// dan tidak ada aturan bisnis, sehingga membungkus tiap get/set dengan record
/// sukses/gagal justru over-engineering (lihat catatan di README/docs).
abstract class SettingsRepository {
  Future<bool> getDarkMode();

  Future<void> setDarkMode(bool value);

  Future<void> markOpenedNow();

  Future<String?> getLastOpened();
}
