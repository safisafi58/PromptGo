# PromptGo

A polished, English-language Flutter app for discovering AI prompts.

## User app features
- Premium dark theme and branded animated splash screen.
- Home screen with Search and Menu, featured image slider, categories, and prompt image cards.
- Tap a prompt image to open its detail screen.
- Prompt text is revealed with a typewriter animation; the Copy button appears after the full text is shown.
- Favorites are stored locally on the device.
- Share prompt, refresh catalog, and search prompt title or text.

## Supabase connection
Project ref: `evaammherpizsntcbzbf`

Public catalog tables:
- `public.categories`
- `public.prompts`

The app connects using the project's publishable key. Both tables have RLS enabled and public SELECT-only policies. Do not put a Supabase secret/service-role key in the Flutter app.

## Build APK
The workflow `.github/workflows/build-user-apk.yml` builds the Android release APK on every push to `main` and on manual dispatch. Download `PromptGo-User-APK` from the Actions run artifacts.
