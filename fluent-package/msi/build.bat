SET SRC_DIR=%~dp0
CALL "%SRC_DIR%env.bat"

tar xvf "%SRC_DIR%..\%PACKAGE%-%VERSION%.tar.gz"
cd "%PACKAGE%-%VERSION%"
rake msi:selfbuild FLUENT_PACKAGE_STAGING_PATH="C:/opt/fluent" FLUENT_PACKAGE_MSI_OUTPUT_PATH="%SRC_DIR%\repositories"
