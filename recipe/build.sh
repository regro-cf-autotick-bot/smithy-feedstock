#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Add dependency-license-report as a plugin to build.gradle
sed -i 's/id "java-library"/id "java-library"\nid "com.github.jk1.dependency-license-report" version "latest.release"/' build.gradle

# Build with gradle and copy outputs
./gradlew clean build
./gradlew generateLicenseReport
find . -name '*.jar' | rg "build/libs" | xargs -I % cp % ${PREFIX}/libexec/${PKG_NAME}

# Create bash and batch files
tee ${PREFIX}/bin/smithy << EOF
#!/bin/sh
exec \${JAVA_HOME}/bin/java -jar \${CONDA_PREFIX}/libexec/smithy/smithy-cli-${PKG_VERSION}.jar "\$@"
EOF

tee ${PREFIX}/bin/smithy.cmd << EOF
call %JAVA_HOME%\bin\java -jar %CONDA_PREFIX%\libexec\smithy\smithy-cli-${PKG_VERSION}.jar %*
EOF
