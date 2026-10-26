import 'package:flutter/material.dart';

import '../models/announcement.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key, required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                Chip(
                  avatar: const Icon(Icons.label_outline, size: 16),
                  label: Text(announcement.category),
                ),
                Chip(
                  avatar: const Icon(Icons.event_outlined, size: 16),
                  label: Text(announcement.date),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(announcement.author)),
                const Icon(Icons.visibility_outlined, size: 16),
                const SizedBox(width: 4),
                Text('${announcement.readCount} dibaca'),
              ],
            ),
            const Divider(height: 32),
            Text(announcement.content, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali ke Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}