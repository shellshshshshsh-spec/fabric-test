# fabric-test

Build Apache Log4j **2.26.1** from its official Apache source release and
check console logging with the resulting API and Core JARs.

Run the Workspace check from the repository root:

```sh
bash .sandcastle/repos/fabric-test/verify.sh
```

The entry point delegates to `verify.sh`, which can also be run with `sh verify.sh`.
Requirements: JDK 17 (set `JAVA_HOME` if needed), a POSIX shell, curl, unzip,
sha512sum, grep, and network access to Apache and Maven repositories. The release's
Maven wrapper downloads Maven; prebuilt Maven plugins and external build
dependencies are allowed.

Each check downloads the [Apache source archive](https://archive.apache.org/dist/logging/log4j/2.26.1/),
verifies its pinned SHA-512, and builds `log4j-api-java9`, `log4j-core-java9`,
`log4j-api`, and `log4j-core` with their required reactor parents using upstream
Maven packaging on JDK 17. Upstream tests are skipped; the full reactor and
recursive source builds of external dependencies are outside this check.

A Java source-file example uses only the freshly built `log4j-api-2.26.1.jar`
and `log4j-core-2.26.1.jar` on its classpath. An explicit Core console appender
writes `fabric-test Log4j console smoke test` to stdout. The check prints that
exact line on success and fails on download, checksum, build, launch, or marker
failure. Temporary sources and build artifacts are removed on exit; Maven's
local dependency cache is retained. No artifacts are published.
