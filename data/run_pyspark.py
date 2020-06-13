from pyspark.ml import Pipeline
import pyspark
from pyspark import SparkContext
from pyspark.ml.feature import HashingTF, IDF, Tokenizer
from pyspark.ml.feature import RegexTokenizer
from pyspark.sql.types import IntegerType
from pyspark.sql import SparkSession
from pyspark.ml.feature import StopWordsRemover
from pyspark.sql.types import IntegerType
from pyspark.sql.types import StringType
from pyspark.sql.types import ArrayType
from pyspark.sql import functions
from graphframes import *
import os
import argparse
import json
import pickle
import pandas as pd
from pyspark.sql.functions import *

conf = pyspark.SparkConf()
conf.set("spark.ui.showConsoleProgress", "true")
conf.set('spark.local.dir', '/mnt/pyspark/')
conf.set('spark.sql.shuffle.partitions', '2100')
conf.set('spark.executor.heartbeatInterval','100s')
#SparkContext.setLogLevel(logLevel="WARN")
SparkContext.setSystemProperty('spark.executor.memory', '8g')
SparkContext.setSystemProperty('spark.driver.memory', '8g')
sc = SparkContext(appName='mm_exp', conf=conf)
spark = SparkSession(sc)
sqlcontext = pyspark.sql.SQLContext(sc)
file = spark.read.text("/mnt/pyspark/Train.csv")
print("FILE READ ---------- ",file.head())
print("FILE COUNT ---------- ",file.count())
spark.sparkContext.getConf().getAll()
print("Default parallelism ",sc.defaultParallelism)

v = sqlcontext.createDataFrame([
  ("a", "Alice", 34),
  ("b", "Bob", 36),
  ("c", "Charlie", 30),
  ("d", "David", 29),
  ("e", "Esther", 32),
  ("f", "Fanny", 36),
  ("g", "Gabby", 60)
], ["id", "name", "age"])
# Edge DataFrame
e = sqlcontext.createDataFrame([
  ("a", "b", "friend"),
  ("b", "c", "follow"),
  ("c", "b", "follow"),
  ("f", "c", "follow"),
  ("e", "f", "follow"),
  ("e", "d", "friend"),
  ("d", "a", "friend"),
  ("a", "e", "friend")
], ["src", "dst", "relationship"])
# Create a GraphFrame
g = GraphFrame(v, e)
gd = g.degrees
print(gd.show())
