/// Exception kustom untuk menangani error jaringan, server, dan parsing JSON.
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  factory ApiException.noInternet() =>
      const ApiException('Tidak ada koneksi internet');

  factory ApiException.timeout() =>
      const ApiException('Koneksi timeout. Silakan coba lagi.');

  factory ApiException.notFound() =>
      const ApiException('Data tidak ditemukan');

  factory ApiException.server(int statusCode) =>
      ApiException('Terjadi kesalahan server (Kode $statusCode)');

  factory ApiException.parse() =>
      const ApiException('Data tidak dapat dibaca');

  @override
  String toString() => message;
}
