import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv, ['input_path', 'output_path'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Read raw data
df = spark.read.option("header", True).csv(args['input_path'])

# Basic cleaning
df_clean = df.dropDuplicates()

# Write bronze layer
df_clean.write.mode("overwrite").parquet(args['output_path'])