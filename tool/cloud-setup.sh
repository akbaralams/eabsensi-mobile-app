#!/usr/bin/env bash
# Setup script environment Claude Cloud untuk eabsensi-mobile-app (Ubuntu 24.04, root).
# Memasang Flutter stable terbaru. Android SDK hanya dipasang bila dl.google.com terjangkau.
# Sengaja tidak pernah gagal (selalu exit 0).
set +e
export DEBIAN_FRONTEND=noninteractive
FLUTTER_DIR=/opt/flutter

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
    rel=$(curl -fsS --max-time 30 https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json |
        python3 -c 'import sys,json; d=json.load(sys.stdin); c=d["current_release"]["stable"]; print(next(r["archive"] for r in d["releases"] if r["hash"]==c))')
    if [ -n "$rel" ]; then
        tmp=$(mktemp -d)
        curl -fsS --max-time 900 -o "$tmp/flutter.tar.xz" "https://storage.googleapis.com/flutter_infra_release/releases/$rel" &&
            tar -xf "$tmp/flutter.tar.xz" -C /opt && git config --global --add safe.directory "$FLUTTER_DIR"
        rm -rf "$tmp"
    else
        echo "!! gagal membaca versi Flutter stable"
    fi
fi
grep -q "$FLUTTER_DIR/bin" /root/.bashrc 2>/dev/null || echo "export PATH=$FLUTTER_DIR/bin:\$PATH CI=true" >>/root/.bashrc
export PATH="$FLUTTER_DIR/bin:$PATH" CI=true
flutter --disable-analytics >/dev/null 2>&1
flutter --version 2>&1 | head -2

# Android SDK (butuh dl.google.com di Allowed domains; tanpa itu `flutter build apk` tidak bisa)
export ANDROID_HOME=/opt/android-sdk
if curl -fsS --max-time 15 -o /dev/null -I https://dl.google.com/android/repository/repository2-3.xml; then
    if [ ! -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
        mkdir -p "$ANDROID_HOME/cmdline-tools" && tmp=$(mktemp -d) &&
            curl -fsS -o "$tmp/ct.zip" https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip &&
            unzip -q "$tmp/ct.zip" -d "$tmp" && mv "$tmp/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
        rm -rf "$tmp"
    fi
    yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1
    "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-36" "build-tools;36.0.0" 2>&1 | tail -2
    flutter config --android-sdk "$ANDROID_HOME" >/dev/null 2>&1
    echo "export ANDROID_HOME=$ANDROID_HOME" >>/root/.bashrc
else
    echo "!! dl.google.com tidak terjangkau: Android SDK dilewati (analyze/test/golden tetap jalan, build APK tidak)"
fi

# Maven Central membatasi laju (429) dari VM cloud: pakai mirror Google dan kurangi paralelisme Gradle.
mkdir -p /root/.gradle/init.d
cat >/root/.gradle/init.d/mirror.gradle <<'GRADLE'
def mirror = 'https://maven-central.storage-download.googleapis.com/maven2/'
def isCentral = { r -> r instanceof MavenArtifactRepository && (r.url.toString().startsWith('https://repo.maven.apache.org/maven2') || r.url.toString().startsWith('https://repo1.maven.org/maven2')) }
settingsEvaluated { s ->
    s.pluginManagement.repositories.all { r -> if (isCentral(r)) r.url = uri(mirror) }
    s.dependencyResolutionManagement.repositories.all { r -> if (isCentral(r)) r.url = uri(mirror) }
}
allprojects {
    buildscript.repositories.all { r -> if (isCentral(r)) r.url = uri(mirror) }
    repositories.all { r -> if (isCentral(r)) r.url = uri(mirror) }
}
GRADLE
grep -q 'org.gradle.workers.max' /root/.gradle/gradle.properties 2>/dev/null ||
    printf 'org.gradle.parallel=false\norg.gradle.workers.max=2\n' >>/root/.gradle/gradle.properties
exit 0
