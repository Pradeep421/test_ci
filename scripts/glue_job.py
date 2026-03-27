import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Read from S3
df = spark.read.option("header", True).csv("s3://my-glue-project-bucket-pradeep/data/input/")

# Transform
df_filtered = df.filter(df["salary"] > 3000)

# Write output
df_filtered.write.mode("overwrite").parquet("s3://my-glue-project-bucket-pradeep/data/output/")