"""
pyspark_startup.py

IPython startup script for the "S.A.N.A.T.A.N Spark Python" kernel — loaded
via kernel.json's `--IPKernelApp.exec_files=[...]`, so it runs once before
the first cell and its module-level names land in the notebook's global
namespace. Mirrors the Scala predef: exposes `spark`, `sc`, `sql`.

Deliberately does NOT rely on a pip-installed `pyspark` package — that would
ship its own bundled Spark distribution (and its own *unpatched*, Guava-
conflicting Scala/Spark jars), silently reintroducing the exact bug this
whole project exists to fix. Instead we point sys.path at the already-patched
$SPARK_HOME/python, so `import pyspark` resolves to the one true Spark
install this image was built around.
"""

import logging
import os
import sys


def _wire_pyspark_path() -> None:
    spark_home = os.environ.get("SPARK_HOME", "/opt/spark")
    py4j_lib_dir = os.path.join(spark_home, "python", "lib")

    if os.path.isdir(py4j_lib_dir):
        py4j_zips = sorted(f for f in os.listdir(py4j_lib_dir) if f.startswith("py4j"))
        if py4j_zips:
            sys.path.insert(0, os.path.join(py4j_lib_dir, py4j_zips[-1]))
        else:
            print(f"[sanatan-pyspark] WARNING: no py4j-*.zip found under {py4j_lib_dir}", file=sys.stderr)
    else:
        print(f"[sanatan-pyspark] WARNING: {py4j_lib_dir} does not exist — is SPARK_HOME correct?", file=sys.stderr)

    sys.path.insert(0, os.path.join(spark_home, "python"))


_wire_pyspark_path()

from pyspark.sql import SparkSession  # noqa: E402  (must follow path wiring above)

logging.getLogger("py4j").setLevel(logging.WARNING)

spark = (
    SparkSession.builder
    .master(os.environ.get("SPARK_MASTER", "local[*]"))
    .appName(os.environ.get("SPARK_APP_NAME", "SANATAN-Python-Notebook"))
    .config("spark.sql.warehouse.dir", os.environ.get("SPARK_WAREHOUSE_DIR", "/tmp/spark-warehouse"))
    .config("spark.ui.enabled", os.environ.get("SPARK_UI_ENABLED", "true")).config(
        "spark.ui.port",
        os.environ.get("SPARK_UI_PORT", "4040")
    )
    .getOrCreate()
)

sc = spark.sparkContext
sql = spark.sql

print(
    f"Spark session ready (v{spark.version})\n"
    f"  spark  -> SparkSession\n"
    f"  sc     -> SparkContext\n"
    f"  sql(_) -> spark.sql shortcut, e.g. sql('select 1').show()\n"
)
