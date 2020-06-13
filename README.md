
To build the base container
---------------------------

docker build -t pyspark .

This container does not have the GraphFrames packages installed. The simple hack to install it is shown below


Build container with Graphframes
--------------------------------

1. Get a bash shell inside the container with

docker run -it --rm --gpus all -v FOLDER_PATH/data/:/mnt/pyspark/ -w /mnt/pyspark/ pyspark_graphframes:latest

2. Run pyspark by specifying the packages needed which forces it to download them

pyspark --packages graphframes:graphframes:0.6.0-spark2.3-s_2.11

3. Commit the container using

docker commit CONTAINER_NAME NEW_IMAGE_NAME


To run the Docker container with Graphframes
--------------------------------------------

If the new image is named pyspark_graphframes:latest

docker run -it --rm --gpus all -v FOLDER_PATH/data/:/mnt/pyspark/ -w /mnt/pyspark/ pyspark_graphframes:latest spark-submit --packages graphframes:graphframes:0.6.0-spark2.3-s_2.11 run_pyspark.py
