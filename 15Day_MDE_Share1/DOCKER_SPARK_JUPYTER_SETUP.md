# Docker-Based Spark + JupyterLab Setup on Windows

This guide documents the complete setup used to run the repository's Spark notebooks with Docker Desktop, WSL 2, and JupyterLab.

## Quick Start After Installation

Use these steps each time you want to work with the Spark notebooks:

1. Start Docker Desktop and wait until it reports that the engine is running.
2. Open PowerShell and move to the repository root:

```powershell
cd E:\coding_ground\synechron_modern_data_engineering_training
```

3. Confirm that Docker is available:

```powershell
docker version
```

The output must include both `Client` and `Server` sections.

4. Start the container by running the PowerShell command in [DOCKERCOMMAND.txt](DOCKERCOMMAND.txt), or copy the command from section 5 below.
5. Open the tokenized JupyterLab URL printed in the terminal, usually `http://localhost:8888/lab?token=...`.
6. Open an existing notebook or create one with the `pyspark4` / `SANATAN Spark Python 4` kernel.
7. Run a Spark action to initialize Spark:

```python
spark.range(10).count()
```

8. Open the Spark UI at [http://localhost:8889](http://localhost:8889).

Keep the Docker terminal open while working. When finished, press `Ctrl+C` in that terminal to stop the container.

For a one-click start, double-click `15Day_MDE_Share1\start-spark-jupyter.bat` in File Explorer. The batch file checks Docker, pulls the Spark image if it is missing, and starts the same container command. It uses paths relative to its own location, so it does not require the repository to be the current PowerShell directory.

From a terminal, run it with:

```powershell
& .\15Day_MDE_Share1\start-spark-jupyter.bat
```

## 1. Prerequisites

The setup requires:

- Windows 10 or Windows 11, 64-bit
- Hardware virtualization enabled in the BIOS/UEFI
- Administrator access for installing Windows components and Docker Desktop
- Docker Desktop with the WSL 2 backend
- WSL 2 with an Ubuntu distribution

Check WSL from an Administrator PowerShell window:

```powershell
wsl --status
wsl --list --verbose
```

If WSL is not installed, install it with:

```powershell
wsl --install
```

Restart Windows if requested. Confirm that the Ubuntu distribution uses version 2:

```powershell
wsl --list --verbose
```

The VERSION column should show `2`.

## 2. Install Docker Desktop

Install Docker Desktop with WinGet:

```powershell
winget install --exact --id Docker.DockerDesktop
```

Start Docker Desktop from the Windows Start menu. In Docker Desktop settings, use the WSL 2 based engine when prompted or when selecting the container engine configuration.

Open a new PowerShell window after installation so the Docker executable is added to `PATH`.

Verify Docker:

```powershell
docker version
docker run --rm hello-world
```

The `docker version` output should include both a Client section and a Server section. If it only shows the client, start Docker Desktop and wait until its status is Running.

## 3. Move to the Repository Root

The repository root used for this setup is:

```powershell
cd E:\coding_ground\synechron_modern_data_engineering_training
```

The relevant notebook directory is:

```text
15Day_MDE_Share1\jupyterbasedexamples
```

The PySpark startup script is:

```text
15Day_MDE_Share1\jupyterbasedexamples\pyspark_startup.py
```

The startup script exposes these names in a PySpark notebook:

- `spark`: the SparkSession
- `sc`: the SparkContext
- `sql`: a shortcut for `spark.sql`

## 4. Pull the Spark Image

The repository uses this external image; there is no local Dockerfile or Compose file:

```text
minus1by12/sanatan:spark-lakehouse-driver-4.2.0-gravitino-1.3.0
```

Pull it before starting the container:

```powershell
docker pull minus1by12/sanatan:spark-lakehouse-driver-4.2.0-gravitino-1.3.0
```

Confirm that it is available locally:

```powershell
docker image ls minus1by12/sanatan
```

If `docker` is not recognized immediately after installation, close the old PowerShell window and open a new one. Docker Desktop may also need to be started first.

## 5. Start Spark and JupyterLab

Run this from the repository root in PowerShell:

```powershell
$examples = (Resolve-Path ".\15Day_MDE_Share1\jupyterbasedexamples").Path
$startup = (Resolve-Path "$examples\pyspark_startup.py").Path

docker run --rm `
  --user root `
  -e HOME=/tmp `
  -e SPARK_UI_PORT=8889 `
  -p 8888:8888 `
  -p 8889:8889 `
  --mount "type=bind,source=$startup,target=/usr/local/share/jupyter/kernels/pyspark4/startup.py,readonly" `
  --mount "type=bind,source=$examples,target=/mnt/data" `
  minus1by12/sanatan:spark-lakehouse-driver-4.2.0-gravitino-1.3.0 `
  jupyter-lab `
  --ip=0.0.0.0 `
  --port=8888 `
  --notebook-dir=/mnt/data `
  --no-browser `
  --allow-root `
  --ServerApp.disable_check_xsrf=True `
  --LabApp.news_url='' `
  --NotebookNotary.db_file=':memory:'
```

Keep this terminal open while using JupyterLab. The `--rm` option removes the container when it stops; notebooks remain on the Windows host because the notebook directory is bind-mounted.

## 6. Open JupyterLab

The container prints a tokenized URL in the terminal. Open the URL that looks like this:

```text
http://localhost:8888/lab?token=...
```

The notebooks from `15Day_MDE_Share1\jupyterbasedexamples` appear in JupyterLab under `/mnt/data`.

## 7. Start Spark in a Notebook

Creating the container does not automatically start a Spark application. In JupyterLab:

1. Create a notebook or open an existing notebook.
2. Select the PySpark kernel, named `pyspark4` or `SANATAN Spark Python 4`.
3. Run a Spark action such as:

```python
spark.range(10).count()
```

The startup script then creates `spark`, `sc`, and `sql` before the first cell runs.

Do not use the regular `Python 3` kernel for Spark notebooks. That kernel does not load the Spark startup script.

## 8. Open the Spark UI

After a PySpark or Scala Spark kernel has created a Spark application, open:

```text
http://localhost:8889
```

The Spark UI may not respond before a Spark kernel starts. Port 8889 is published by Docker, but the Spark application must first bind the UI to that port.

The startup configuration uses:

- Spark master: `local[*]`
- Spark UI port: `8889`
- Spark warehouse directory: `/tmp/spark-warehouse`

`local[*]` uses the available CPU cores inside the container.

## 9. Check the Container

In another PowerShell window:

```powershell
docker ps
```

The container should show ports similar to:

```text
0.0.0.0:8888-8889->8888-8889/tcp
```

To inspect container logs, first get the container ID:

```powershell
docker ps
```

Then run:

```powershell
docker logs <container-id>
```

A successful Jupyter startup includes a line containing:

```text
Jupyter Server ... is running at:
```

## 10. Stop and Restart

To stop the current container, focus the terminal running Docker and press:

```text
Ctrl+C
```

Because the command uses `--rm`, the stopped container is removed automatically. The downloaded image remains available locally.

To restart, run the PowerShell command from section 5 again.

## 11. Common Problems

### `docker` is not recognized

Open a new PowerShell window after installing Docker Desktop. If necessary, use the full executable path temporarily:

```powershell
& "$env:ProgramFiles\Docker\Docker\resources\bin\docker.exe" version
```

### Docker engine is unavailable

Start Docker Desktop and wait until it reports that the engine is running. Confirm both the Client and Server sections with:

```powershell
docker version
```

### WSL is missing

Run this from an Administrator PowerShell window:

```powershell
wsl --install
```

Restart Windows, then start Docker Desktop again.

### JupyterLab starts but Spark UI does not

Select the `pyspark4` kernel and run a Spark action such as:

```python
spark.range(10).count()
```

Then refresh `http://localhost:8889`.

### The image pull reports a credential-helper error

Close the old PowerShell window and open a new one. Confirm that Docker Desktop is running, then retry the pull:

```powershell
docker pull minus1by12/sanatan:spark-lakehouse-driver-4.2.0-gravitino-1.3.0
```

### Jupyter reports that `jupyter_server_terminals` or `terminado` is missing

This is an optional Jupyter terminal extension warning from the image. It does not prevent notebooks or Spark from running. Use a local PowerShell or WSL terminal for shell commands.

## 12. Security Note

The command disables Jupyter's XSRF protection to support this isolated local learning setup:

```text
--ServerApp.disable_check_xsrf=True
```

Do not expose port 8888 or this Jupyter server to an untrusted network. Use it only on the local machine unless the security configuration is changed.
