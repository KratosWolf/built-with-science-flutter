# Releases - Built With Science App

Esta pasta contém as versões compiladas (APKs) do aplicativo Android.

## Política de Retenção

- **Mantidos**: Apenas as 3 versões mais recentes
- **Limpeza**: APKs antigos são removidos regularmente para economizar espaço
- **Versionamento**: APKs não são versionados no Git (ver `.gitignore`)

## Versões Atuais

### v5.21 - Dashboard Charts (24/11/2024)
- **File**: APP_V5.21_DASHBOARD_CHARTS.apk
- **Size**: 23MB
- Dashboard com gráficos de progresso integrados

### v5.20 - Dashboard Supabase (24/11/2024)
- **File**: APP_V5.20_DASHBOARD_SUPABASE.apk
- **Size**: 23MB
- Dashboard integrado com sincronização Supabase

### v5.19 - Sync Complete (24/11/2024)
- **File**: APP_V5.19_SYNC_COMPLETE.apk
- **Size**: 23MB
- Sistema de sincronização completo

## Build de Produção

Para gerar um novo APK:

```bash
flutter build apk --release
```

O APK gerado estará em `build/app/outputs/flutter-apk/app-release.apk`.

## Histórico

Versões anteriores (v2.0 - v5.18) foram arquivadas em 16/02/2026 durante a Fase 1 de limpeza do projeto.
Total economizado: ~1GB de espaço em disco.
