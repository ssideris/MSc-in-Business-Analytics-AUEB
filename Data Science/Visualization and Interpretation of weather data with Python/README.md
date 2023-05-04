# Q1: Obtain the Data

## Description

### We will obtain our weather data from the 2866825.csv file and complement it with the athens.csv file. After changing variable types, convert some of the measure units and clean some unknown values the final dataset is ready for use.


```python
#import library pandas
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import matplotlib.colors as colors
import datetime

%matplotlib inline
```


```python
#import the 2 datasets as dataframes
data1 = pd.read_csv("2866825.csv")
data2 = pd.read_csv("athens.csv", header=None)
```


```python
#check head and tails of data1
data1
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
      <th>STATION</th>
      <th>NAME</th>
      <th>DATE</th>
      <th>PRCP</th>
      <th>SNWD</th>
      <th>TAVG</th>
      <th>TMAX</th>
      <th>TMIN</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>1/1/1955</td>
      <td>0.00</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>65.0</td>
      <td>50.0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>1/2/1955</td>
      <td>0.08</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>58.0</td>
      <td>45.0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>1/3/1955</td>
      <td>0.00</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>60.0</td>
      <td>49.0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>1/4/1955</td>
      <td>0.00</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>66.0</td>
      <td>45.0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>1/5/1955</td>
      <td>0.00</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>64.0</td>
      <td>47.0</td>
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
    </tr>
    <tr>
      <th>23246</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>12/27/2020</td>
      <td>0.00</td>
      <td>NaN</td>
      <td>62.0</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>23247</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>12/28/2020</td>
      <td>0.26</td>
      <td>NaN</td>
      <td>59.0</td>
      <td>65.0</td>
      <td>53.0</td>
    </tr>
    <tr>
      <th>23248</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>12/29/2020</td>
      <td>0.00</td>
      <td>NaN</td>
      <td>61.0</td>
      <td>68.0</td>
      <td>54.0</td>
    </tr>
    <tr>
      <th>23249</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>12/30/2020</td>
      <td>0.00</td>
      <td>NaN</td>
      <td>62.0</td>
      <td>68.0</td>
      <td>59.0</td>
    </tr>
    <tr>
      <th>23250</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>12/31/2020</td>
      <td>0.00</td>
      <td>NaN</td>
      <td>60.0</td>
      <td>65.0</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
<p>23251 rows × 8 columns</p>
</div>




```python
#check head and tails of data2
data2
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
      <th>0</th>
      <th>1</th>
      <th>2</th>
      <th>3</th>
      <th>4</th>
      <th>5</th>
      <th>6</th>
      <th>7</th>
      <th>8</th>
      <th>9</th>
      <th>10</th>
      <th>11</th>
      <th>12</th>
      <th>13</th>
      <th>14</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1/1/2010</td>
      <td>17.90</td>
      <td>18.10</td>
      <td>17.80</td>
      <td>61.4</td>
      <td>91</td>
      <td>33</td>
      <td>1003.6</td>
      <td>1006.3</td>
      <td>1002.0</td>
      <td>0.2</td>
      <td>4.0</td>
      <td>WSW</td>
      <td>12.7</td>
      <td>2010</td>
    </tr>
    <tr>
      <th>1</th>
      <td>1/2/2010</td>
      <td>15.60</td>
      <td>15.70</td>
      <td>15.50</td>
      <td>57.4</td>
      <td>70</td>
      <td>45</td>
      <td>1005.2</td>
      <td>1008.7</td>
      <td>1001.5</td>
      <td>0.0</td>
      <td>6.8</td>
      <td>WSW</td>
      <td>20.7</td>
      <td>2010</td>
    </tr>
    <tr>
      <th>2</th>
      <td>1/3/2010</td>
      <td>13.50</td>
      <td>13.60</td>
      <td>13.40</td>
      <td>56.0</td>
      <td>76</td>
      <td>39</td>
      <td>1011.7</td>
      <td>1016.7</td>
      <td>1008.6</td>
      <td>0.0</td>
      <td>5.0</td>
      <td>WSW</td>
      <td>15.4</td>
      <td>2010</td>
    </tr>
    <tr>
      <th>3</th>
      <td>1/4/2010</td>
      <td>9.50</td>
      <td>9.60</td>
      <td>9.50</td>
      <td>50.7</td>
      <td>60</td>
      <td>38</td>
      <td>1021.3</td>
      <td>1023.1</td>
      <td>1016.8</td>
      <td>0.0</td>
      <td>4.3</td>
      <td>NNE</td>
      <td>11.0</td>
      <td>2010</td>
    </tr>
    <tr>
      <th>4</th>
      <td>1/5/2010</td>
      <td>13.40</td>
      <td>13.50</td>
      <td>13.40</td>
      <td>70.5</td>
      <td>82</td>
      <td>54</td>
      <td>1018.7</td>
      <td>1022.1</td>
      <td>1015.5</td>
      <td>0.0</td>
      <td>7.9</td>
      <td>S</td>
      <td>19.8</td>
      <td>2010</td>
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
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>3647</th>
      <td>12/27/2019</td>
      <td>10.10</td>
      <td>10.20</td>
      <td>10.00</td>
      <td>60.3</td>
      <td>79</td>
      <td>44</td>
      <td>1018.4</td>
      <td>1019.9</td>
      <td>1016.8</td>
      <td>0.0</td>
      <td>2.9</td>
      <td>NE</td>
      <td>8.0</td>
      <td>2019</td>
    </tr>
    <tr>
      <th>3648</th>
      <td>12/28/2019</td>
      <td>8.30</td>
      <td>8.40</td>
      <td>8.20</td>
      <td>60.9</td>
      <td>82</td>
      <td>46</td>
      <td>1016.0</td>
      <td>1017.2</td>
      <td>1014.2</td>
      <td>7.2</td>
      <td>4.3</td>
      <td>NE</td>
      <td>12.8</td>
      <td>2019</td>
    </tr>
    <tr>
      <th>3649</th>
      <td>12/29/2019</td>
      <td>6.40</td>
      <td>6.50</td>
      <td>6.40</td>
      <td>73.4</td>
      <td>82</td>
      <td>66</td>
      <td>1017.6</td>
      <td>1018.9</td>
      <td>1016.5</td>
      <td>3.4</td>
      <td>10.6</td>
      <td>NNE</td>
      <td>24.5</td>
      <td>2019</td>
    </tr>
    <tr>
      <th>3650</th>
      <td>12/30/2019</td>
      <td>4.00</td>
      <td>4.00</td>
      <td>3.90</td>
      <td>83.9</td>
      <td>90</td>
      <td>65</td>
      <td>1020.0</td>
      <td>1024.2</td>
      <td>1016.6</td>
      <td>12.4</td>
      <td>5.1</td>
      <td>NE</td>
      <td>15.0</td>
      <td>2019</td>
    </tr>
    <tr>
      <th>3651</th>
      <td>12/31/2019</td>
      <td>6.40</td>
      <td>6.50</td>
      <td>6.30</td>
      <td>72.3</td>
      <td>86</td>
      <td>58</td>
      <td>1025.4</td>
      <td>1026.7</td>
      <td>1023.9</td>
      <td>0.0</td>
      <td>2.7</td>
      <td>W</td>
      <td>9.4</td>
      <td>2019</td>
    </tr>
  </tbody>
</table>
<p>3652 rows × 15 columns</p>
</div>




```python
#delete not needed for the assignment columns from data1
data1 = data1.drop('SNWD', axis=1)
```


```python
#convert Fahrenheit to Celsius in data1
data1['TAVG'] = (data1.TAVG - 32)*5/9
data1['TMAX'] = (data1.TMAX - 32)*5/9
data1['TMIN'] = (data1.TMIN - 32)*5/9
```


```python
#convert inches to mm
data1['PRCP'] = (data1.PRCP *25.4)
```


```python
#delete not needed for the assignment columns from data2
data2 = data2[[0,1,2,3,10]]
```


```python
#name the columns of data2
data2 = data2.rename(columns={0:"DATE", 1:"TAVG", 2:"TMAX", 3:"TMIN", 10:"PRCP"})
```


```python
#convert characters to NaN for float type columns in data2
data2.TAVG = data2.TAVG.replace('---', np.nan)
data2.TMAX = data2.TMAX.replace('---', np.nan)
data2.TMIN = data2.TMIN.replace('---', np.nan)
```


```python
#change type of columns in data2
data2['TAVG'] = data2.TAVG.astype('float64')
data2['TMAX'] = data2.TMAX.astype('float64')
data2['TMIN'] = data2.TMIN.astype('float64')
```


```python
#merge the 2 datasets with outer join on column DATE
data = data1.merge(data2, on=["DATE"], how='outer')
```


```python
#fill NaN values of x with values of y
data.PRCP_x = data.PRCP_x.fillna(data.PRCP_y)
data.TAVG_x = data.TAVG_x.fillna(data.TAVG_y)
data.TMAX_x = data.TMAX_x.fillna(data.TMAX_y)
data.TMIN_x = data.TMIN_x.fillna(data.TMIN_y)
```


```python
#remove y columns
data = data.drop(['TAVG_y', 'TMAX_y','TMIN_y','PRCP_y'], axis=1)
```


```python
#rename x columns
data.rename(columns={'PRCP_x': 'PRCP', 'TAVG_x':'TAVG', 'TMAX_x':'TMAX', 'TMIN_x':'TMIN'}, inplace=True)
```


```python
#change columns dtypes
data['DATE'] = data.DATE.astype('Datetime64')
```


```python
#The final dataset
data
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
      <th>STATION</th>
      <th>NAME</th>
      <th>DATE</th>
      <th>PRCP</th>
      <th>TAVG</th>
      <th>TMAX</th>
      <th>TMIN</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>1955-01-01</td>
      <td>0.000</td>
      <td>NaN</td>
      <td>18.333333</td>
      <td>10.000000</td>
    </tr>
    <tr>
      <th>1</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>1955-01-02</td>
      <td>2.032</td>
      <td>NaN</td>
      <td>14.444444</td>
      <td>7.222222</td>
    </tr>
    <tr>
      <th>2</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>1955-01-03</td>
      <td>0.000</td>
      <td>NaN</td>
      <td>15.555556</td>
      <td>9.444444</td>
    </tr>
    <tr>
      <th>3</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>1955-01-04</td>
      <td>0.000</td>
      <td>NaN</td>
      <td>18.888889</td>
      <td>7.222222</td>
    </tr>
    <tr>
      <th>4</th>
      <td>GR000016716</td>
      <td>HELLINIKON, GR</td>
      <td>1955-01-05</td>
      <td>0.000</td>
      <td>NaN</td>
      <td>17.777778</td>
      <td>8.333333</td>
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
    </tr>
    <tr>
      <th>24099</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>2017-10-02</td>
      <td>0.000</td>
      <td>18.7</td>
      <td>18.800000</td>
      <td>18.600000</td>
    </tr>
    <tr>
      <th>24100</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>2017-10-08</td>
      <td>0.000</td>
      <td>17.8</td>
      <td>17.900000</td>
      <td>17.700000</td>
    </tr>
    <tr>
      <th>24101</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>2017-10-15</td>
      <td>0.000</td>
      <td>20.4</td>
      <td>20.500000</td>
      <td>20.300000</td>
    </tr>
    <tr>
      <th>24102</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>2017-10-27</td>
      <td>0.000</td>
      <td>17.8</td>
      <td>17.900000</td>
      <td>17.700000</td>
    </tr>
    <tr>
      <th>24103</th>
      <td>NaN</td>
      <td>NaN</td>
      <td>2018-09-17</td>
      <td>0.000</td>
      <td>26.3</td>
      <td>26.300000</td>
      <td>26.200000</td>
    </tr>
  </tbody>
</table>
<p>24104 rows × 7 columns</p>
</div>



# Q2: Deviation of Summer Temperatures

## Description

### We will create a graph showing the mean summer temperature deviation from a baseline of 1974-1999 and a line showing the 10 years rolling avarege of the deviation from the mean.

## Solution


```python
#create dataset of summer months from 1955 to 2020
data_summer = data.loc[(data.DATE.dt.month.isin([6,7,8]))]
#1955-2020 summers mean temperature per year
mean_summer_temp_per_year = data_summer.groupby(data_summer.DATE.dt.year).agg('mean')

#1974-1999 summers mean temperature
mean_temp = data.loc[(data['DATE'] >= '1974-06-01' ) & 
                   (data['DATE'] <= '1999-08-31') &
                   (data.DATE.dt.month.isin([6,7,8]))].TAVG.mean()

#create dataframe of deviation of summer TAVG per year from the mean_temp
mean_summer_temp_per_year['deviation'] = mean_summer_temp_per_year.TAVG - mean_temp 

#create column of moving average of 10 years
mean_summer_temp_per_year['MA'] = mean_summer_temp_per_year['deviation'].rolling(window=10, min_periods=1).mean()
```

## Graph


```python
#create the graph of deviation per year and MA per 10 years
fig = plt.gcf()
fig.set_size_inches(15.5, 8.5)
plt.bar(data.DATE.dt.year.drop_duplicates(), mean_summer_temp_per_year['deviation'], 
        color=np.where(mean_summer_temp_per_year['deviation'] < 0, 'blue', 'orange'),
        width = 0.2)
#create the plot line of 10 year moving average
mean_summer_temp_per_year['MA'].plot(kind='line', color='lightblue')
#add title and show 
plt.title('Mean Summer Temperature Difference from the 1974-1999 Mean')
plt.show()
```


    
![png](Code_files/Code_26_0.png)
    


## Interpretation

### The mean summer temperature has increased as years passing by after year 1992, in comparison to 1974-1999 summers' mean. This is an indicator of the greenhouse effect and how it has drastically affected summer temperatures the last 30 years.

# Q3: Evolution of Daily Temperatures

## Description

### We will create a plot showing the daily temperature for each year and a line showing the average daily temperature for the baseline period of 1974-1999. Both will be smoothed using a 30 days rolling average.

## 1955-2020


```python
#daily average temperature for years 1955-2020
data_Q3 = data[['DATE','TAVG']] 
```


```python
#set date as index
data_Q3 = data_Q3.set_index('DATE')
```


```python
#Smooth with moving average window of 30
data_Q3['TAVG'] = data_Q3.TAVG.rolling(window=30,min_periods=1).mean()
```


```python
#Create 2 columns for day and year
data_Q3['day'] = data_Q3.index.dayofyear
data_Q3['month'] = data_Q3.index.month
data_Q3['year'] = data_Q3.index.year
#create pivot table using data_Q3
piv = data_Q3.pivot(index=['year'],columns=['day'], values=['TAVG'])
```

## 1974-1999


```python
#daily average temperature for years 1974-1999
data_1974_1999 = data.loc[(data['DATE'] >= '1974-06-01' ) & 
                   (data['DATE'] <= '1999-08-31') ]
black_line_data = data_1974_1999[['DATE','TAVG']]
```


```python
#set date as index
black_line_data = black_line_data.set_index('DATE')
```


```python
#Smooth with moving average window of 30
black_line_data = black_line_data.rolling(window=30,min_periods=1).mean()
```


```python
#Create 2 index columns for day and year
black_line_data['day'] = black_line_data.index.dayofyear
black_line_data['year'] = black_line_data.index.year
#create pivot table using black_line_data
piv2 = black_line_data.pivot(index=['year'],columns=['day'], values=['TAVG'])
```

## Graph


```python
#plot of daily average temperature for each year
fig = plt.gcf()
fig.set_size_inches(15.5, 8.5)
n = 66
colors = cm.Oranges(np.linspace(0,1,n))
i=0
for year, day in piv.iterrows():
    plt.plot(day.to_numpy(), color= colors[i])
    i+=1
plt.xticks(np.linspace(0,365,13)[:-1], ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))
plt.xlabel("Date")
plt.ylabel("Average Daily Temperature")
plt.plot(day.to_numpy(), color= 'black')
```




    [<matplotlib.lines.Line2D at 0x22c8404c190>]




    
![png](Code_files/Code_43_1.png)
    


## Interpretation

### Temperatures are starting low in winter months and getting higher as we reach spring and summer months until a final decline in autumn months. It is observed that daily temperatures are not highly different through out the years for winter and autumn months in comparison to spring and summer months where temperatures are highler getting closer to year 2020. This means that high temperatures are highly more affected through out the years than low temperatures.

# Q4: Extreme Temperature Events

## Description

### We will create a plot to count the number of extreme temperature events per year, compared to the baseline of 1974-1999 and a line in the middle as the average percentage of extreme temperature events of the baseline.

## Baseline


```python
baseline_data = data_1974_1999[['DATE','TAVG']]
```


```python
#set date as index
baseline_data = baseline_data.set_index('DATE')
```


```python
#Create 2 index columns for day and year
baseline_data['day'] = baseline_data.index.dayofyear
baseline_data['year'] = baseline_data.index.year
```


```python
#data of period 1974-1999 per day of year
piv3 = baseline_data.pivot(index=['day'],columns=['year'], values=['TAVG'])
```


```python
#expected value of avg temperature per day of year
exp_val = piv3.mean(axis=1)
```


```python
#data of period 1974-1999 per year
piv4 = baseline_data.pivot(index=['year'],columns=['day'], values=['TAVG'])
```


```python
#convert pivot to dataframe
piv4.columns = piv4.columns.droplevel(0)
piv4.columns.name = None               
piv4 = piv4.reset_index()
```


```python
#calculate number of observasions per year
piv4['number_of_observ'] = piv4.count(axis=1)-1
```


```python
#calculate variation of each day's temp from expected value
i = 1
for j in range(1,367):
    piv4[j] = ((piv4[j] - exp_val[i])/exp_val[i])
    i+=1
```


```python
#transpose the table
piv4_tran = piv4.T

#keep extreme values as True
piv4_1 = piv4_tran > 0.1
```


```python
#Count True values as number of extreme events per year
count_of_extreme_events_baseline = (piv4_1.sum()-2)/(piv4['number_of_observ'])
```


```python
#calculate the baseline mean percentage of extreme events
round(count_of_extreme_events_baseline.mean(),2)
```




    0.25



## 1955-2020


```python
#daily average temperatures for years 1955-2020
data_Q4 = data[['DATE','TAVG']] 
```


```python
#set date as index
data_Q4 = data_Q4.set_index('DATE')
```


```python
#Create 2 columns for day and year
data_Q4['day'] = data_Q4.index.dayofyear
data_Q4['year'] = data_Q4.index.year
```


```python
#data of period 1955-2020 per year
piv6 = data_Q4.pivot(index=['year'],columns=['day'], values=['TAVG'])
```


```python
#convert pivot to dataframe
piv6.columns = piv6.columns.droplevel(0)
piv6.columns.name = None               
piv6 = piv6.reset_index() 
```


```python
piv6['number_of_observ'] = piv6.count(axis=1)-1
```


```python
#calculate variation of each day's temp from expected value
i = 1
for j in range(1,367):
    piv6[j] = ((piv6[j] - exp_val[i])/exp_val[i])
    i+=1
```


```python
#transpose the table
piv6_tran = piv6.T

#keep extreme values as True
piv6_1 = piv6_tran > 0.1
```


```python
#Count True values as number of extreme events per year
count_of_extreme_events = (piv6_1.sum()-2 )/(piv6['number_of_observ'])
```

## Graph


```python
#create the graph and line
fig = plt.gcf()
fig.set_size_inches(15.5, 8.5)
plt.bar(data_Q4.year.unique(), count_of_extreme_events , 
        color=np.where(count_of_extreme_events  < count_of_extreme_events_baseline.mean() , 'blue', 'orange'),
        width = 0.2)
#create the plot line of 10 year moving average
plt.axhline(count_of_extreme_events_baseline.mean())
```




    <matplotlib.lines.Line2D at 0x22c83878220>




    
![png](Code_files/Code_73_1.png)
    


## Interpretation

### It is observed that the number of extreme yearly events is increased in comparison to the mean of 1974-1999 getting close to 50% of the days of a year. This mainly occurs due to the increase of high temperatures to a level higher than 10% from the baseline.

# Q5: Precipitation

## Description

### We will create create a plot showing the ratio of rainfall over rainy days over the years and a line for the 10 years rolling average.


```python
#daily rainfall for years 1955-2020
data_Q5 = data[['DATE','PRCP']] 
```


```python
#total rainfall per year
overall_rainfall = data_Q5.groupby(data_Q5.DATE.dt.year)['PRCP'].agg('sum')
```


```python
data_Q5 = data_Q5.dropna()
data_Q5['rainy_day'] = (data_Q5.PRCP != 0)
```


```python
#total of rainy days per year
count_rainy_days = data_Q5.groupby(data_Q5.DATE.dt.year)['rainy_day'].agg('sum')
```


```python
#ratio of rainfall over rainy days per year
ratio = overall_rainfall/count_rainy_days
```


```python
#ratio of rainfall over rainy days per year with rolling window 10
ratio_MA = ratio.rolling(window=10,min_periods=1).mean()
```


```python
#create the graph and line
fig = plt.gcf()
fig.set_size_inches(15.5, 8.5)
plt.bar(data_Q5.DATE.dt.year.unique(), ratio , 
        color='blue',
        width = 0.2)
#create the plot line of 10 year moving average
ratio_MA.plot(kind='line', color='lightblue')
plt.show()
```


    
![png](Code_files/Code_85_0.png)
    


## Interpretation

### High ratios indicate a year with a few days of highly concentrated rain and lower ratios a year of many rainy days with low bursts of rain. Ratios seem to be moving in a pattern with low concentration of rainfall for 3 to 5 years and a sudden burst of high conentration of rainfall for a year.
