@ECHO OFF

rem ------ ENVIRONMENT --------------------------------------------------------
rem The script depends on various environment variables to exist in order to
rem run properly. The java version we want to use, the location of the java
rem binaries (java home), and the project version as defined inside the pom.xml
rem file, e.g. 1.0-SNAPSHOT.
rem
rem JAVA_VERSION: JDK Version
rem PROJECT_VERSION: version used in pom.xml, e.g. 1.0-SNAPSHOT
rem ARTIFACT_ID: Project Artifact Id from pom
rem MAIN_CLASS: App main class
rem APP_NAME: The App name

set VENDOR="GonGarceIO"
set MAIN_JAR=%ARTIFACT_ID%-%PROJECT_VERSION%.jar

rem Set desired installer type: "app-image" "msi" "exe".
set INSTALLER_TYPE=exe

rem ------ SETUP DIRECTORIES AND FILES ----------------------------------------
rem Remove previously generated java runtime and installers. Copy all required
rem jar files into the input/libs folder.

IF EXIST target\runtime rmdir /S /Q  .\target\runtime
IF EXIST target\installer rmdir /S /Q target\installer

rem xcopy /S /Q target\libs\* target\installer\input\libs\
xcopy target\%MAIN_JAR% target\installer\input\

rem ------ REQUIRED MODULES ---------------------------------------------------
rem Use jlink to detect all modules that are required to run the application.
rem Starting point for the jdep analysis is the set of jars being used by the
rem application.
rem --class-path "target\installer\input\*" ^
rem target\classes\com\dlsc\jpackagefx\App.class

echo detecting required modules

rem "%JAVA_HOME%\bin\jdeps" ^
rem   -q ^
rem   --multi-release %JAVA_VERSION% ^
rem   --ignore-missing-deps ^
rem   --print-module-deps target\installer\input\%MAIN_JAR% > temp.txt

rem set /p detected_modules=<temp.txt

rem echo detected modules: %detected_modules%

rem ------ MANUAL MODULES -----------------------------------------------------
rem jdk.crypto.ec has to be added manually bound via --bind-services or
rem otherwise HTTPS does not work.
rem
rem See: https://bugs.openjdk.java.net/browse/JDK-8221674
rem
rem In addition we need jdk.localedata if the application is localized.
rem This can be reduced to the actually needed locales via a jlink parameter,
rem e.g., --include-locales=en,de.
rem
rem Don't forget the leading ','!

rem set manual_modules=,jdk.crypto.ec,jdk.localedata
rem echo manual modules: %manual_modules%

rem ------ RUNTIME IMAGE ------------------------------------------------------
rem Use the jlink tool to create a runtime image for our application. We are
rem doing this in a separate step instead of letting jlink do the work as part
rem of the jpackage tool. This approach allows for finer configuration and also
rem works with dependencies that are not fully modularized, yet.
rem --add-modules %detected_modules%%manual_modules% ^

echo creating java runtime image

call "%JAVA_HOME%\bin\jlink" ^
  --strip-native-commands ^
  --no-header-files ^
  --no-man-pages ^
  --compress=zip-9 ^
  --strip-debug ^
  --add-modules ALL-MODULE-PATH ^
  --include-locales=en,es ^
  --output target/runtime


rem ------ PACKAGING ----------------------------------------------------------
rem In the end we will find the package inside the target/installer directory.
rem --copyright "Copyright © 2019-21 ACME Inc." ^
rem --win-per-user-install ^

call "%JAVA_HOME%\bin\jpackage" ^
  --type %INSTALLER_TYPE% ^
  --dest target/installer ^
  --input target/installer/input ^
  --name %APP_NAME% ^
  --main-class %MAIN_CLASS% ^
  --main-jar %MAIN_JAR% ^
  --java-options -Xmx2048m ^
  --runtime-image target/runtime ^
  --icon src/main/resources/images/icon.ico ^
  --app-version %PROJECT_VERSION% ^
  --vendor %VENDOR% ^
  --win-dir-chooser ^
  --win-shortcut ^
  --win-menu
