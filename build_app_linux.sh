#!/bin/bash

# ------ ENVIRONMENT --------------------------------------------------------
# The script depends on various environment variables to exist in order to
# run properly. The java version we want to use, the location of the java
# binaries (java home), and the project version as defined inside the pom.xml
# file, e.g. 1.0-SNAPSHOT.
#
# JAVA_VERSION: JDK Version
# PROJECT_VERSION: version used in pom.xml, e.g. 1.0-SNAPSHOT
# ARTIFACT_ID: Project Artifact Id from pom
# MAIN_CLASS: App main class
# APP_NAME: The App name

VENDOR="GonGarceIO"
MAIN_JAR="$ARTIFACT_ID-$PROJECT_VERSION.jar"

# Set desired installer type: "app-image", "rpm" or "deb".
INSTALLER_TYPE=rpm

echo "java home: $JAVA_HOME"
echo "project version: $PROJECT_VERSION"
echo "main JAR file: $MAIN_JAR"

# ------ SETUP DIRECTORIES AND FILES ----------------------------------------
# Remove previously generated java runtime and installers. Copy all required
# jar files into the input/libs folder.

rm -rfd ./target/runtime/
rm -rfd target/installer/

mkdir -p target/installer/input/libs/

#cp target/libs/* target/installer/input/libs/
cp target/${MAIN_JAR} target/installer/input/

# ------ REQUIRED MODULES ---------------------------------------------------
# Use jlink to detect all modules that are required to run the application.
# Starting point for the jdep analysis is the set of jars being used by the
# application.

#echo "detecting required modules"
#detected_modules=`$JAVA_HOME/bin/jdeps \
#  -q \
#  --multi-release ${JAVA_VERSION} \
#  --ignore-missing-deps \
#  --print-module-deps \
#  --class-path "target/installer/input/libs/*" \
#    target/classes/com/dlsc/jpackagefx/App.class`
#echo "detected modules: ${detected_modules}"


# ------ MANUAL MODULES -----------------------------------------------------
# jdk.crypto.ec has to be added manually bound via --bind-services or
# otherwise HTTPS does not work.
#
# See: https://bugs.openjdk.java.net/browse/JDK-8221674
#
# In addition we need jdk.localedata if the application is localized.
# This can be reduced to the actually needed locales via a jlink parameter,
# e.g., --include-locales=en,de.
#
# Don't forget the leading ','!

#manual_modules=,jdk.crypto.ec,jdk.localedata
#echo "manual modules: ${manual_modules}"

# ------ RUNTIME IMAGE ------------------------------------------------------
# Use the jlink tool to create a runtime image for our application. We are
# doing this in a separate step instead of letting jlink do the work as part
# of the jpackage tool. This approach allows for finer configuration and also
# works with dependencies that are not fully modularized, yet.

echo "creating java runtime image"
$JAVA_HOME/bin/jlink \
  --strip-native-commands \
  --no-header-files \
  --no-man-pages  \
  --compress=zip-9  \
  --strip-debug \
  --add-modules ALL-MODULE-PATH \
  --include-locales=en,es \
  --output target/runtime

# ------ PACKAGING ----------------------------------------------------------
# In the end we will find the package inside the target/installer directory.

echo "Creating installer of type $INSTALLER_TYPE"

$JAVA_HOME/bin/jpackage \
--type $INSTALLER_TYPE \
--dest target/installer \
--input target/installer/input \
--name ${APP_NAME} \
--main-class ${MAIN_CLASS} \
--main-jar ${MAIN_JAR} \
--java-options -Xmx2048m \
--runtime-image target/runtime \
--icon src/main/resources/images/icon.png \
--app-version ${PROJECT_VERSION} \
--vendor ${VENDOR}