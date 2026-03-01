import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/models/settings_data.dart';
import 'package:songbook_flutter/utilities/constants.dart';

class SettingsScreen extends StatelessWidget {
  static const String id = 'settings_screen';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsData>();

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ListTile(
            title: Text('Theme'),
            subtitle: Text('App color scheme'),
            trailing: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  label: Text('Auto'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Dark'),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) =>
                  context.read<SettingsData>().setThemeMode(s.first),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Accessibility',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ListTile(
            title: Text('Text Size'),
            subtitle: Text('Lyrics and content text size'),
            trailing: SegmentedButton<double>(
              segments: [
                ButtonSegment(
                  value: kSmallTextSizeFactor,
                  label: Text('S'),
                ),
                ButtonSegment(
                  value: kMediumTextSizeFactor,
                  label: Text('M'),
                ),
                ButtonSegment(
                  value: kLargeTextSizeFactor,
                  label: Text('L'),
                ),
              ],
              selected: {settings.textSizeFactor},
              onSelectionChanged: (s) =>
                  context.read<SettingsData>().setTextSizeFactor(s.first),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Reading',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Line Spacing',
                    style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: 2),
                Text('Space between lines of lyrics',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<double>(
                    segments: [
                      ButtonSegment(
                        value: kCompactLineSpacing,
                        label: Text('Compact'),
                      ),
                      ButtonSegment(
                        value: kNormalLineSpacing,
                        label: Text('Normal'),
                      ),
                      ButtonSegment(
                        value: kSpaciousLineSpacing,
                        label: Text('Spacious'),
                      ),
                    ],
                    selected: {settings.lineSpacingFactor},
                    onSelectionChanged: (s) =>
                        context.read<SettingsData>().setLineSpacing(s.first),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Preview',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                'ഉണര്‍വ്വിന്‍ വരം ലഭിപ്പാന്‍\nഞങ്ങള്‍ വരുന്നൂ തിരുസവിധേ\nനാഥാ - നിന്‍റെ വന്‍ കൃപകള്‍\nഞങ്ങള്‍ക്കരുളൂ അനുഗ്രഹിക്കൂ',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18 * settings.textSizeFactor,
                  height: settings.lineSpacingFactor,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
