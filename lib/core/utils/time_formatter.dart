class TimeFormatter {
  static String formatTimeAgo(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) {
      return 'Nunca';
    }

    final date = DateTime.tryParse(isoDate);
    if (date == null) return 'Fecha inválida';

    final now = DateTime.now().toUtc();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Hace un momento';
    } else if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} minuto${diff.inMinutes == 1 ? '' : 's'}';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} hora${diff.inHours == 1 ? '' : 's'}';
    } else if (diff.inDays < 30) {
      return 'Hace ${diff.inDays} día${diff.inDays == 1 ? '' : 's'}';
    } else {
      return 'Hace más de un mes';
    }
  }
}
