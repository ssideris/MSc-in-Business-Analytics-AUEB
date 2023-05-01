**Background**

You have been hired by a small bookstore company that wants to use data science techniques to optimize their sales. It has been assigned to you to analyse a dataset of books metadata using Apache Spark (and PySpark, in particular) to reveal useful insights.

**Contents**
- [Task 1](#task1)
- [Task 2](#task2)
- [Task 3](#task3)

**Task 1**<a class="anchor" id="task1"></a>

Your first task is to explore the dataset. You need to use SparkSQL with Dataframes in a Jupyter notebook that delivers the following:
- It uses the json() function to load the dataset.
- It counts and displays the number of books in the database.
- It counts and displays the number of e-books in the database (based on the “is_ebook”
field).
- It uses the summary() command to display basic statistics about the “average_rating”
field.
- It uses the groupby() and count() commands to display all distinct values in the
“format” field and their number of appearances


```python
jupyter nbconvert --execute --to markdown README.ipynb
```


      Input In [12]
        jupyter nbconvert --execute --to markdown README.ipynb
                ^
    SyntaxError: invalid syntax
    


##### We first create a sparkSession. It is responsible to create a sparkContext object that will help us communicate with Spark. As it will need the credentials of our application it also creates a SparkConf object that includes our application name and the location it will run.


```python
from pyspark.sql import SparkSession
appName = "task1" #determine the name of the App
master = "local" #determine it will run locally
spark = SparkSession.builder.appName(appName).master(master).getOrCreate()
```

##### We read the json file and print its schema


```python
json_path = "books_5000.json"
df = spark.read.json(json_path)
df.printSchema()
df.show(3)
```

##### Count the number of distinct rows and so the number of books as each row refers to a book. The total number of books is 4999.


```python
df.distinct().count()
```

##### Group by the column "is_ebook" and use count to count the number of true and false. Use collect function to keep the second row only that displays the count of true values. The number of true values and so the number of ebooks is 749.


```python
df.groupBy("is_ebook").count().collect()[1]
```

##### Use summary command to display basic statistics about the "average_rating" field.


```python
df.select("average_rating").summary().show()
```

##### Use the groupby() and count() commands to display all distinct values in the "format" field and their number of appearances 


```python
df.groupBy("format").count().show()
```

**Task 2**<a class="anchor" id="task2"></a>

For this task you continue to work with SparkSQL. This time, you need to provide a Jupyter notebook (again using PySpark and Dataframes) that delivers the following:
- It returns the “book_id” and “title” of the book with the largest “average_rating” that its title starts with the first letter of your last name.
- It returns the average “average_rating” of the books that their title starts with the *second* letter of your last name.
- It returns the “book_id” and “title” of the Paperback book with the most pages, when only books with title starting with the *third* letter of your last name are considered. Your deliverable should be a ready-to-run Jupyter notebook (named “id-t2.ipynb”), containing your details (name, id) and explanations for each step of the code.

##### We first create a sparkSession. It is responsible to create a sparkContext object that will help us communicate with Spark. As it will need the credentials of our application it also creates a SparkConf object that includes our application name and the location it will run.


```python
from pyspark.sql import SparkSession
appName = "task2" #determine the name of the App
master = "local" #determine it will run locally
spark = SparkSession.builder.appName(appName).master(master).getOrCreate()
```

##### We read the json file and print its schema


```python
json_path = "books_5000.json"
df = spark.read.json(json_path)
df.printSchema()
df.show(3)
```

##### We choose to keep the columns "book_id", "title" and "average_rating". We filter them so that we keep only the titles that start with the letter "S". We sort them in descending order by the column "average_rating" and we choose the first row as it will be the highest rating.


```python
from pyspark.sql.functions import desc
df.select(df["book_id"],df["title"],df["average_rating"]).filter(df.title.startswith("S")).sort(desc("average_rating")).show(1)
```

##### We filter the titles that start with "I". We then use mean command to find the average of the "average_rating" column.


```python
from pyspark.sql.functions import mean
df.filter(df.title.startswith("I")).select(mean("average_rating")).show()
```

##### We change the type of column "num_pages" to integer as it is an integer number.


```python
from pyspark.sql.types import *
df = df.withColumn("num_pages",df.num_pages.cast(IntegerType()))
```

##### We select the columns "book_id", "title", "format" and "num_pages" as they are the ones needed. We filter them for titles starting with "D" and their format is equal to "Paperback". We sort them in descending order by the number of pages and take the first row as it will be the book with the most pages.


```python
df.select(df["book_id"],df["title"],df["format"],df["num_pages"]).filter(df.title.startswith("D") & (df.format == "Paperback")).sort(desc("num_pages")).show(1)
```

**Task 3**<a class="anchor" id="task3"></a>

As a final task, your supervisor assigned to you to investigate if it is possible to train a linear
regression model (using LinearRegression() function) that could predict the “average_rating”
of a book, using as input, its “language_code”, its “num_pages”, its “ratings_count”, and its
“publication year”. Again you should use Python and Dataframes, this time with MLlib. You
should pay attention to transform the string-based input features (“language_code” and
“publication_year”) using the proper representation format, and you should explain your
choices. Your code should (a) prepare the feature vectors, (b) prepare the training and testing
datasets (70%-30%), (c) train the model, and (d) evaluate the accuracy of the model (based
on the Rsquared metric) and display the corresponding metric on the screen. 

##### We first create a sparkSession. It is responsible to create a sparkContext object that will help us communicate with Spark. As it will need the credentials of our application it also creates a SparkConf object that includes our application name and the location it will run.


```python
from pyspark.sql import SparkSession
appName = "task3" #determine the name of the App
master = "local" #determine it will run locally
spark = SparkSession.builder.appName(appName).master(master).getOrCreate()
```

##### We read the json file and print its schema


```python
json_path = "books_5000.json"
df = spark.read.json(json_path)
df.printSchema()
df.show(3)
```

##### Variables language_code, publication_year and num_pages include 1685, 1072 and 1382 missing values we need to handle.


```python
[df.filter(df.language_code == "").count(), df.filter(df.publication_year == "").count(), df.filter(df.num_pages == '').count()]
```

##### To do so, we substitute the missing values with NAs for variables language_code and publication_year as we will handle as categorical moving forward, and we substitute the missing values with 0 for variable num_pages as we will handle it as numeric.


```python
from pyspark.sql.functions import when
df = df.withColumn("language_code", when(df.language_code == "" ,"NA").otherwise(df.language_code))
df = df.withColumn("publication_year", when(df.publication_year == "" ,"NA").otherwise(df.publication_year))
df = df.withColumn("num_pages", when(df.num_pages == "" ,0).otherwise(df.num_pages))
df.select(df["language_code"], df["publication_year"], df["num_pages"]).show()
```

##### We change the variables types of ratings_count and num_pages to integer and average_rating to double as it is more appropriate.


```python
from pyspark.sql.types import *
df = df.withColumn("average_rating",df.average_rating.cast(DoubleType()))
df = df.withColumn("ratings_count",df.ratings_count.cast(IntegerType()))
df = df.withColumn("num_pages",df.num_pages.cast(IntegerType()))
```

##### We split the dataset by 80-20 to training and testing. We use cache command to the training dataset as it will be used multiple times.


```python
trainDF, testDF = df.randomSplit([0.8, 0.2], seed=42)
print(trainDF.cache().count()) 
print(testDF.count())
```

##### As variable language_code is a categorical variable we must change it to numeric for our algorithm to understand. To do so, we will use the StringIndexer that will convert each distinct category to numeric starting by giving to the most appeared category the number 0. We will treat variable publication_year the same way as we do not pay attention to the time-series. We will then pass the new numeric variables to the OneHotEncoder in order to create dummy variables of 0 and 1 for the categories.


```python
from pyspark.ml.feature import StringIndexer, OneHotEncoder

# We determine which of the columns are categorical.
categoricalCols = ["language_code", "publication_year"]

# The following two lines are estimators. They return functions that we will later apply to transform the dataset.
stringIndexer = StringIndexer(inputCols=categoricalCols, outputCols=[x + "Index" for x in categoricalCols]).setHandleInvalid("keep")
encoder = OneHotEncoder(inputCols=stringIndexer.getOutputCols(), outputCols=[x + "OHE" for x in categoricalCols]) 
```

##### The algorithm we will use requires a single features column as input. We use VectorAssembler to create a single vector column from a list of the features we will use for the prediction. Our final dataset has 2 columns: features (that includes predictors) and average_rating (the variable we want to predict). 


```python
from pyspark.ml.feature import VectorAssembler
# This includes both the numeric columns and the one-hot encoded binary vector columns in our dataset.
numericCols = ["num_pages", "ratings_count"]
assemblerInputs = [c + "OHE" for c in categoricalCols] + numericCols
vecAssembler = VectorAssembler(inputCols=assemblerInputs, outputCol="features")
```

##### Define the linear regression model


```python
from pyspark.ml.regression import LinearRegression
lr = LinearRegression(featuresCol="features", labelCol="average_rating")
```

##### We create a pipeline that will run all the above commands we prepared to get the train dataset ready for the training of our model. Then it will train our model. Finally, we use the trained model to make predictions using the testing dataset.


```python
from pyspark.ml import Pipeline

# Define the pipeline based on the stages created in previous steps.
pipeline = Pipeline(stages=[stringIndexer, encoder, vecAssembler, lr])

# Define the pipeline model.
pipelineModel = pipeline.fit(trainDF)

# Apply the pipeline model to the test dataset to classify the respective samples.
predDF = pipelineModel.transform(testDF)
```

##### The R2 for our model is very low meaning that our model is very bad at predicting the average rating of each book.


```python
from pyspark.ml.evaluation import RegressionEvaluator
mcEvaluator = RegressionEvaluator(predictionCol="prediction", labelCol="average_rating",metricName="r2")
print(f"R2: {mcEvaluator.evaluate(predDF)}")
```
