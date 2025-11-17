# Network Security Configuration - Documentation

## 📋 Overview

Project ini memiliki 2 file network security config:

1. **`network_security_config.xml`** - Development (dengan localhost support)
2. **`network_security_config_prod.xml`** - Production (HTTPS only, no cleartext)

---

## 🔒 Security Features

### Development Config (`network_security_config.xml`)

```xml
✅ HTTPS enforced untuk semua domain (default)
⚠️ Localhost cleartext ALLOWED (untuk testing local API)
✅ System certificates trusted
```

**Allowed:**
- ✅ `https://wellness.netlify.app`
- ✅ `http://localhost:*` (development only)
- ✅ `http://127.0.0.1:*` (development only)
- ✅ `http://10.0.2.2:*` (Android emulator)

---

### Production Config (`network_security_config_prod.xml`)

```xml
✅ HTTPS enforced untuk SEMUA domain
❌ NO cleartext traffic
❌ NO localhost exception
✅ System certificates trusted
```

**Allowed:**
- ✅ `https://wellness.netlify.app`
- ❌ `http://localhost:*` (BLOCKED)
- ❌ `http://127.0.0.1:*` (BLOCKED)
- ❌ ANY HTTP traffic (BLOCKED)

---

## 🔧 Usage

### Development Build

```bash
# File sudah OK, langsung build
flutter build apk --debug

# Atau run di device
flutter run
```

### Production Build

**Option 1: Manual Replace (Recommended)**
```bash
# 1. Backup development config
cp android/app/src/main/res/xml/network_security_config.xml network_security_config_dev.xml.backup

# 2. Replace dengan production config
cp android/app/src/main/res/xml/network_security_config_prod.xml android/app/src/main/res/xml/network_security_config.xml

# 3. Build release
flutter build apk --release

# 4. Restore development config (optional)
cp network_security_config_dev.xml.backup android/app/src/main/res/xml/network_security_config.xml
```

**Option 2: Using Build Flavors (Advanced)**

Buat flavors di `android/app/build.gradle.kts`:

```kotlin
android {
    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
        }
        create("prod") {
            dimension = "environment"
        }
    }
}
```

Kemudian copy file ke folder flavor-specific:
- `res/xml-dev/network_security_config.xml` (dengan localhost)
- `res/xml-prod/network_security_config.xml` (tanpa localhost)

---

## ⚠️ Important Notes

### Security Considerations

1. **NEVER ship app dengan localhost cleartext ke production!**
   - Attacker bisa exploit untuk man-in-the-middle attack
   - Bisa bypass HTTPS requirements

2. **Production HARUS:**
   - ✅ HTTPS only
   - ✅ No cleartext traffic
   - ✅ Certificate pinning (optional, untuk extra security)

3. **Development boleh:**
   - ⚠️ Localhost cleartext (untuk testing)
   - ⚠️ User certificates (untuk debugging proxy)

### Testing Checklist

**Before Production Release:**
- [ ] Replace network_security_config.xml dengan production version
- [ ] Remove localhost cleartext traffic
- [ ] Test API calls dengan HTTPS
- [ ] Verify no HTTP fallback
- [ ] Check AndroidManifest.xml → usesCleartextTraffic="false"

---

## 🧪 Testing Network Security

### Test 1: Verify HTTPS Enforcement

```bash
# Install debug build
flutter install

# Monitor logcat
adb logcat | grep -i "cleartext\|security"

# Should see: "Cleartext HTTP traffic not permitted"
# if trying to access HTTP URLs
```

### Test 2: Test API Connectivity

```dart
// Test HTTPS endpoint
final response = await http.get(
  Uri.parse('https://wellness.netlify.app/api/health')
);
// ✅ Should work

// Test HTTP endpoint
final response = await http.get(
  Uri.parse('http://wellness.netlify.app/api/health')
);
// ❌ Should fail with "Cleartext HTTP traffic not permitted"
```

---

## 📊 Config Comparison

| Feature | Development | Production |
|---------|-------------|------------|
| **HTTPS** | ✅ Required | ✅ Required |
| **HTTP** | ⚠️ Localhost only | ❌ Blocked |
| **Localhost** | ✅ Allowed | ❌ Blocked |
| **System Certs** | ✅ Trusted | ✅ Trusted |
| **User Certs** | ⚠️ Optional | ❌ Not trusted |
| **Cleartext Base** | ❌ Disabled | ❌ Disabled |

---

## 🔐 Best Practices

### 1. Certificate Pinning (Optional - Extra Security)

Untuk extra security, tambahkan certificate pinning:

```xml
<domain-config>
    <domain includeSubdomains="true">wellness.netlify.app</domain>
    <pin-set expiration="2026-01-01">
        <pin digest="SHA-256">base64==</pin>
        <!-- backup pin -->
        <pin digest="SHA-256">backup_base64==</pin>
    </pin-set>
</domain-config>
```

### 2. Debugging Network Issues

```xml
<!-- Add untuk debugging (REMOVE untuk production) -->
<debug-overrides>
    <trust-anchors>
        <certificates src="user" />
    </trust-anchors>
</debug-overrides>
```

### 3. Multiple Domain Support

```xml
<domain-config cleartextTrafficPermitted="false">
    <domain includeSubdomains="true">wellness.netlify.app</domain>
    <domain includeSubdomains="true">api.wellness.com</domain>
    <domain includeSubdomains="true">cdn.wellness.com</domain>
</domain-config>
```

---

## 📱 Build Commands

### Debug Build (Development Config)
```bash
flutter build apk --debug
# Uses network_security_config.xml (with localhost)
```

### Release Build (Production Config)
```bash
# IMPORTANT: Replace config first!
cp android/app/src/main/res/xml/network_security_config_prod.xml \
   android/app/src/main/res/xml/network_security_config.xml

flutter build apk --release
```

### App Bundle (Google Play)
```bash
# IMPORTANT: Use production config!
flutter build appbundle --release
```

---

## ✅ Verification

After build, verify dengan:

```bash
# Extract APK
unzip app-release.apk -d extracted/

# Check network_security_config.xml
cat extracted/res/xml/network_security_config.xml

# Should NOT contain localhost if production build!
```

---

## 🆘 Troubleshooting

### Issue: "Cleartext HTTP traffic to XXX not permitted"

**Cause:** Trying to access HTTP endpoint

**Solution:**
1. Change endpoint to HTTPS
2. Or add domain to development config (if local testing)

### Issue: "Trust anchor for certification path not found"

**Cause:** SSL certificate not trusted

**Solution:**
1. Verify API has valid SSL certificate
2. Check if using self-signed cert (not allowed in production)
3. Add `<certificates src="user" />` for development only

---

## 📚 References

- [Android Network Security Config](https://developer.android.com/training/articles/security-config)
- [Certificate Pinning Best Practices](https://developer.android.com/training/articles/security-ssl)

---

**Last Updated:** November 17, 2025
**App Version:** 1.0.0
**Min SDK:** 21
**Target SDK:** 34

