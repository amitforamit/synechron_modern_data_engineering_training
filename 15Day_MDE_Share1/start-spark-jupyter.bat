@echo off
setlocal

set "IMAGE=minus1by12/sanatan:spark-lakehouse-driver-4.2.0-gravitino-1.3.0"
set "EXAMPLES=%~dp0jupyterbasedexamples"
set "STARTUP=%EXAMPLES%\pyspark_startup.py"
set "DOCKER=%ProgramFiles%\Docker\Docker\resources\bin\docker.exe"

if not exist "%DOCKER%" (
    set "DOCKER=docker"
)

if not exist "%STARTUP%" (
    echo PySpark startup script not found:
    echo %STARTUP%
    pause
    exit /b 1
)

"%DOCKER%" version >nul 2>&1
if errorlevel 1 (
    echo Docker Desktop is not running or the engine is not ready.
    echo Start Docker Desktop, wait until it reports Running, then try again.
    pause
    exit /b 1
)

"%DOCKER%" image inspect "%IMAGE%" >nul 2>&1
if errorlevel 1 (
    echo Spark image is not available locally. Pulling it now...
    "%DOCKER%" pull "%IMAGE%"
    if errorlevel 1 (
        echo The Spark image could not be downloaded.
        pause
        exit /b 1
    )
)

echo Starting Spark and JupyterLab...
echo Open the Jupyter URL printed below.
echo Press Ctrl+C to stop the container.
echo.

"%DOCKER%" run --rm ^
  --user root ^
  -e HOME=/tmp ^
  -e SPARK_UI_PORT=8889 ^
  -p 8888:8888 ^
  -p 8889:8889 ^
  --mount "type=bind,source=%STARTUP%,target=/usr/local/share/jupyter/kernels/pyspark4/startup.py,readonly" ^
  --mount "type=bind,source=%EXAMPLES%,target=/mnt/data" ^
  "%IMAGE%" ^
  jupyter-lab ^
  --ip=0.0.0.0 ^
  --port=8888 ^
  --notebook-dir=/mnt/data ^
  --no-browser ^
  --allow-root ^
  --ServerApp.disable_check_xsrf=True ^
  --LabApp.news_url='' ^
  --NotebookNotary.db_file=':memory:'

if errorlevel 1 (
    echo.
    echo The Spark and JupyterLab container stopped with an error.
    pause
)

endlocal
