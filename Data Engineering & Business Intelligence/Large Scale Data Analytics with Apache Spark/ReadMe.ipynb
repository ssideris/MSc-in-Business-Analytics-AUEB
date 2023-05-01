{
 "cells": [
  {
   "cell_type": "markdown",
   "id": "e7db437b",
   "metadata": {},
   "source": [
    "**Background**\n",
    "\n",
    "You have been hired by a small bookstore company that wants to use data science techniques to optimize their sales. It has been assigned to you to analyse a dataset of books metadata using Apache Spark (and PySpark, in particular) to reveal useful insights.\n",
    "\n",
    "**Contents**\n",
    "- [Task 1](#task1)\n",
    "- [Task 2](#task2)\n",
    "- [Task 3](#task3)\n",
    "\n",
    "**Task 1** <a class=\"anchor\" id=\"task1\"></a>\n",
    "\n",
    "Your first task is to explore the dataset. You need to use SparkSQL with Dataframes in a Jupyter notebook that delivers the following:\n",
    "- It uses the json() function to load the dataset.\n",
    "- It counts and displays the number of books in the database.\n",
    "- It counts and displays the number of e-books in the database (based on the “is_ebook” field).\n",
    "- It uses the summary() command to display basic statistics about the “average_rating” field.\n",
    "- It uses the groupby() and count() commands to display all distinct values in the “format” field and their number of appearances"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "998205d9",
   "metadata": {},
   "source": [
    "##### We first create a sparkSession. It is responsible to create a sparkContext object that will help us communicate with Spark. As it will need the credentials of our application it also creates a SparkConf object that includes our application name and the location it will run."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "78286c9b",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.sql import SparkSession\n",
    "appName = \"task1\" #determine the name of the App\n",
    "master = \"local\" #determine it will run locally\n",
    "spark = SparkSession.builder.appName(appName).master(master).getOrCreate()"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "594e6e96",
   "metadata": {},
   "source": [
    "##### We read the json file and print its schema"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "e236d54a",
   "metadata": {},
   "outputs": [],
   "source": [
    "json_path = \"books_5000.json\"\n",
    "df = spark.read.json(json_path)\n",
    "df.printSchema()\n",
    "df.show(3)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "bb3c40f8",
   "metadata": {},
   "source": [
    "##### Count the number of distinct rows and so the number of books as each row refers to a book. The total number of books is 4999."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "cd3f6025",
   "metadata": {},
   "outputs": [],
   "source": [
    "df.distinct().count()"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "d405593f",
   "metadata": {},
   "source": [
    "##### Group by the column \"is_ebook\" and use count to count the number of true and false. Use collect function to keep the second row only that displays the count of true values. The number of true values and so the number of ebooks is 749."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "e1f6efa3",
   "metadata": {},
   "outputs": [],
   "source": [
    "df.groupBy(\"is_ebook\").count().collect()[1]"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "b3bfdb33",
   "metadata": {},
   "source": [
    "##### Use summary command to display basic statistics about the \"average_rating\" field."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "5410e2ea",
   "metadata": {},
   "outputs": [],
   "source": [
    "df.select(\"average_rating\").summary().show()"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "5fff0bff",
   "metadata": {},
   "source": [
    "##### Use the groupby() and count() commands to display all distinct values in the \"format\" field and their number of appearances "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "d9385b71",
   "metadata": {},
   "outputs": [],
   "source": [
    "df.groupBy(\"format\").count().show()"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f5cac7e9",
   "metadata": {},
   "source": [
    "**Task 2** <a class=\"anchor\" id=\"task2\"></a>\n",
    "\n",
    "For this task you continue to work with SparkSQL. This time, you need to provide a Jupyter notebook (again using PySpark and Dataframes) that delivers the following:\n",
    "- It returns the “book_id” and “title” of the book with the largest “average_rating” that its title starts with the first letter of your last name.\n",
    "- It returns the average “average_rating” of the books that their title starts with the *second* letter of your last name.\n",
    "- It returns the “book_id” and “title” of the Paperback book with the most pages, when only books with title starting with the *third* letter of your last name are considered. Your deliverable should be a ready-to-run Jupyter notebook (named “id-t2.ipynb”), containing your details (name, id) and explanations for each step of the code."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "02138e66",
   "metadata": {},
   "source": [
    "##### We first create a sparkSession. It is responsible to create a sparkContext object that will help us communicate with Spark. As it will need the credentials of our application it also creates a SparkConf object that includes our application name and the location it will run."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "4f9aace1",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.sql import SparkSession\n",
    "appName = \"task2\" #determine the name of the App\n",
    "master = \"local\" #determine it will run locally\n",
    "spark = SparkSession.builder.appName(appName).master(master).getOrCreate()"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "ff1e0287",
   "metadata": {},
   "source": [
    "##### We read the json file and print its schema"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "956c150c",
   "metadata": {},
   "outputs": [],
   "source": [
    "json_path = \"books_5000.json\"\n",
    "df = spark.read.json(json_path)\n",
    "df.printSchema()\n",
    "df.show(3)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "1deb8e4d",
   "metadata": {},
   "source": [
    "##### We choose to keep the columns \"book_id\", \"title\" and \"average_rating\". We filter them so that we keep only the titles that start with the letter \"S\". We sort them in descending order by the column \"average_rating\" and we choose the first row as it will be the highest rating."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "0d3d9335",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.sql.functions import desc\n",
    "df.select(df[\"book_id\"],df[\"title\"],df[\"average_rating\"]).filter(df.title.startswith(\"S\")).sort(desc(\"average_rating\")).show(1)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "e5482e0a",
   "metadata": {},
   "source": [
    "##### We filter the titles that start with \"I\". We then use mean command to find the average of the \"average_rating\" column."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "c5b0f3b4",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.sql.functions import mean\n",
    "df.filter(df.title.startswith(\"I\")).select(mean(\"average_rating\")).show()"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f9d159d1",
   "metadata": {},
   "source": [
    "##### We change the type of column \"num_pages\" to integer as it is an integer number."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "a988e71b",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.sql.types import *\n",
    "df = df.withColumn(\"num_pages\",df.num_pages.cast(IntegerType()))"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "2a48492b",
   "metadata": {},
   "source": [
    "##### We select the columns \"book_id\", \"title\", \"format\" and \"num_pages\" as they are the ones needed. We filter them for titles starting with \"D\" and their format is equal to \"Paperback\". We sort them in descending order by the number of pages and take the first row as it will be the book with the most pages."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "a5dcc19a",
   "metadata": {},
   "outputs": [],
   "source": [
    "df.select(df[\"book_id\"],df[\"title\"],df[\"format\"],df[\"num_pages\"]).filter(df.title.startswith(\"D\") & (df.format == \"Paperback\")).sort(desc(\"num_pages\")).show(1)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "2fe1f42a",
   "metadata": {},
   "source": [
    "**Task 3** <a class=\"anchor\" id=\"task3\"></a>\n",
    "\n",
    "As a final task, your supervisor assigned to you to investigate if it is possible to train a linear\n",
    "regression model (using LinearRegression() function) that could predict the “average_rating”\n",
    "of a book, using as input, its “language_code”, its “num_pages”, its “ratings_count”, and its\n",
    "“publication year”. Again you should use Python and Dataframes, this time with MLlib. You\n",
    "should pay attention to transform the string-based input features (“language_code” and\n",
    "“publication_year”) using the proper representation format, and you should explain your\n",
    "choices. Your code should (a) prepare the feature vectors, (b) prepare the training and testing\n",
    "datasets (70%-30%), (c) train the model, and (d) evaluate the accuracy of the model (based\n",
    "on the Rsquared metric) and display the corresponding metric on the screen. "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f3e02013",
   "metadata": {},
   "source": [
    "##### We first create a sparkSession. It is responsible to create a sparkContext object that will help us communicate with Spark. As it will need the credentials of our application it also creates a SparkConf object that includes our application name and the location it will run."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "67cab9d1",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.sql import SparkSession\n",
    "appName = \"task3\" #determine the name of the App\n",
    "master = \"local\" #determine it will run locally\n",
    "spark = SparkSession.builder.appName(appName).master(master).getOrCreate()"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f9556f39",
   "metadata": {},
   "source": [
    "##### We read the json file and print its schema"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "378917a0",
   "metadata": {},
   "outputs": [],
   "source": [
    "json_path = \"books_5000.json\"\n",
    "df = spark.read.json(json_path)\n",
    "df.printSchema()\n",
    "df.show(3)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "26c0d381",
   "metadata": {},
   "source": [
    "##### Variables language_code, publication_year and num_pages include 1685, 1072 and 1382 missing values we need to handle."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "721517bd",
   "metadata": {},
   "outputs": [],
   "source": [
    "[df.filter(df.language_code == \"\").count(), df.filter(df.publication_year == \"\").count(), df.filter(df.num_pages == '').count()]"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "e11100a3",
   "metadata": {},
   "source": [
    "##### To do so, we substitute the missing values with NAs for variables language_code and publication_year as we will handle as categorical moving forward, and we substitute the missing values with 0 for variable num_pages as we will handle it as numeric."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "1223cdd8",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.sql.functions import when\n",
    "df = df.withColumn(\"language_code\", when(df.language_code == \"\" ,\"NA\").otherwise(df.language_code))\n",
    "df = df.withColumn(\"publication_year\", when(df.publication_year == \"\" ,\"NA\").otherwise(df.publication_year))\n",
    "df = df.withColumn(\"num_pages\", when(df.num_pages == \"\" ,0).otherwise(df.num_pages))\n",
    "df.select(df[\"language_code\"], df[\"publication_year\"], df[\"num_pages\"]).show()"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "b7d44016",
   "metadata": {},
   "source": [
    "##### We change the variables types of ratings_count and num_pages to integer and average_rating to double as it is more appropriate."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "eb6015a1",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.sql.types import *\n",
    "df = df.withColumn(\"average_rating\",df.average_rating.cast(DoubleType()))\n",
    "df = df.withColumn(\"ratings_count\",df.ratings_count.cast(IntegerType()))\n",
    "df = df.withColumn(\"num_pages\",df.num_pages.cast(IntegerType()))"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "653e959f",
   "metadata": {},
   "source": [
    "##### We split the dataset by 80-20 to training and testing. We use cache command to the training dataset as it will be used multiple times."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "b455ee5e",
   "metadata": {},
   "outputs": [],
   "source": [
    "trainDF, testDF = df.randomSplit([0.8, 0.2], seed=42)\n",
    "print(trainDF.cache().count()) \n",
    "print(testDF.count())"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "916fdb52",
   "metadata": {},
   "source": [
    "##### As variable language_code is a categorical variable we must change it to numeric for our algorithm to understand. To do so, we will use the StringIndexer that will convert each distinct category to numeric starting by giving to the most appeared category the number 0. We will treat variable publication_year the same way as we do not pay attention to the time-series. We will then pass the new numeric variables to the OneHotEncoder in order to create dummy variables of 0 and 1 for the categories."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "2b12844b",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.ml.feature import StringIndexer, OneHotEncoder\n",
    "\n",
    "# We determine which of the columns are categorical.\n",
    "categoricalCols = [\"language_code\", \"publication_year\"]\n",
    "\n",
    "# The following two lines are estimators. They return functions that we will later apply to transform the dataset.\n",
    "stringIndexer = StringIndexer(inputCols=categoricalCols, outputCols=[x + \"Index\" for x in categoricalCols]).setHandleInvalid(\"keep\")\n",
    "encoder = OneHotEncoder(inputCols=stringIndexer.getOutputCols(), outputCols=[x + \"OHE\" for x in categoricalCols]) "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "1a4e9bb6",
   "metadata": {},
   "source": [
    "##### The algorithm we will use requires a single features column as input. We use VectorAssembler to create a single vector column from a list of the features we will use for the prediction. Our final dataset has 2 columns: features (that includes predictors) and average_rating (the variable we want to predict). "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "cb8753e2",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.ml.feature import VectorAssembler\n",
    "# This includes both the numeric columns and the one-hot encoded binary vector columns in our dataset.\n",
    "numericCols = [\"num_pages\", \"ratings_count\"]\n",
    "assemblerInputs = [c + \"OHE\" for c in categoricalCols] + numericCols\n",
    "vecAssembler = VectorAssembler(inputCols=assemblerInputs, outputCol=\"features\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "b4c642b0",
   "metadata": {},
   "source": [
    "##### Define the linear regression model"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "6d71d372",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.ml.regression import LinearRegression\n",
    "lr = LinearRegression(featuresCol=\"features\", labelCol=\"average_rating\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "8987f20b",
   "metadata": {},
   "source": [
    "##### We create a pipeline that will run all the above commands we prepared to get the train dataset ready for the training of our model. Then it will train our model. Finally, we use the trained model to make predictions using the testing dataset."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "e1de1a73",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.ml import Pipeline\n",
    "\n",
    "# Define the pipeline based on the stages created in previous steps.\n",
    "pipeline = Pipeline(stages=[stringIndexer, encoder, vecAssembler, lr])\n",
    "\n",
    "# Define the pipeline model.\n",
    "pipelineModel = pipeline.fit(trainDF)\n",
    "\n",
    "# Apply the pipeline model to the test dataset to classify the respective samples.\n",
    "predDF = pipelineModel.transform(testDF)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "e05e3089",
   "metadata": {},
   "source": [
    "##### The R2 for our model is very low meaning that our model is very bad at predicting the average rating of each book."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "c0b1a725",
   "metadata": {},
   "outputs": [],
   "source": [
    "from pyspark.ml.evaluation import RegressionEvaluator\n",
    "mcEvaluator = RegressionEvaluator(predictionCol=\"prediction\", labelCol=\"average_rating\",metricName=\"r2\")\n",
    "print(f\"R2: {mcEvaluator.evaluate(predDF)}\")"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.9.12"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
