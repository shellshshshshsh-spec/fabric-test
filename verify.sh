#!/bin/sh
# Build Log4j from its Apache source release and verify console output.
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
test -s "$repo_dir/README.md"

# Use the same JDK for Maven and the source-file launcher.
if [ -n "${JAVA_HOME:-}" ]; then
    PATH="$JAVA_HOME/bin:$PATH"
    export PATH
fi
java -version 2>&1 | grep -E 'version "17[.]'

version=2.26.1
archive="apache-log4j-${version}-src.zip"
checksum=f4fa83e4185e479da6b5d8ecece6ce75645b1645ccb6cd4fb71dca184edc8a748e363da0a217466704efe264b51b351b11536dca4e7a3a1031524616f12d55c8
build_dir=$(mktemp -d)
trap 'rm -rf -- "$build_dir"' 0
cd "$build_dir"

curl --fail --silent --show-error --location --retry 3 \
    "https://archive.apache.org/dist/logging/log4j/$version/$archive" \
    --output "$archive"
printf '%s  %s\n' "$checksum" "$archive" | sha512sum --check
unzip -q "$archive"

sh ./mvnw --batch-mode --no-transfer-progress \
    --projects :log4j-api-java9,:log4j-core-java9,:log4j-api,:log4j-core \
    --also-make -DskipTests package

api_jar="log4j-api/target/log4j-api-$version.jar"
core_jar="log4j-core/target/log4j-core-$version.jar"
test -s "$api_jar"
test -s "$core_jar"

cat > Log4jSmoke.java <<'JAVA'
import org.apache.logging.log4j.LogManager;

class Log4jSmoke {
    public static void main(String[] args) {
        LogManager.getLogger(Log4jSmoke.class).error("fabric-test Log4j console smoke test");
    }
}
JAVA

cat > log4j2.xml <<'XML'
<Configuration>
  <Appenders>
    <Console name="Console" target="SYSTEM_OUT">
      <PatternLayout pattern="%m%n"/>
    </Console>
  </Appenders>
  <Loggers>
    <Root level="error">
      <AppenderRef ref="Console"/>
    </Root>
  </Loggers>
</Configuration>
XML

java -Dlog4j2.configurationFile="$build_dir/log4j2.xml" \
    --class-path "$api_jar:$core_jar" Log4jSmoke.java > console.log
grep -Fx 'fabric-test Log4j console smoke test' console.log
