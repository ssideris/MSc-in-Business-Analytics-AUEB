### Introduction

The goal of this assignment is to implement a simple workflow that will assess the similarity between bank customers and suggest for any input customer a list of his/her 10 most similar other customers. Moreover, you will be using these results to predict
the rating of the customer to the bank. To calculate the similarity between customers you will first have to compute the dissimilarity for every given attribute as discussed in lecture “Measuring Data Similarity”. In order to fulfill this assignment, you will have to perform the following tasks:

1) Import and pre-process the dataset with customers

Download the bank.csv dataset from moodle. This dataset is related with direct marketing campaigns of a Portuguese banking institution. The marketing campaigns were based on phone calls to access the opinion of the customer to the bank service
and products. The dataset includes 43191 bank customer profiles with 10 attributes each. Below is a description of the available attributes:

Age: The age of the customer.
Job: type of job (admin, unknown, unemployed, management, housemaid,
entrepreneur, student, blue-collar, self-employed, retired, technician, services).
Marital Status: Married, Single, Divorced.
Education: Primary, Secondary, Tertiary.
Default: If the customer has credit in default (yes/no).
Balance: average yearly balance, in euros.
Housing: if the customer has a housing loan (yes/no).
Loan: if the customer has a personal loan (yes/no)
Customer Rating: The rating of the bank from the customer (Poor, Fair, Good, Very
Good, Excellent).
Products: An array containing the bank products (1-20) each customer has.
For any numerical values missing, you should replace them with the average value of
the attribute in the dataset (rounded to the nearest integer). The replaced average
values calculated should be reported in the pdf.

2) Compute data (dis-)similarity

To assess the similarity between the customers you could form the dissimilarity matrix for all given attributes. As described in lecture “Measuring Data Similarity”, for every given attribute you first distinguish its type (categorical, ordinal, numerical or set) and then compute the dissimilarity of its values accordingly. For set similarity use the Jaccard similarity between sets. Then, you can calculate the average of the computed dissimilarities to derive the dissimilarity over all attributes. Depending on the machine used to implement this assignment you should decide whether it is feasible to compute the dissimilarity matrices, or, have the computations performed on-the-fly for a pair of customers.

3) Nearest Neighbor (NN) search

Using the implementation of the previous step, you will calculate the 10-NN (most similar) customers for the customers with ids listed below (customer id=line number1): 1200, 3650, 10400, 14930, 22330, 25671, 29311, 34650, 39200, 42000 
For this task your script must take as input the customer-id and return the list of her 10 nearest neighbors (most similar), along with the corresponding similarity score.

4) Customer rating prediction

For this assignment you will implement a classification algorithm which, for a given
customer, will predict his rating (poor, fair, good, very good, excellent) for the bank.
In order to implement the classification for a given customer you need to:

    1) Calculate the similarities between the given customer and all other customers and
    compute his 10-nn (most similar) customers. IMPORTANT: In the similarity
    calculations for this step you need to exclude the customer rating attribute.
    
    2) Based only on the 10 most similar customers computed in the previous step, predict
    the customer rating rank using:
     The average rating rank of the 10 most similar customers (rounded to the
    nearest integer).
     The weighted average rating rank of the 10 most similar customers (rounded
    to the nearest integer).
    
    3) For the evaluation of your classification algorithm you will use the 50 first records
    of the bank dataset and predict the rating for them. Then, for all n=50 records
    calculate the Mean Prediction Error for both prediction methods.



### Solution

**Task 1**


```python
#import libraries
import pandas as pd
import numpy as np
```

###### Import of the .csv file and missing values management


```python
#read the csv file using read_csv command
marketing_campaign = pd.read_csv("bank.csv",  sep = ";")
marketing_campaign
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Age</th>
      <th>Job</th>
      <th>Marital</th>
      <th>Education</th>
      <th>Default</th>
      <th>Balance</th>
      <th>Housing</th>
      <th>Loan</th>
      <th>Rating</th>
      <th>Products</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>33.0</td>
      <td>entrepreneur</td>
      <td>married</td>
      <td>secondary</td>
      <td>no</td>
      <td>2</td>
      <td>yes</td>
      <td>yes</td>
      <td>poor</td>
      <td>1,3,16,17,19</td>
    </tr>
    <tr>
      <th>1</th>
      <td>35.0</td>
      <td>management</td>
      <td>married</td>
      <td>tertiary</td>
      <td>no</td>
      <td>231</td>
      <td>yes</td>
      <td>no</td>
      <td>good</td>
      <td>4,8,16</td>
    </tr>
    <tr>
      <th>2</th>
      <td>NaN</td>
      <td>management</td>
      <td>single</td>
      <td>tertiary</td>
      <td>no</td>
      <td>447</td>
      <td>yes</td>
      <td>yes</td>
      <td>fair</td>
      <td>7,16</td>
    </tr>
    <tr>
      <th>3</th>
      <td>42.0</td>
      <td>entrepreneur</td>
      <td>divorced</td>
      <td>tertiary</td>
      <td>yes</td>
      <td>2</td>
      <td>yes</td>
      <td>no</td>
      <td>fair</td>
      <td>1,3,8,10,11,12,18,19</td>
    </tr>
    <tr>
      <th>4</th>
      <td>58.0</td>
      <td>retired</td>
      <td>married</td>
      <td>primary</td>
      <td>no</td>
      <td>121</td>
      <td>yes</td>
      <td>no</td>
      <td>good</td>
      <td>4,5,6,7,11,18,19</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>43186</th>
      <td>51.0</td>
      <td>technician</td>
      <td>married</td>
      <td>tertiary</td>
      <td>no</td>
      <td>825</td>
      <td>no</td>
      <td>no</td>
      <td>very_good</td>
      <td>12,15</td>
    </tr>
    <tr>
      <th>43187</th>
      <td>71.0</td>
      <td>retired</td>
      <td>divorced</td>
      <td>primary</td>
      <td>no</td>
      <td>1729</td>
      <td>no</td>
      <td>no</td>
      <td>very_good</td>
      <td>4,17,19</td>
    </tr>
    <tr>
      <th>43188</th>
      <td>72.0</td>
      <td>retired</td>
      <td>married</td>
      <td>secondary</td>
      <td>no</td>
      <td>5715</td>
      <td>no</td>
      <td>no</td>
      <td>very_good</td>
      <td>5,7,8,9,10,11,13,16,17,18</td>
    </tr>
    <tr>
      <th>43189</th>
      <td>57.0</td>
      <td>blue-collar</td>
      <td>married</td>
      <td>secondary</td>
      <td>no</td>
      <td>668</td>
      <td>no</td>
      <td>no</td>
      <td>very_good</td>
      <td>2,3,7</td>
    </tr>
    <tr>
      <th>43190</th>
      <td>37.0</td>
      <td>entrepreneur</td>
      <td>married</td>
      <td>secondary</td>
      <td>no</td>
      <td>2971</td>
      <td>no</td>
      <td>no</td>
      <td>very_good</td>
      <td>3,6,7,9,12,15,18</td>
    </tr>
  </tbody>
</table>
<p>43191 rows × 10 columns</p>
</div>




```python
#view the top 5 observations using the head function
marketing_campaign.head(5)
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Age</th>
      <th>Job</th>
      <th>Marital</th>
      <th>Education</th>
      <th>Default</th>
      <th>Balance</th>
      <th>Housing</th>
      <th>Loan</th>
      <th>Rating</th>
      <th>Products</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>33.0</td>
      <td>entrepreneur</td>
      <td>married</td>
      <td>secondary</td>
      <td>no</td>
      <td>2</td>
      <td>yes</td>
      <td>yes</td>
      <td>poor</td>
      <td>1,3,16,17,19</td>
    </tr>
    <tr>
      <th>1</th>
      <td>35.0</td>
      <td>management</td>
      <td>married</td>
      <td>tertiary</td>
      <td>no</td>
      <td>231</td>
      <td>yes</td>
      <td>no</td>
      <td>good</td>
      <td>4,8,16</td>
    </tr>
    <tr>
      <th>2</th>
      <td>NaN</td>
      <td>management</td>
      <td>single</td>
      <td>tertiary</td>
      <td>no</td>
      <td>447</td>
      <td>yes</td>
      <td>yes</td>
      <td>fair</td>
      <td>7,16</td>
    </tr>
    <tr>
      <th>3</th>
      <td>42.0</td>
      <td>entrepreneur</td>
      <td>divorced</td>
      <td>tertiary</td>
      <td>yes</td>
      <td>2</td>
      <td>yes</td>
      <td>no</td>
      <td>fair</td>
      <td>1,3,8,10,11,12,18,19</td>
    </tr>
    <tr>
      <th>4</th>
      <td>58.0</td>
      <td>retired</td>
      <td>married</td>
      <td>primary</td>
      <td>no</td>
      <td>121</td>
      <td>yes</td>
      <td>no</td>
      <td>good</td>
      <td>4,5,6,7,11,18,19</td>
    </tr>
  </tbody>
</table>
</div>




```python
#identify the datatypes of each column
marketing_campaign.dtypes
```




    Age          float64
    Job           object
    Marital       object
    Education     object
    Default       object
    Balance        int64
    Housing       object
    Loan          object
    Rating        object
    Products      object
    dtype: object



###### There are missing values in the age and the balance variables.


```python
#calculation of the average age
average_age = round(np.mean(marketing_campaign["Age"]),0)
average_age
```




    41.0




```python
#calculation of the average balance
average_balance = round(np.mean(marketing_campaign["Balance"]),0)
average_balance
```




    1354.0




```python
#replace of the missing values in the balance variable with the average balance
marketing_campaign.loc[np.isnan(marketing_campaign.Balance), 'Balance'] = average_balance

print("The Age variable has",sum(np.isnan(marketing_campaign.Age)), "missing values")
print("The Balance variable has",sum(np.isnan(marketing_campaign.Balance)), "missing values")
```

    The Age variable has 1000 missing values
    The Balance variable has 0 missing values
    


```python
#update the data type of age from float to integer
marketing_campaign['Age'] = marketing_campaign['Age'].astype(np.int64)

#check if the data type conversion was succesful
marketing_campaign.dtypes
```


```python
marketing_campaign.head(5)
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Age</th>
      <th>Job</th>
      <th>Marital</th>
      <th>Education</th>
      <th>Default</th>
      <th>Balance</th>
      <th>Housing</th>
      <th>Loan</th>
      <th>Rating</th>
      <th>Products</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>33.0</td>
      <td>entrepreneur</td>
      <td>married</td>
      <td>secondary</td>
      <td>no</td>
      <td>2</td>
      <td>yes</td>
      <td>yes</td>
      <td>poor</td>
      <td>1,3,16,17,19</td>
    </tr>
    <tr>
      <th>1</th>
      <td>35.0</td>
      <td>management</td>
      <td>married</td>
      <td>tertiary</td>
      <td>no</td>
      <td>231</td>
      <td>yes</td>
      <td>no</td>
      <td>good</td>
      <td>4,8,16</td>
    </tr>
    <tr>
      <th>2</th>
      <td>NaN</td>
      <td>management</td>
      <td>single</td>
      <td>tertiary</td>
      <td>no</td>
      <td>447</td>
      <td>yes</td>
      <td>yes</td>
      <td>fair</td>
      <td>7,16</td>
    </tr>
    <tr>
      <th>3</th>
      <td>42.0</td>
      <td>entrepreneur</td>
      <td>divorced</td>
      <td>tertiary</td>
      <td>yes</td>
      <td>2</td>
      <td>yes</td>
      <td>no</td>
      <td>fair</td>
      <td>1,3,8,10,11,12,18,19</td>
    </tr>
    <tr>
      <th>4</th>
      <td>58.0</td>
      <td>retired</td>
      <td>married</td>
      <td>primary</td>
      <td>no</td>
      <td>121</td>
      <td>yes</td>
      <td>no</td>
      <td>good</td>
      <td>4,5,6,7,11,18,19</td>
    </tr>
  </tbody>
</table>
</div>



**Task 2**

###### Calculation of dissimilarity between customers in the dataset


```python
import itertools

#define jaccard similarity (size of intersection over size of union)
def jaccard_sim(list1, list2):
    intersection = len(list(set(list1).intersection(list2)))
    union = (len(list1) + len(list2)) - intersection
    return float(intersection) / union

#update the products column into lists of products
marketing_campaign.iloc[:,9] = marketing_campaign.iloc[:,9].str.split(',')
marketing_campaign.head(5)
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Age</th>
      <th>Job</th>
      <th>Marital</th>
      <th>Education</th>
      <th>Default</th>
      <th>Balance</th>
      <th>Housing</th>
      <th>Loan</th>
      <th>Rating</th>
      <th>Products</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>33.0</td>
      <td>entrepreneur</td>
      <td>married</td>
      <td>secondary</td>
      <td>no</td>
      <td>2</td>
      <td>yes</td>
      <td>yes</td>
      <td>poor</td>
      <td>[1, 3, 16, 17, 19]</td>
    </tr>
    <tr>
      <th>1</th>
      <td>35.0</td>
      <td>management</td>
      <td>married</td>
      <td>tertiary</td>
      <td>no</td>
      <td>231</td>
      <td>yes</td>
      <td>no</td>
      <td>good</td>
      <td>[4, 8, 16]</td>
    </tr>
    <tr>
      <th>2</th>
      <td>NaN</td>
      <td>management</td>
      <td>single</td>
      <td>tertiary</td>
      <td>no</td>
      <td>447</td>
      <td>yes</td>
      <td>yes</td>
      <td>fair</td>
      <td>[7, 16]</td>
    </tr>
    <tr>
      <th>3</th>
      <td>42.0</td>
      <td>entrepreneur</td>
      <td>divorced</td>
      <td>tertiary</td>
      <td>yes</td>
      <td>2</td>
      <td>yes</td>
      <td>no</td>
      <td>fair</td>
      <td>[1, 3, 8, 10, 11, 12, 18, 19]</td>
    </tr>
    <tr>
      <th>4</th>
      <td>58.0</td>
      <td>retired</td>
      <td>married</td>
      <td>primary</td>
      <td>no</td>
      <td>121</td>
      <td>yes</td>
      <td>no</td>
      <td>good</td>
      <td>[4, 5, 6, 7, 11, 18, 19]</td>
    </tr>
  </tbody>
</table>
</div>




```python
educ_mapping = {
    'secondary' : 1, 
    'tertiary' : 2,
    'primary' : 3, 
}

# If no mapping provided, return x
f = lambda x: educ_mapping.get(x, x) 
#update the values of education with their corresponding numeric value
marketing_sim = marketing_campaign
marketing_sim.loc[:, 'Education'] = marketing_sim.loc[:, 'Education'].map(f)

rating_mapping = {
    'poor' : 1, 
    'good' : 2,
    'fair' : 3, 
    'very_good':4,
    'excelent':5
}

# If no mapping provided, return x
f2 = lambda x: rating_mapping.get(x, x) 
#update the values of education with their corresponding numeric value
marketing_sim.loc[:, 'Rating'] = marketing_sim.loc[:, 'Rating'].map(f2)
```

    C:\Users\sgsid\AppData\Local\Temp\ipykernel_4040\1338994491.py:11: DeprecationWarning: In a future version, `df.iloc[:, i] = newvals` will attempt to set the values inplace instead of always setting a new array. To retain the old behavior, use either `df[df.columns[i]] = newvals` or, if columns are non-unique, `df.isetitem(i, newvals)`
      marketing_sim.loc[:, 'Education'] = marketing_sim.loc[:, 'Education'].map(f)
    C:\Users\sgsid\AppData\Local\Temp\ipykernel_4040\1338994491.py:24: DeprecationWarning: In a future version, `df.iloc[:, i] = newvals` will attempt to set the values inplace instead of always setting a new array. To retain the old behavior, use either `df[df.columns[i]] = newvals` or, if columns are non-unique, `df.isetitem(i, newvals)`
      marketing_sim.loc[:, 'Rating'] = marketing_sim.loc[:, 'Rating'].map(f2)
    


```python
#estimate the number of observations in the dataset
n = len(marketing_campaign)

#empty dissimilarity matrix
cust_dissimilarity = [[0.0 for x in range(0,n+1)] for y in range(0,n+1)]
age_range = max(marketing_sim.Age) - min(marketing_sim.Age)
balance_range = max(marketing_sim.Balance) - min(marketing_sim.Balance)
education_range = max(marketing_sim.Education) - min(marketing_sim.Education)
rating_range = max(marketing_sim.Rating) - min(marketing_sim.Rating)
def similarity_estimation(campaign, customer_index=None):
    best = {}
    #if no specific customer is given, a dissimilarity matrix will be formed
    if customer_index==None:
        for i in range(0,n):
            for j in range(i+1,n):
                #calculating the age dissimilarity - numerical
                age_dis = (abs(campaign.iloc[i,0] - campaign.iloc[j,0]))/age_range

                #calculating the balance dissimilarity - numerical
                balance_dis = (abs(campaign.iloc[i,5] - campaign.iloc[j,5]))/balance_range

                #calculating the job dissmilarity - nominal (categorical)
                if campaign.iloc[i,1] == campaign.iloc[j,1]:
                    job_dis = 0
                else:
                    job_dis = 1

                #calculating the marital status dissmilarity - nominal (categorical)
                if campaign.iloc[i,2] == campaign.iloc[j,2]:
                    marital_dis = 0
                else:
                    marital_dis = 1

                #calculating the loan default index dissmilarity - nominal (binary - categorical)
                if campaign.iloc[i,4] == campaign.iloc[j,4]:
                    default_dis = 0
                else:
                    default_dis = 1

                #calculating the housing loan index dissmilarity - nominal (binary - categorical)
                if campaign.iloc[i,6] == campaign.iloc[j,6]:
                    housing_dis = 0
                else:
                    housing_dis = 1

                #calculating the personal loan index dissmilarity - nominal (binary - categorical)
                if campaign.iloc[i,7] == campaign.iloc[j,7]:
                    loan_dis = 0
                else:
                    loan_dis = 1

                #calculating the education dissmilarity - oridnal
                educ_dis = abs(campaign.iloc[i,3] - campaign.iloc[j,3])/education_range

                #calculating the rating dissmilarity - oridnal
                rating_dis = abs(campaign.iloc[i,8] - campaign.iloc[j,8])/rating_range

                #calculating the jaccard dissmilarity of the products - sets of products
                products_dis =  1 - jaccard_sim(campaign.iloc[i,9], campaign.iloc[j,9])

                #calculating the customers dissimilarity and assigning it in the dissimilarity matrix
                cust_dissimilarity[i][j] = (age_dis + balance_dis + job_dis + marital_dis + default_dis + housing_dis \
                                                  + loan_dis + educ_dis + rating_dis + products_dis)/10
    #if a specific customer is given, his 10 nearest customers will be identified along with their similarity scores
    #(similarity)
    else:
        i = customer_index
        sp_cust_similarity = None
        for j in range(0,n):
            if i==j:
                continue
            else:
                #calculating the age similarity - numerical
                age_sim = 1 - (abs(campaign.iloc[i,0] - campaign.iloc[j,0]))/age_range

                #calculating the balance similarity - numerical
                balance_sim = 1 - (abs(campaign.iloc[i,5] - campaign.iloc[j,5]))/balance_range

                #calculating the job similarity - nominal (categorical)
                if campaign.iloc[i,1] == campaign.iloc[j,1]:
                    job_sim = 1
                else:
                    job_sim = 0
                    
                #calculating the marital status similarity - nominal (categorical)
                if campaign.iloc[i,2] == campaign.iloc[j,2]:
                    marital_sim = 1
                else:
                    marital_sim = 0

                #calculating the loan default index similarity - nominal (binary - categorical)
                if campaign.iloc[i,4] == campaign.iloc[j,4]:
                    default_sim = 1
                else:
                    default_sim = 0

                #calculating the housing loan index similarity - nominal (binary - categorical)
                if campaign.iloc[i,6] == campaign.iloc[j,6]:
                    housing_sim = 1
                else:
                    housing_sim = 0

                #calculating the personal loan index similarity - nominal (binary - categorical)
                if campaign.iloc[i,7] == campaign.iloc[j,7]:
                    loan_sim = 1
                else:
                    loan_sim = 0

                #calculating the education similarity - oridnal
                educ_sim = 1 - abs(campaign.iloc[i,3] - campaign.iloc[j,3])/education_range

                #calculating the rating similarity - oridnal
                rating_sim = 1 - abs(campaign.iloc[i,8] - campaign.iloc[j,8])/rating_range

                #calculating the jaccard similarity of the products - sets of products
                products_sim = jaccard_sim(campaign.iloc[i,9], campaign.iloc[j,9])

                #calculating the customers similarity and assigning it in the dissimilarity matrix
                sp_cust_similarity = (age_sim + balance_sim + job_sim + marital_sim + default_sim + housing_sim \
                                                  + loan_sim + educ_sim + rating_sim + products_sim)/10
                if j <= 9:
                    best[j] = sp_cust_similarity
                else:
                    if sp_cust_similarity > min(best.values()):
                        min_key = min(best, key=best.get)
                        del best[min_key]
                        best[j] = sp_cust_similarity
        best = {k: v for k, v in sorted(best.items(), key=lambda item: item[1])} 
        return best
```


```python
def printing_fun(cust_set, customer_index):
    print('─' * 39)
    print("| 10 Nearest Neighbors for Customer",customer_index, "|")
    print('─' * 39)
    print("|  Customer ID", " "*1, "|", " "*1,"Similarity Score |")
    print('─' * 39)
    # print each data item.
    for key, value in cust_set.items():
        print("|      ",key,"     ","|"\
              , "       ", round(value,2), "      |")
    print('─' * 39)
```

**Task 3**

###### Identification of the 10 nearest neighbors for some specific customers


```python
#identification of the 10 nearest neighbors for the customer 1200
cust_index = 1200
nn_1200 = similarity_estimation(marketing_sim,cust_index)
printing_fun(nn_1200,cust_index)
```

    ───────────────────────────────────────
    | 10 Nearest Neighbors for Customer 1200 |
    ───────────────────────────────────────
    |  Customer ID   |   Similarity Score |
    ───────────────────────────────────────
    |       2       |         nan       |
    |       8       |         0.76       |
    |       9       |         nan       |
    |       15       |         0.74       |
    |       22       |         0.74       |
    |       13       |         0.77       |
    |       19       |         0.8       |
    |       14       |         0.8       |
    |       30       |         0.89       |
    |       27       |         0.9       |
    ───────────────────────────────────────
    


```python
#identification of the 10 nearest neighbors for the customer 3650
cust_index = 3650
nn_3650 = similarity_estimation(marketing_sim,cust_index)
printing_fun(nn_3650,cust_index)
```

    ───────────────────────────────────────
    | 10 Nearest Neighbors for Customer 3650 |
    ───────────────────────────────────────
    |  Customer ID   |   Similarity Score |
    ───────────────────────────────────────
    |       0       |         nan       |
    |       1       |         nan       |
    |       2       |         nan       |
    |       3       |         nan       |
    |       4       |         nan       |
    |       5       |         nan       |
    |       6       |         nan       |
    |       7       |         nan       |
    |       8       |         nan       |
    |       9       |         nan       |
    ───────────────────────────────────────
    


```python
#identification of the 10 nearest neighbors for the customer 10400
cust_index = 10400
nn_10400 = similarity_estimation(marketing_sim,cust_index)
printing_fun(nn_10400,cust_index)
```

    ───────────────────────────────────────
    | 10 Nearest Neighbors for Customer 10400 |
    ───────────────────────────────────────
    |  Customer ID   |   Similarity Score |
    ───────────────────────────────────────
    |       2       |         nan       |
    |       8       |         0.65       |
    |       9       |         nan       |
    |       22       |         0.61       |
    |       28       |         0.63       |
    |       24       |         0.63       |
    |       27       |         0.65       |
    |       19       |         0.65       |
    |       13       |         0.66       |
    |       30       |         0.66       |
    ───────────────────────────────────────
    


```python
#identification of the 10 nearest neighbors for the customer 14930
cust_index = 14930
nn_14930 = similarity_estimation(marketing_sim,cust_index)
printing_fun(nn_14930,cust_index)
```

    ───────────────────────────────────────
    | 10 Nearest Neighbors for Customer 14930 |
    ───────────────────────────────────────
    |  Customer ID   |   Similarity Score |
    ───────────────────────────────────────
    |       2       |         nan       |
    |       26       |         0.59       |
    |       4       |         0.62       |
    |       9       |         nan       |
    |       12       |         0.59       |
    |       31       |         0.61       |
    |       10       |         0.62       |
    |       47       |         0.63       |
    |       18       |         0.69       |
    |       24       |         0.7       |
    ───────────────────────────────────────
    


```python
#identification of the 10 nearest neighbors for the customer 22330
cust_index = 22330
nn_22330 = similarity_estimation(marketing_sim,cust_index)
printing_fun(nn_22330,cust_index)
```

    ───────────────────────────────────────
    | 10 Nearest Neighbors for Customer 22330 |
    ───────────────────────────────────────
    |  Customer ID   |   Similarity Score |
    ───────────────────────────────────────
    |       2       |         nan       |
    |       9       |         nan       |
    |       15       |         0.76       |
    |       54       |         0.76       |
    |       73       |         0.77       |
    |       97       |         0.77       |
    |       25       |         0.77       |
    |       87       |         0.77       |
    |       61       |         0.79       |
    |       83       |         0.86       |
    ───────────────────────────────────────
    


```python
#identification of the 10 nearest neighbors for the customer 25671
cust_index = 25671
nn_25671 = similarity_estimation(marketing_sim,cust_index)
printing_fun(nn_25671,cust_index)
```

    ───────────────────────────────────────
    | 10 Nearest Neighbors for Customer 25671 |
    ───────────────────────────────────────
    |  Customer ID   |   Similarity Score |
    ───────────────────────────────────────
    |       2       |         nan       |
    |       8       |         0.65       |
    |       9       |         nan       |
    |       24       |         0.64       |
    |       28       |         0.64       |
    |       27       |         0.64       |
    |       13       |         0.65       |
    |       19       |         0.66       |
    |       30       |         0.66       |
    |       31       |         0.74       |
    ───────────────────────────────────────
    


```python
#identification of the 10 nearest neighbors for the customer 29311
cust_index = 29311
nn_29311 = similarity_estimation(marketing_sim,cust_index)
printing_fun(nn_29311,cust_index)
```

    ───────────────────────────────────────
    | 10 Nearest Neighbors for Customer 29311 |
    ───────────────────────────────────────
    |  Customer ID   |   Similarity Score |
    ───────────────────────────────────────
    |       2       |         nan       |
    |       22       |         0.71       |
    |       25       |         0.71       |
    |       33       |         0.72       |
    |       37       |         0.73       |
    |       7       |         0.74       |
    |       5       |         0.76       |
    |       9       |         nan       |
    |       20       |         0.79       |
    |       41       |         0.79       |
    ───────────────────────────────────────
    


```python
#identification of the 10 nearest neighbors for the customer 34650
cust_index = 34650
nn_34650 = similarity_estimation(marketing_sim,cust_index)
printing_fun(nn_34650,cust_index)
```

    ───────────────────────────────────────
    | 10 Nearest Neighbors for Customer 34650 |
    ───────────────────────────────────────
    |  Customer ID   |   Similarity Score |
    ───────────────────────────────────────
    |       2       |         nan       |
    |       20       |         0.63       |
    |       15       |         0.64       |
    |       16       |         0.66       |
    |       25       |         0.67       |
    |       12       |         0.69       |
    |       4       |         0.7       |
    |       6       |         0.7       |
    |       9       |         nan       |
    |       10       |         0.73       |
    ───────────────────────────────────────
    


```python
#identification of the 10 nearest neighbors for the customer 39200
cust_index = 39200
nn_39200 = similarity_estimation(marketing_sim,cust_index)
printing_fun(nn_39200,cust_index)
```

    ───────────────────────────────────────
    | 10 Nearest Neighbors for Customer 39200 |
    ───────────────────────────────────────
    |  Customer ID   |   Similarity Score |
    ───────────────────────────────────────
    |       2       |         nan       |
    |       15       |         0.59       |
    |       13       |         0.64       |
    |       24       |         0.64       |
    |       12       |         0.64       |
    |       4       |         0.66       |
    |       8       |         0.67       |
    |       9       |         nan       |
    |       19       |         0.66       |
    |       10       |         0.68       |
    ───────────────────────────────────────
    


```python
#identification of the 10 nearest neighbors for the customer 42000
cust_index = 42000
nn_42000 = similarity_estimation(marketing_sim,cust_index)
printing_fun(nn_42000,cust_index)
```

    ───────────────────────────────────────
    | 10 Nearest Neighbors for Customer 42000 |
    ───────────────────────────────────────
    |  Customer ID   |   Similarity Score |
    ───────────────────────────────────────
    |       2       |         nan       |
    |       43       |         0.65       |
    |       7       |         0.65       |
    |       9       |         nan       |
    |       28       |         0.66       |
    |       22       |         0.7       |
    |       44       |         0.71       |
    |       20       |         0.73       |
    |       48       |         0.73       |
    |       41       |         0.77       |
    ───────────────────────────────────────
    

**Task 4**

##### Customer rating prediction

###### Next we will attempt to predict the customer's ratings based on their nearest neighbors' rating by utilizing different methods.


```python
#estimate the number of observations in the dataset
n = len(marketing_campaign)

def rating_prediction(campaign, customer_index=None):
    best = {}
    sp_cust_similarity = None
    i=customer_index
    pred_ranks_avg = []
    for j in range(0,n):
        if i==j:
            continue
        else:
            #calculating the age similarity - numerical
            age_sim = 1 - (abs(campaign.iloc[i,0] - campaign.iloc[j,0]))/age_range

            #calculating the balance similarity - numerical
            balance_sim = 1 - (abs(campaign.iloc[i,5] - campaign.iloc[j,5]))/balance_range

            #calculating the job similarity - nominal (categorical)
            if campaign.iloc[i,1] == campaign.iloc[j,1]:
                job_sim = 1
            else:
                job_sim = 0

            #calculating the marital status similarity - nominal (categorical)
            if campaign.iloc[i,2] == campaign.iloc[j,2]:
                marital_sim = 1
            else:
                marital_sim = 0

            #calculating the loan default index similarity - nominal (binary - categorical)
            if campaign.iloc[i,4] == campaign.iloc[j,4]:
                default_sim = 1
            else:
                default_sim = 0

            #calculating the housing loan index similarity - nominal (binary - categorical)
            if campaign.iloc[i,6] == campaign.iloc[j,6]:
                housing_sim = 1
            else:
                housing_sim = 0

            #calculating the personal loan index similarity - nominal (binary - categorical)
            if campaign.iloc[i,7] == campaign.iloc[j,7]:
                loan_sim = 1
            else:
                loan_sim = 0

            #calculating the education similarity - oridnal
            educ_sim = 1 - abs(campaign.iloc[i,3] - campaign.iloc[j,3])/education_range

            #calculating the jaccard similarity of the products - sets of products
            products_sim =  jaccard_sim(campaign.iloc[i,9], campaign.iloc[j,9])

            #calculating the customers similarity and assigning it in the dissimilarity matrix
            sp_cust_similarity = (age_sim + balance_sim + job_sim + marital_sim + default_sim + housing_sim \
                                              + loan_sim + educ_sim + products_sim)/10
            if j <= 9:
                best[j] = sp_cust_similarity
            else:
                if sp_cust_similarity > min(best.values()):
                    min_key = min(best, key=best.get)
                    del best[min_key]
                    best[j] = sp_cust_similarity
    best = {k: v for k, v in sorted(best.items(), key=lambda item: item[1])} 
    
    #calculation of the average rank of a given customer given the average rank of his/her 10 nearest neighbors
    rank_sum = 0
    #for loop to find the sum of the ranks of his/her 10 nearest neighbors
    for keys in best:
        rank_sum += campaign.iloc[keys,8]
    
    #divide the sum of the neighbors' rating with the number of the nearest neighbors
    avg_rank_of_nn = round(rank_sum/len(best.keys()),0)
    
    
    #calculation of the weighted average rank of a given customer given the average rank of his/her 10 nearest neighbors
    rank_weighted_sum = 0
    similarity_sum = 0

    #for loop to find the sum of the ranks multiplied by their similarity scores of his/her 10 nearest neighbors
    for keys, values in best.items():
        rank_weighted_sum += values * campaign.iloc[keys,8]
        similarity_sum += values
    
    #divide the weighted sum of the neighbors' rating with the sum of their similarity scores
    w_avg_rank_of_nn = round(rank_weighted_sum/similarity_sum,0)
    
    
    return best, avg_rank_of_nn, w_avg_rank_of_nn
```

###### Next, we will identify the 10 nearest neighbors of the customer-100 by using the function that does not consider any customer's rating


```python
#we assign the customer's (100) index
cust_index = 100

#we find the 10 nearest neighbors of the customer along with their similarity scores
nn_100, avg_rating, w_avg_rating = rating_prediction(marketing_campaign,cust_index)
printing_fun(nn_100,cust_index)
print("The predicted rating of the customer", cust_index, "according to the average rating and the weighted average rating\
 of his her 10 nearest neighbors is equal to",avg_rating,"and", w_avg_rating, "respectively.")
```

    ───────────────────────────────────────
    | 10 Nearest Neighbors for Customer 100 |
    ───────────────────────────────────────
    |  Customer ID   |   Similarity Score |
    ───────────────────────────────────────
    |       2       |         nan       |
    |       4       |         0.62       |
    |       9       |         nan       |
    |       12       |         0.59       |
    |       21       |         0.62       |
    |       49       |         0.62       |
    |       10       |         0.64       |
    |       26       |         0.64       |
    |       38       |         0.66       |
    |       18       |         0.7       |
    ───────────────────────────────────────
    The predicted rating of the customer 100 according to the average rating and the weighted average rating of his her 10 nearest neighbors is equal to 2.0 and nan respectively.
    

###### Finally, we will try to predict the rating scores for the first 50 customers in the dataset, according to the two classification methods that consider their 10-nearest neighbors and evaluate their effectiveness by using the Mean Prediction Error metric.


```python
#we create two empty lists that contain the predicted rating scores from each classification method 
#(average, weighted average) 
list_of_predicted_rating_avg = []
list_of_predicted_rating_w_avg = []

#for loop that will iterate through the first 50 customers
for i in range(0,50):
    #we assign the results of the function in three variables
    nn_dict, avg, w_avg = rating_prediction(marketing_campaign,i)
    #we append each predicted rating to its corresponding list
    list_of_predicted_rating_avg.append(avg)
    list_of_predicted_rating_w_avg.append(w_avg)
    
#we find the true rating scores of the first 50 customers
true_ratings_of_first_50_cust = marketing_campaign.iloc[0:50,8]

#calculation of the mean prediction error for the predictions based on the average ratings of the 10-nn
mpe_score_avg = sum(abs(list_of_predicted_rating_avg- true_ratings_of_first_50_cust))/len(true_ratings_of_first_50_cust)

#calculation of the mean prediction error for the predictions based on the weighted average ratings of the 10-nn
mpe_score_w_avg = sum(abs(list_of_predicted_rating_w_avg- true_ratings_of_first_50_cust))/len(true_ratings_of_first_50_cust)

print("Mean Prediction Error for the predictions based on nn-average rating\
 is equal to", mpe_score_avg)

print("Mean Prediction Error for the predictions based on nn-weighted average rating\
 is equal to", mpe_score_w_avg)
```

    Mean Prediction Error for the predictions based on nn-average rating is equal to 0.52
    Mean Prediction Error for the predictions based on nn-weighted average rating is equal to nan
    

###### It is observed that the weighted average classification method has slightly worse predictions on the customers' ratings. In other words, the average rating score of the nearest customers is a slightly better measure to predict one's true rating. Thus, we can assume that it is a more efficient method to predict any given customer's rating based on the average rating of his/her nearest neighbors-customers. 
