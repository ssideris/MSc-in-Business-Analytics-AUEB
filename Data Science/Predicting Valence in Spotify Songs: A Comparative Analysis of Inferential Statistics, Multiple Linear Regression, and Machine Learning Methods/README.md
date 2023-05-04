# Table of Contents
[Q1: Explore which Track Features Influence Valence using Inferential Statistics](#1.-explore-which-track-features-influence-valence-using-inferential-statistics)

[Q2: Predict Valence using 3 Machine Learning methods]

# Scope

### Use inferential statistics and machine learning methods to create the best model for predicting the metric valence of spotify songs.

# Import Data 

### The dataset we will use is found in the following url: https://www.kaggle.com/rodolfofigueroa/spotify-12m-songs. 
### It contains audio features for over 1.2 million songs, obtained with the Spotify API. 


```python
#import library pandas
import pandas as pd
import numpy as np
import scipy.stats.stats as stats
import statsmodels.api as sm
import statsmodels.formula.api as smf
import statsmodels.stats.api as sms
import statsmodels.tsa.api as smt
from statsmodels.stats.outliers_influence import variance_inflation_factor
from statsmodels.tools.tools import add_constant
import matplotlib.pyplot as plt
import seaborn as sns
from plotnine import *
import sklearn as sk
from sklearn.model_selection import train_test_split
from sklearn.linear_model import SGDClassifier
import sklearn.metrics as metrics


%matplotlib inline
```


```python
#import the dataset as dataframe
data = pd.read_csv("tracks_features.csv")
```

### The dataset consists of 1204025 observations with each observation being a unique song. Each observation includes 24 variables which are:

1) id: spotify track id
2) name: track title
3) album: album title
4) album_id: Spotify album ID
5) artist: list of artist names
6) artist_ids: list of Spotify artist IDs
7) track_number: 
8) disc_number:
9) explicit: whether the song is explicit in Spotify or not
10) danceability: how suitable a track is for dancing
11) energy: how intense and active a track is
12) key: overall key of the track
13) loudness: overall loudness of the track in decibels(DB)
14) mode: whether the track is in major mode (1) or minor (0)
15) speechiness: proportion of spoken words in the track
16) acousticness: confidence measure of whether a track is acoustic
17) instrumentalness: proportion of instrumental parts in a track
18) liveness: detects live audience in a track. represents the probability that a track was performed live
19) valence: measures how positive a track sounds, from 1 (extremely positive) to 0 (extremely negative)
20) tempo: overall tempo of a track, in beats per minute (BPM)
21) duration_ms: duration of a track, in milliseconds (ms)
22) time_signature:  a notational convention to specify how many beats are in each bar (or measure)
23) year: release date of track
24) release_date: full release date 

### Variable valence is our dependent variable and the rest variables are our predictors.


```python
#The dataset
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
      <th>id</th>
      <th>name</th>
      <th>album</th>
      <th>album_id</th>
      <th>artists</th>
      <th>artist_ids</th>
      <th>track_number</th>
      <th>disc_number</th>
      <th>explicit</th>
      <th>danceability</th>
      <th>...</th>
      <th>speechiness</th>
      <th>acousticness</th>
      <th>instrumentalness</th>
      <th>liveness</th>
      <th>valence</th>
      <th>tempo</th>
      <th>duration_ms</th>
      <th>time_signature</th>
      <th>year</th>
      <th>release_date</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>7lmeHLHBe4nmXzuXc0HDjk</td>
      <td>Testify</td>
      <td>The Battle Of Los Angeles</td>
      <td>2eia0myWFgoHuttJytCxgX</td>
      <td>['Rage Against The Machine']</td>
      <td>['2d0hyoQ5ynDBnkvAbJKORj']</td>
      <td>1</td>
      <td>1</td>
      <td>False</td>
      <td>0.470</td>
      <td>...</td>
      <td>0.0727</td>
      <td>0.02610</td>
      <td>0.000011</td>
      <td>0.3560</td>
      <td>0.503</td>
      <td>117.906</td>
      <td>210133</td>
      <td>4.0</td>
      <td>1999</td>
      <td>1999-11-02</td>
    </tr>
    <tr>
      <th>1</th>
      <td>1wsRitfRRtWyEapl0q22o8</td>
      <td>Guerrilla Radio</td>
      <td>The Battle Of Los Angeles</td>
      <td>2eia0myWFgoHuttJytCxgX</td>
      <td>['Rage Against The Machine']</td>
      <td>['2d0hyoQ5ynDBnkvAbJKORj']</td>
      <td>2</td>
      <td>1</td>
      <td>True</td>
      <td>0.599</td>
      <td>...</td>
      <td>0.1880</td>
      <td>0.01290</td>
      <td>0.000071</td>
      <td>0.1550</td>
      <td>0.489</td>
      <td>103.680</td>
      <td>206200</td>
      <td>4.0</td>
      <td>1999</td>
      <td>1999-11-02</td>
    </tr>
    <tr>
      <th>2</th>
      <td>1hR0fIFK2qRG3f3RF70pb7</td>
      <td>Calm Like a Bomb</td>
      <td>The Battle Of Los Angeles</td>
      <td>2eia0myWFgoHuttJytCxgX</td>
      <td>['Rage Against The Machine']</td>
      <td>['2d0hyoQ5ynDBnkvAbJKORj']</td>
      <td>3</td>
      <td>1</td>
      <td>False</td>
      <td>0.315</td>
      <td>...</td>
      <td>0.4830</td>
      <td>0.02340</td>
      <td>0.000002</td>
      <td>0.1220</td>
      <td>0.370</td>
      <td>149.749</td>
      <td>298893</td>
      <td>4.0</td>
      <td>1999</td>
      <td>1999-11-02</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2lbASgTSoDO7MTuLAXlTW0</td>
      <td>Mic Check</td>
      <td>The Battle Of Los Angeles</td>
      <td>2eia0myWFgoHuttJytCxgX</td>
      <td>['Rage Against The Machine']</td>
      <td>['2d0hyoQ5ynDBnkvAbJKORj']</td>
      <td>4</td>
      <td>1</td>
      <td>True</td>
      <td>0.440</td>
      <td>...</td>
      <td>0.2370</td>
      <td>0.16300</td>
      <td>0.000004</td>
      <td>0.1210</td>
      <td>0.574</td>
      <td>96.752</td>
      <td>213640</td>
      <td>4.0</td>
      <td>1999</td>
      <td>1999-11-02</td>
    </tr>
    <tr>
      <th>4</th>
      <td>1MQTmpYOZ6fcMQc56Hdo7T</td>
      <td>Sleep Now In the Fire</td>
      <td>The Battle Of Los Angeles</td>
      <td>2eia0myWFgoHuttJytCxgX</td>
      <td>['Rage Against The Machine']</td>
      <td>['2d0hyoQ5ynDBnkvAbJKORj']</td>
      <td>5</td>
      <td>1</td>
      <td>False</td>
      <td>0.426</td>
      <td>...</td>
      <td>0.0701</td>
      <td>0.00162</td>
      <td>0.105000</td>
      <td>0.0789</td>
      <td>0.539</td>
      <td>127.059</td>
      <td>205600</td>
      <td>4.0</td>
      <td>1999</td>
      <td>1999-11-02</td>
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
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>1204020</th>
      <td>0EsMifwUmMfJZxzoMPXJKZ</td>
      <td>Gospel of Juke</td>
      <td>Notch - EP</td>
      <td>38O5Ys0W9PFS5K7dMb7yKb</td>
      <td>['FVLCRVM']</td>
      <td>['7AjItKsRnEYRSiBt2OxK1y']</td>
      <td>2</td>
      <td>1</td>
      <td>False</td>
      <td>0.264</td>
      <td>...</td>
      <td>0.0672</td>
      <td>0.00935</td>
      <td>0.002240</td>
      <td>0.3370</td>
      <td>0.415</td>
      <td>159.586</td>
      <td>276213</td>
      <td>4.0</td>
      <td>2014</td>
      <td>2014-01-09</td>
    </tr>
    <tr>
      <th>1204021</th>
      <td>2WSc2TB1CSJgGE0PEzVeiu</td>
      <td>Prism Visions</td>
      <td>Notch - EP</td>
      <td>38O5Ys0W9PFS5K7dMb7yKb</td>
      <td>['FVLCRVM']</td>
      <td>['7AjItKsRnEYRSiBt2OxK1y']</td>
      <td>3</td>
      <td>1</td>
      <td>False</td>
      <td>0.796</td>
      <td>...</td>
      <td>0.0883</td>
      <td>0.10400</td>
      <td>0.644000</td>
      <td>0.0749</td>
      <td>0.781</td>
      <td>121.980</td>
      <td>363179</td>
      <td>4.0</td>
      <td>2014</td>
      <td>2014-01-09</td>
    </tr>
    <tr>
      <th>1204022</th>
      <td>6iProIgUe3ETpO6UT0v5Hg</td>
      <td>Tokyo 360</td>
      <td>Notch - EP</td>
      <td>38O5Ys0W9PFS5K7dMb7yKb</td>
      <td>['FVLCRVM']</td>
      <td>['7AjItKsRnEYRSiBt2OxK1y']</td>
      <td>4</td>
      <td>1</td>
      <td>False</td>
      <td>0.785</td>
      <td>...</td>
      <td>0.0564</td>
      <td>0.03040</td>
      <td>0.918000</td>
      <td>0.0664</td>
      <td>0.467</td>
      <td>121.996</td>
      <td>385335</td>
      <td>4.0</td>
      <td>2014</td>
      <td>2014-01-09</td>
    </tr>
    <tr>
      <th>1204023</th>
      <td>37B4SXC8uoBsUyKCWnhPfX</td>
      <td>Yummy!</td>
      <td>Notch - EP</td>
      <td>38O5Ys0W9PFS5K7dMb7yKb</td>
      <td>['FVLCRVM']</td>
      <td>['7AjItKsRnEYRSiBt2OxK1y']</td>
      <td>5</td>
      <td>1</td>
      <td>False</td>
      <td>0.665</td>
      <td>...</td>
      <td>0.0409</td>
      <td>0.00007</td>
      <td>0.776000</td>
      <td>0.1170</td>
      <td>0.227</td>
      <td>124.986</td>
      <td>324455</td>
      <td>4.0</td>
      <td>2014</td>
      <td>2014-01-09</td>
    </tr>
    <tr>
      <th>1204024</th>
      <td>3GgQmOxxLyRoAb4j86zOBX</td>
      <td>That's The Way It Is</td>
      <td>Notch - EP</td>
      <td>38O5Ys0W9PFS5K7dMb7yKb</td>
      <td>['FVLCRVM']</td>
      <td>['7AjItKsRnEYRSiBt2OxK1y']</td>
      <td>6</td>
      <td>1</td>
      <td>False</td>
      <td>0.736</td>
      <td>...</td>
      <td>0.0539</td>
      <td>0.01680</td>
      <td>0.296000</td>
      <td>0.2790</td>
      <td>0.204</td>
      <td>117.991</td>
      <td>304982</td>
      <td>4.0</td>
      <td>2014</td>
      <td>2014-01-09</td>
    </tr>
  </tbody>
</table>
<p>1204025 rows × 24 columns</p>
</div>



### We exclude the variables that offer no significant value to our model as they are not audio features of a song as Spotify specify them here:
https://developer.spotify.com/documentation/web-api/reference/#/operations/get-audio-features 

https://developer.spotify.com/documentation/web-api/reference/#/operations/get-audio-analysis


```python
#drop columns
data = data.drop(['id','name','album','album_id','artists','artist_ids','track_number','disc_number','explicit','year','release_date'], axis=1)
```

### The dataset now includes 3 int variables and 10 float variables. Variables key, mode and time_signature are categorical variables and will be treated like this when needed.


```python
# types of variables
data.dtypes
```




    danceability        float64
    energy              float64
    key                   int64
    loudness            float64
    mode                  int64
    speechiness         float64
    acousticness        float64
    instrumentalness    float64
    liveness            float64
    valence             float64
    tempo               float64
    duration_ms           int64
    time_signature      float64
    dtype: object



### No empty or NaN values exist.


```python
#find NaN Values
np.where(pd.isnull(data))
```




    (array([], dtype=int64), array([], dtype=int64))




```python
#find empty values
np.where(data.applymap(lambda x: x == ''))
```




    (array([], dtype=int64), array([], dtype=int64))



### Our final dataset is:


```python
#the final dataset
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
      <th>danceability</th>
      <th>energy</th>
      <th>key</th>
      <th>loudness</th>
      <th>mode</th>
      <th>speechiness</th>
      <th>acousticness</th>
      <th>instrumentalness</th>
      <th>liveness</th>
      <th>valence</th>
      <th>tempo</th>
      <th>duration_ms</th>
      <th>time_signature</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0.470</td>
      <td>0.978</td>
      <td>7</td>
      <td>-5.399</td>
      <td>1</td>
      <td>0.0727</td>
      <td>0.02610</td>
      <td>0.000011</td>
      <td>0.3560</td>
      <td>0.503</td>
      <td>117.906</td>
      <td>210133</td>
      <td>4.0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>0.599</td>
      <td>0.957</td>
      <td>11</td>
      <td>-5.764</td>
      <td>1</td>
      <td>0.1880</td>
      <td>0.01290</td>
      <td>0.000071</td>
      <td>0.1550</td>
      <td>0.489</td>
      <td>103.680</td>
      <td>206200</td>
      <td>4.0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>0.315</td>
      <td>0.970</td>
      <td>7</td>
      <td>-5.424</td>
      <td>1</td>
      <td>0.4830</td>
      <td>0.02340</td>
      <td>0.000002</td>
      <td>0.1220</td>
      <td>0.370</td>
      <td>149.749</td>
      <td>298893</td>
      <td>4.0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>0.440</td>
      <td>0.967</td>
      <td>11</td>
      <td>-5.830</td>
      <td>0</td>
      <td>0.2370</td>
      <td>0.16300</td>
      <td>0.000004</td>
      <td>0.1210</td>
      <td>0.574</td>
      <td>96.752</td>
      <td>213640</td>
      <td>4.0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>0.426</td>
      <td>0.929</td>
      <td>2</td>
      <td>-6.729</td>
      <td>1</td>
      <td>0.0701</td>
      <td>0.00162</td>
      <td>0.105000</td>
      <td>0.0789</td>
      <td>0.539</td>
      <td>127.059</td>
      <td>205600</td>
      <td>4.0</td>
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
    </tr>
    <tr>
      <th>1204020</th>
      <td>0.264</td>
      <td>0.966</td>
      <td>5</td>
      <td>-6.970</td>
      <td>0</td>
      <td>0.0672</td>
      <td>0.00935</td>
      <td>0.002240</td>
      <td>0.3370</td>
      <td>0.415</td>
      <td>159.586</td>
      <td>276213</td>
      <td>4.0</td>
    </tr>
    <tr>
      <th>1204021</th>
      <td>0.796</td>
      <td>0.701</td>
      <td>11</td>
      <td>-6.602</td>
      <td>0</td>
      <td>0.0883</td>
      <td>0.10400</td>
      <td>0.644000</td>
      <td>0.0749</td>
      <td>0.781</td>
      <td>121.980</td>
      <td>363179</td>
      <td>4.0</td>
    </tr>
    <tr>
      <th>1204022</th>
      <td>0.785</td>
      <td>0.796</td>
      <td>9</td>
      <td>-5.960</td>
      <td>0</td>
      <td>0.0564</td>
      <td>0.03040</td>
      <td>0.918000</td>
      <td>0.0664</td>
      <td>0.467</td>
      <td>121.996</td>
      <td>385335</td>
      <td>4.0</td>
    </tr>
    <tr>
      <th>1204023</th>
      <td>0.665</td>
      <td>0.856</td>
      <td>6</td>
      <td>-6.788</td>
      <td>0</td>
      <td>0.0409</td>
      <td>0.00007</td>
      <td>0.776000</td>
      <td>0.1170</td>
      <td>0.227</td>
      <td>124.986</td>
      <td>324455</td>
      <td>4.0</td>
    </tr>
    <tr>
      <th>1204024</th>
      <td>0.736</td>
      <td>0.708</td>
      <td>2</td>
      <td>-9.279</td>
      <td>0</td>
      <td>0.0539</td>
      <td>0.01680</td>
      <td>0.296000</td>
      <td>0.2790</td>
      <td>0.204</td>
      <td>117.991</td>
      <td>304982</td>
      <td>4.0</td>
    </tr>
  </tbody>
</table>
<p>1204025 rows × 13 columns</p>
</div>



# 1. Explore which Track Features Influence Valence using Inferential Statistics

## Descriptive Statistics and Model Choice

### Valence is a continuous variable that takes values between [0,1] with its mean value been equal to 0.43. A very small amount of observations takes value exactly at 0,1.


```python
#Observe the frequency of values of valence
f = plt.figure(figsize=(10, 10))
ax = sns.countplot(x="valence",data=data)
```


    
![png](README_files/README_20_0.png)
    



```python
#descriptive statistics
data.describe().round(decimals=2)
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
      <th>danceability</th>
      <th>energy</th>
      <th>key</th>
      <th>loudness</th>
      <th>mode</th>
      <th>speechiness</th>
      <th>acousticness</th>
      <th>instrumentalness</th>
      <th>liveness</th>
      <th>valence</th>
      <th>tempo</th>
      <th>duration_ms</th>
      <th>time_signature</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>count</th>
      <td>1204025.00</td>
      <td>1204025.00</td>
      <td>1204025.00</td>
      <td>1204025.00</td>
      <td>1204025.00</td>
      <td>1204025.00</td>
      <td>1204025.00</td>
      <td>1204025.00</td>
      <td>1204025.00</td>
      <td>1204025.00</td>
      <td>1204025.00</td>
      <td>1204025.00</td>
      <td>1204025.00</td>
    </tr>
    <tr>
      <th>mean</th>
      <td>0.49</td>
      <td>0.51</td>
      <td>5.19</td>
      <td>-11.81</td>
      <td>0.67</td>
      <td>0.08</td>
      <td>0.45</td>
      <td>0.28</td>
      <td>0.20</td>
      <td>0.43</td>
      <td>117.63</td>
      <td>248839.86</td>
      <td>3.83</td>
    </tr>
    <tr>
      <th>std</th>
      <td>0.19</td>
      <td>0.29</td>
      <td>3.54</td>
      <td>6.98</td>
      <td>0.47</td>
      <td>0.12</td>
      <td>0.39</td>
      <td>0.38</td>
      <td>0.18</td>
      <td>0.27</td>
      <td>30.94</td>
      <td>162210.36</td>
      <td>0.56</td>
    </tr>
    <tr>
      <th>min</th>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>-60.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>0.00</td>
      <td>1000.00</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>25%</th>
      <td>0.36</td>
      <td>0.25</td>
      <td>2.00</td>
      <td>-15.25</td>
      <td>0.00</td>
      <td>0.04</td>
      <td>0.04</td>
      <td>0.00</td>
      <td>0.10</td>
      <td>0.19</td>
      <td>94.05</td>
      <td>174090.00</td>
      <td>4.00</td>
    </tr>
    <tr>
      <th>50%</th>
      <td>0.50</td>
      <td>0.52</td>
      <td>5.00</td>
      <td>-9.79</td>
      <td>1.00</td>
      <td>0.04</td>
      <td>0.39</td>
      <td>0.01</td>
      <td>0.12</td>
      <td>0.40</td>
      <td>116.73</td>
      <td>224339.00</td>
      <td>4.00</td>
    </tr>
    <tr>
      <th>75%</th>
      <td>0.63</td>
      <td>0.77</td>
      <td>8.00</td>
      <td>-6.72</td>
      <td>1.00</td>
      <td>0.07</td>
      <td>0.86</td>
      <td>0.72</td>
      <td>0.24</td>
      <td>0.64</td>
      <td>137.05</td>
      <td>285840.00</td>
      <td>4.00</td>
    </tr>
    <tr>
      <th>max</th>
      <td>1.00</td>
      <td>1.00</td>
      <td>11.00</td>
      <td>7.23</td>
      <td>1.00</td>
      <td>0.97</td>
      <td>1.00</td>
      <td>1.00</td>
      <td>1.00</td>
      <td>1.00</td>
      <td>248.93</td>
      <td>6061090.00</td>
      <td>5.00</td>
    </tr>
  </tbody>
</table>
</div>



### We will calculate the pairwise correlations of numeric variables. Valence is only, somewhat, positively correlated to danceability and so, data might not explain valence in a significant level. Energy seems negatively correlated to loudness and acousticness while loudness and acousticness are positively correlated. The high correlations could lead to possible problems of multicollinearity in our model, which affects inference as it increases the value of coefficients.


```python
#numeric only dataset
data_num = data.drop(['key','mode','time_signature'], axis=1)
#categorical variables dataset
data_cat = data[['key','mode','time_signature']]
```


```python
#pairwise correlation matrix plot
f = plt.figure(figsize=(8, 8))
p=sns.heatmap(data_num.corr(), annot=True,cmap='RdYlGn',square=True)
```


    
![png](README_files/README_24_0.png)
    


### We plot our data to see their distributions. It seems that a linear regression is not the correct type to choose for our model as any variable seems to follow a line against valence.


```python
#plot numeric variables
sns.pairplot(data_num, x_vars=['danceability','energy','loudness','speechiness','acousticness','instrumentalness','liveness','tempo','duration_ms'], y_vars='valence', height=7, aspect=0.7)
```




    <seaborn.axisgrid.PairGrid at 0x1d8d7685d00>




    
![png](README_files/README_26_1.png)
    



```python
#plot catogorical variables
fig, axs = plt.subplots(ncols=3)
fig.set_size_inches(18.5, 10.5, forward=True)
fig.tight_layout(pad=3.0)
sns.boxplot(x = 'key', y='valence', data=data, ax=axs[0])
sns.boxplot(x = 'mode', y='valence', data=data, ax=axs[1])
sns.boxplot(x = 'time_signature', y='valence', data=data, ax=axs[2])
```




    <AxesSubplot:xlabel='time_signature', ylabel='valence'>




    
![png](README_files/README_27_1.png)
    


### The most appropriate regression to use is the Beta regression as valence is a continous variable in [0,1], in combination with a transformation in order to change the interval into (0,1) if needed. As Beta distribution has not been taught and logistic regression cannot be used for continuous variables in the interval [0,1], we will try to proceed using the ols regression and Normal Distribution of residuals in order to built our model. 


```python
#ols regression
fullm = smf.ols(formula='valence ~ danceability + energy + C(key) + loudness + C(mode) + speechiness + acousticness + instrumentalness + liveness + tempo + duration_ms + C(time_signature)', data=data)
results  = fullm.fit()
```

### The adjusted R^2 is good been equal to 0.43 and all of our predictors are statistically significant. The Prob of F-Statistic is 0 meaning that our model is better than the constant-only model.


```python
results.summary()
```




<table class="simpletable">
<caption>OLS Regression Results</caption>
<tr>
  <th>Dep. Variable:</th>         <td>valence</td>     <th>  R-squared:         </th>  <td>   0.435</td> 
</tr>
<tr>
  <th>Model:</th>                   <td>OLS</td>       <th>  Adj. R-squared:    </th>  <td>   0.435</td> 
</tr>
<tr>
  <th>Method:</th>             <td>Least Squares</td>  <th>  F-statistic:       </th>  <td>3.709e+04</td>
</tr>
<tr>
  <th>Date:</th>             <td>Sun, 06 Mar 2022</td> <th>  Prob (F-statistic):</th>   <td>  0.00</td>  
</tr>
<tr>
  <th>Time:</th>                 <td>22:36:31</td>     <th>  Log-Likelihood:    </th> <td>2.0965e+05</td>
</tr>
<tr>
  <th>No. Observations:</th>      <td>1204025</td>     <th>  AIC:               </th> <td>-4.192e+05</td>
</tr>
<tr>
  <th>Df Residuals:</th>          <td>1203999</td>     <th>  BIC:               </th> <td>-4.189e+05</td>
</tr>
<tr>
  <th>Df Model:</th>              <td>    25</td>      <th>                     </th>      <td> </td>    
</tr>
<tr>
  <th>Covariance Type:</th>      <td>nonrobust</td>    <th>                     </th>      <td> </td>    
</tr>
</table>
<table class="simpletable">
<tr>
              <td></td>                <th>coef</th>     <th>std err</th>      <th>t</th>      <th>P>|t|</th>  <th>[0.025</th>    <th>0.975]</th>  
</tr>
<tr>
  <th>Intercept</th>                <td>   -0.3005</td> <td>    0.004</td> <td>  -72.217</td> <td> 0.000</td> <td>   -0.309</td> <td>   -0.292</td>
</tr>
<tr>
  <th>C(key)[T.1]</th>              <td>   -0.0401</td> <td>    0.001</td> <td>  -47.325</td> <td> 0.000</td> <td>   -0.042</td> <td>   -0.038</td>
</tr>
<tr>
  <th>C(key)[T.2]</th>              <td>    0.0008</td> <td>    0.001</td> <td>    1.037</td> <td> 0.300</td> <td>   -0.001</td> <td>    0.002</td>
</tr>
<tr>
  <th>C(key)[T.3]</th>              <td>   -0.0041</td> <td>    0.001</td> <td>   -3.592</td> <td> 0.000</td> <td>   -0.006</td> <td>   -0.002</td>
</tr>
<tr>
  <th>C(key)[T.4]</th>              <td>   -0.0047</td> <td>    0.001</td> <td>   -5.507</td> <td> 0.000</td> <td>   -0.006</td> <td>   -0.003</td>
</tr>
<tr>
  <th>C(key)[T.5]</th>              <td>    0.0061</td> <td>    0.001</td> <td>    7.328</td> <td> 0.000</td> <td>    0.004</td> <td>    0.008</td>
</tr>
<tr>
  <th>C(key)[T.6]</th>              <td>   -0.0087</td> <td>    0.001</td> <td>   -8.942</td> <td> 0.000</td> <td>   -0.011</td> <td>   -0.007</td>
</tr>
<tr>
  <th>C(key)[T.7]</th>              <td>    0.0059</td> <td>    0.001</td> <td>    8.016</td> <td> 0.000</td> <td>    0.004</td> <td>    0.007</td>
</tr>
<tr>
  <th>C(key)[T.8]</th>              <td>   -0.0187</td> <td>    0.001</td> <td>  -19.549</td> <td> 0.000</td> <td>   -0.021</td> <td>   -0.017</td>
</tr>
<tr>
  <th>C(key)[T.9]</th>              <td>    0.0089</td> <td>    0.001</td> <td>   11.567</td> <td> 0.000</td> <td>    0.007</td> <td>    0.010</td>
</tr>
<tr>
  <th>C(key)[T.10]</th>             <td>   -0.0026</td> <td>    0.001</td> <td>   -2.886</td> <td> 0.004</td> <td>   -0.004</td> <td>   -0.001</td>
</tr>
<tr>
  <th>C(key)[T.11]</th>             <td>   -0.0061</td> <td>    0.001</td> <td>   -6.778</td> <td> 0.000</td> <td>   -0.008</td> <td>   -0.004</td>
</tr>
<tr>
  <th>C(mode)[T.1]</th>             <td>    0.0256</td> <td>    0.000</td> <td>   62.215</td> <td> 0.000</td> <td>    0.025</td> <td>    0.026</td>
</tr>
<tr>
  <th>C(time_signature)[T.1.0]</th> <td>   -0.0051</td> <td>    0.004</td> <td>   -1.218</td> <td> 0.223</td> <td>   -0.013</td> <td>    0.003</td>
</tr>
<tr>
  <th>C(time_signature)[T.3.0]</th> <td>   -0.0124</td> <td>    0.004</td> <td>   -3.115</td> <td> 0.002</td> <td>   -0.020</td> <td>   -0.005</td>
</tr>
<tr>
  <th>C(time_signature)[T.4.0]</th> <td>    0.0039</td> <td>    0.004</td> <td>    0.972</td> <td> 0.331</td> <td>   -0.004</td> <td>    0.012</td>
</tr>
<tr>
  <th>C(time_signature)[T.5.0]</th> <td>   -0.0250</td> <td>    0.004</td> <td>   -6.082</td> <td> 0.000</td> <td>   -0.033</td> <td>   -0.017</td>
</tr>
<tr>
  <th>danceability</th>             <td>    0.7088</td> <td>    0.001</td> <td>  618.635</td> <td> 0.000</td> <td>    0.707</td> <td>    0.711</td>
</tr>
<tr>
  <th>energy</th>                   <td>    0.4387</td> <td>    0.001</td> <td>  310.005</td> <td> 0.000</td> <td>    0.436</td> <td>    0.441</td>
</tr>
<tr>
  <th>loudness</th>                 <td>   -0.0047</td> <td> 5.11e-05</td> <td>  -92.844</td> <td> 0.000</td> <td>   -0.005</td> <td>   -0.005</td>
</tr>
<tr>
  <th>speechiness</th>              <td>   -0.1505</td> <td>    0.002</td> <td>  -87.105</td> <td> 0.000</td> <td>   -0.154</td> <td>   -0.147</td>
</tr>
<tr>
  <th>acousticness</th>             <td>    0.1520</td> <td>    0.001</td> <td>  187.405</td> <td> 0.000</td> <td>    0.150</td> <td>    0.154</td>
</tr>
<tr>
  <th>instrumentalness</th>         <td>   -0.0781</td> <td>    0.001</td> <td> -139.378</td> <td> 0.000</td> <td>   -0.079</td> <td>   -0.077</td>
</tr>
<tr>
  <th>liveness</th>                 <td>    0.0308</td> <td>    0.001</td> <td>   28.334</td> <td> 0.000</td> <td>    0.029</td> <td>    0.033</td>
</tr>
<tr>
  <th>tempo</th>                    <td>    0.0008</td> <td> 6.36e-06</td> <td>  118.796</td> <td> 0.000</td> <td>    0.001</td> <td>    0.001</td>
</tr>
<tr>
  <th>duration_ms</th>              <td>-1.736e-07</td> <td> 1.17e-09</td> <td> -148.515</td> <td> 0.000</td> <td>-1.76e-07</td> <td>-1.71e-07</td>
</tr>
</table>
<table class="simpletable">
<tr>
  <th>Omnibus:</th>       <td>3166.090</td> <th>  Durbin-Watson:     </th> <td>   1.370</td>
</tr>
<tr>
  <th>Prob(Omnibus):</th>  <td> 0.000</td>  <th>  Jarque-Bera (JB):  </th> <td>3116.368</td>
</tr>
<tr>
  <th>Skew:</th>           <td> 0.113</td>  <th>  Prob(JB):          </th> <td>    0.00</td>
</tr>
<tr>
  <th>Kurtosis:</th>       <td> 2.894</td>  <th>  Cond. No.          </th> <td>1.41e+07</td>
</tr>
</table><br/><br/>Notes:<br/>[1] Standard Errors assume that the covariance matrix of the errors is correctly specified.<br/>[2] The condition number is large, 1.41e+07. This might indicate that there are<br/>strong multicollinearity or other numerical problems.



## Variable elimination

### We perform bothway stepwise procedures in order to minimize the number of independent variables in our model.

### Firstly, we create a Matrix X where we store our observations. 


```python
def process_subset(y, data, feature_set):
    X = data.loc[:, feature_set].values
    X = sm.add_constant(X)
    names = ['intercept']
    names.extend(feature_set)
    model = sm.OLS(y, X)
    model.data.xnames = names
    regr = model.fit()
    return regr
    
```

### Afterwards, we create a function that will keep k number of independent variables in our model and choose from all the different combinations of the 12 independent variables the ones with the best R^2 for each k combination.


```python
import itertools

def get_best_of_k(y, data, k):
    
    best_rsquared = 0
    best_model = None
    for comb in itertools.combinations(data.columns, k):
        regr = process_subset(y, data, comb)
        if regr.rsquared > best_rsquared:
            best_rsquared = regr.rsquared
            best_model = regr

    return best_model
```

###  Finally, we create a function that will find the best overall model from the best models found in the step before having as a criterion the adjusted R^2. 


```python
def best_subset_selection(data, exog):
    best_model = None
    best_models = []
    y = data.loc[:, exog]
    endog = [ x for x in data.columns if x != exog ]
    X = data.loc[:, endog]

    for i in range(1, len(data.columns)):
        print(f'Finding the best model for {i} variable{"s" if i > 1 else ""}')
        model = get_best_of_k(y, X, i)
        if not best_model or model.rsquared_adj > best_model.rsquared_adj:
            best_model = model
        print(model.model.data.xnames[1:]) # get the variables minums the intercept
        best_models.append(model)

    print(f'Fitted {2**len(data.columns)} models')
    return best_model, best_models
```

### The best model does not exclude any variable from the full model.


```python
#best_model, _ = best_subset_selection(data, 'valence')
#print('Best overall model:', len(best_model.model.exog_names), best_model.model.exog_names)
```

## Check Assumptions

### We check for Multicollinearity using the Variance Inflation Factor, as it affects homoscedasticity. As expected from the pairwised correlations matrix, energy has a VIF of 5.41>5 and so multicollinearity exists.


```python
#VIF Test 
X = add_constant(data_num)
pd.Series([variance_inflation_factor(X.values, i) for i in range(X.shape[1])],
          index=X.columns)
```




    const               89.452814
    danceability         1.733798
    energy               5.399557
    loudness             3.703168
    speechiness          1.144053
    acousticness         2.897141
    instrumentalness     1.308447
    liveness             1.118796
    valence              1.755503
    tempo                1.096592
    duration_ms          1.053034
    dtype: float64



### We exclude variables loudness and acousticness as they are explained by variable energy and are less correlated to valence than energy. The multicollinearity problem is fixed.


```python
#exclude loudness and acousticness
data1 = data.drop(['loudness', 'acousticness'], axis=1)
```

### The new model has decreased adjusted R-squared as 2 variables were excluded but it is alligned to ols regression assumption of non-multicollinearity.


```python
#new model
m1 = smf.ols(formula='valence ~ danceability + energy + C(key) + C(mode) + speechiness + instrumentalness + liveness + tempo + duration_ms + C(time_signature)', data=data1).fit()
m1.summary()
```




<table class="simpletable">
<caption>OLS Regression Results</caption>
<tr>
  <th>Dep. Variable:</th>         <td>valence</td>     <th>  R-squared:         </th>  <td>   0.414</td> 
</tr>
<tr>
  <th>Model:</th>                   <td>OLS</td>       <th>  Adj. R-squared:    </th>  <td>   0.414</td> 
</tr>
<tr>
  <th>Method:</th>             <td>Least Squares</td>  <th>  F-statistic:       </th>  <td>3.705e+04</td>
</tr>
<tr>
  <th>Date:</th>             <td>Sun, 06 Mar 2022</td> <th>  Prob (F-statistic):</th>   <td>  0.00</td>  
</tr>
<tr>
  <th>Time:</th>                 <td>22:36:50</td>     <th>  Log-Likelihood:    </th> <td>1.8804e+05</td>
</tr>
<tr>
  <th>No. Observations:</th>      <td>1204025</td>     <th>  AIC:               </th> <td>-3.760e+05</td>
</tr>
<tr>
  <th>Df Residuals:</th>          <td>1204001</td>     <th>  BIC:               </th> <td>-3.757e+05</td>
</tr>
<tr>
  <th>Df Model:</th>              <td>    23</td>      <th>                     </th>      <td> </td>    
</tr>
<tr>
  <th>Covariance Type:</th>      <td>nonrobust</td>    <th>                     </th>      <td> </td>    
</tr>
</table>
<table class="simpletable">
<tr>
              <td></td>                <th>coef</th>     <th>std err</th>      <th>t</th>      <th>P>|t|</th>  <th>[0.025</th>    <th>0.975]</th>  
</tr>
<tr>
  <th>Intercept</th>                <td>   -0.0563</td> <td>    0.004</td> <td>  -14.220</td> <td> 0.000</td> <td>   -0.064</td> <td>   -0.049</td>
</tr>
<tr>
  <th>C(key)[T.1]</th>              <td>   -0.0449</td> <td>    0.001</td> <td>  -52.124</td> <td> 0.000</td> <td>   -0.047</td> <td>   -0.043</td>
</tr>
<tr>
  <th>C(key)[T.2]</th>              <td>    0.0007</td> <td>    0.001</td> <td>    0.953</td> <td> 0.341</td> <td>   -0.001</td> <td>    0.002</td>
</tr>
<tr>
  <th>C(key)[T.3]</th>              <td>    0.0023</td> <td>    0.001</td> <td>    1.959</td> <td> 0.050</td> <td>-1.03e-06</td> <td>    0.005</td>
</tr>
<tr>
  <th>C(key)[T.4]</th>              <td>   -0.0048</td> <td>    0.001</td> <td>   -5.570</td> <td> 0.000</td> <td>   -0.006</td> <td>   -0.003</td>
</tr>
<tr>
  <th>C(key)[T.5]</th>              <td>    0.0091</td> <td>    0.001</td> <td>   10.731</td> <td> 0.000</td> <td>    0.007</td> <td>    0.011</td>
</tr>
<tr>
  <th>C(key)[T.6]</th>              <td>   -0.0104</td> <td>    0.001</td> <td>  -10.490</td> <td> 0.000</td> <td>   -0.012</td> <td>   -0.008</td>
</tr>
<tr>
  <th>C(key)[T.7]</th>              <td>    0.0059</td> <td>    0.001</td> <td>    7.926</td> <td> 0.000</td> <td>    0.004</td> <td>    0.007</td>
</tr>
<tr>
  <th>C(key)[T.8]</th>              <td>   -0.0181</td> <td>    0.001</td> <td>  -18.617</td> <td> 0.000</td> <td>   -0.020</td> <td>   -0.016</td>
</tr>
<tr>
  <th>C(key)[T.9]</th>              <td>    0.0092</td> <td>    0.001</td> <td>   11.749</td> <td> 0.000</td> <td>    0.008</td> <td>    0.011</td>
</tr>
<tr>
  <th>C(key)[T.10]</th>             <td>   -0.0006</td> <td>    0.001</td> <td>   -0.663</td> <td> 0.507</td> <td>   -0.002</td> <td>    0.001</td>
</tr>
<tr>
  <th>C(key)[T.11]</th>             <td>   -0.0084</td> <td>    0.001</td> <td>   -9.196</td> <td> 0.000</td> <td>   -0.010</td> <td>   -0.007</td>
</tr>
<tr>
  <th>C(mode)[T.1]</th>             <td>    0.0267</td> <td>    0.000</td> <td>   63.718</td> <td> 0.000</td> <td>    0.026</td> <td>    0.027</td>
</tr>
<tr>
  <th>C(time_signature)[T.1.0]</th> <td>    0.0197</td> <td>    0.004</td> <td>    4.605</td> <td> 0.000</td> <td>    0.011</td> <td>    0.028</td>
</tr>
<tr>
  <th>C(time_signature)[T.3.0]</th> <td>    0.0079</td> <td>    0.004</td> <td>    1.939</td> <td> 0.053</td> <td>-8.53e-05</td> <td>    0.016</td>
</tr>
<tr>
  <th>C(time_signature)[T.4.0]</th> <td>    0.0206</td> <td>    0.004</td> <td>    5.116</td> <td> 0.000</td> <td>    0.013</td> <td>    0.029</td>
</tr>
<tr>
  <th>C(time_signature)[T.5.0]</th> <td>   -0.0034</td> <td>    0.004</td> <td>   -0.817</td> <td> 0.414</td> <td>   -0.012</td> <td>    0.005</td>
</tr>
<tr>
  <th>danceability</th>             <td>    0.6685</td> <td>    0.001</td> <td>  588.532</td> <td> 0.000</td> <td>    0.666</td> <td>    0.671</td>
</tr>
<tr>
  <th>energy</th>                   <td>    0.2029</td> <td>    0.001</td> <td>  271.337</td> <td> 0.000</td> <td>    0.201</td> <td>    0.204</td>
</tr>
<tr>
  <th>speechiness</th>              <td>   -0.1116</td> <td>    0.002</td> <td>  -64.293</td> <td> 0.000</td> <td>   -0.115</td> <td>   -0.108</td>
</tr>
<tr>
  <th>instrumentalness</th>         <td>   -0.0549</td> <td>    0.001</td> <td> -101.521</td> <td> 0.000</td> <td>   -0.056</td> <td>   -0.054</td>
</tr>
<tr>
  <th>liveness</th>                 <td>    0.0503</td> <td>    0.001</td> <td>   45.666</td> <td> 0.000</td> <td>    0.048</td> <td>    0.052</td>
</tr>
<tr>
  <th>tempo</th>                    <td>    0.0007</td> <td> 6.46e-06</td> <td>  105.880</td> <td> 0.000</td> <td>    0.001</td> <td>    0.001</td>
</tr>
<tr>
  <th>duration_ms</th>              <td>-1.893e-07</td> <td> 1.19e-09</td> <td> -159.408</td> <td> 0.000</td> <td>-1.92e-07</td> <td>-1.87e-07</td>
</tr>
</table>
<table class="simpletable">
<tr>
  <th>Omnibus:</th>       <td>5304.896</td> <th>  Durbin-Watson:     </th> <td>   1.330</td>
</tr>
<tr>
  <th>Prob(Omnibus):</th>  <td> 0.000</td>  <th>  Jarque-Bera (JB):  </th> <td>5063.674</td>
</tr>
<tr>
  <th>Skew:</th>           <td> 0.135</td>  <th>  Prob(JB):          </th> <td>    0.00</td>
</tr>
<tr>
  <th>Kurtosis:</th>       <td> 2.832</td>  <th>  Cond. No.          </th> <td>1.41e+07</td>
</tr>
</table><br/><br/>Notes:<br/>[1] Standard Errors assume that the covariance matrix of the errors is correctly specified.<br/>[2] The condition number is large, 1.41e+07. This might indicate that there are<br/>strong multicollinearity or other numerical problems.



### We perform the shapiro test to check for the Normality of the residuals. As p-value<0.05, which is our level of significance, we reject Ho that residuals are Normally Distributed.


```python
from scipy.stats import shapiro
# normality test
stat, p = shapiro(m1.resid.to_frame())
print('Statistics=%.3f, p=%.3f' % (stat, p))
# interpret
alpha = 0.05
if p > alpha:
	print('Sample looks Gaussian (fail to reject H0)')
else:
	print('Sample does not look Gaussian (reject H0)')
```

    Statistics=0.998, p=0.000
    Sample does not look Gaussian (reject H0)
    

    C:\Users\sgsid\anaconda3\lib\site-packages\scipy\stats\morestats.py:1681: UserWarning: p-value may not be accurate for N > 5000.
    

### We use the QQ plot to check the Normality of residuals in order to be sure. Residuals are not normal in the tails.


```python
ggplot(data=m1.resid.to_frame().rename(columns={0: 'resid'})) +\
    geom_qq(mapping=aes(sample='resid')) +\
    geom_qq_line(mapping=aes(sample='resid'))
```


    
![png](README_files/README_52_0.png)
    





    <ggplot: (126839360061)>



### We plot the residuals against the fitted values to see if there is constant variance. Heteroscedasticity problem exists.


```python
#plot residuals against fitted values
plt.figure(figsize=(10,10))
_ = plt.scatter(m1.fittedvalues, m1.resid)
plt.axhline(y=0, color='black', linestyle='--')
plt.xlabel('yhat')
plt.ylabel('Residuals') 
```




    Text(0, 0.5, 'Residuals')




    
![png](README_files/README_54_1.png)
    


### We plot the fitted values against the true values to see if there is non-linearity of residuals. It is clear that non-linearity exists.


```python
plt.figure(figsize=(10,10))
plt.scatter(data.valence, m1.fittedvalues, c='black')
p1 = max(max(m1.fittedvalues), max(data.valence))
p2 = min(min(m1.fittedvalues), min(data.valence))
plt.plot([p1, p2], [p1, p2], 'b-')
plt.xlabel('True Values', fontsize=15)
plt.ylabel('Predictions', fontsize=15)
plt.axis('equal')
plt.show()
```


    
![png](README_files/README_56_0.png)
    


### Check for Autocorrelation with the following autocorrelation plot included in staticmodels and the Durbin-Watson test. It seems that autocorrelation exists as durbin-watson test-value is not between [1.5,2.5] and residuals follow a pattern.


```python
_ = sm.graphics.tsa.plot_acf(m1.resid, lags=40, alpha=0.05)
```


    
![png](README_files/README_58_0.png)
    



```python
from statsmodels.stats.stattools import durbin_watson
#perform Durbin-Watson test
durbin_watson(m1.resid)
```




    1.3295492181362332



## Try to improve Assumptions

### Normality Assumption is usually fixed by using Log or Square root transformation of the targeted variable. As valence takes values in [0,1] log transformation is not possible and we will continue with the Square root transformation.


```python
#create log-transformed data
data2 = data1.copy()
data2['valence_trans'] = np.sqrt(data2.valence)
data2 = data2.drop('valence',axis=1)
```


```python
m2 = smf.ols(formula='valence_trans ~ danceability + energy + C(key) + C(mode) + speechiness + instrumentalness + liveness + tempo + duration_ms + C(time_signature)', data=data2).fit()
m2.summary()
```




<table class="simpletable">
<caption>OLS Regression Results</caption>
<tr>
  <th>Dep. Variable:</th>      <td>valence_trans</td>  <th>  R-squared:         </th>  <td>   0.460</td> 
</tr>
<tr>
  <th>Model:</th>                   <td>OLS</td>       <th>  Adj. R-squared:    </th>  <td>   0.460</td> 
</tr>
<tr>
  <th>Method:</th>             <td>Least Squares</td>  <th>  F-statistic:       </th>  <td>4.461e+04</td>
</tr>
<tr>
  <th>Date:</th>             <td>Sun, 06 Mar 2022</td> <th>  Prob (F-statistic):</th>   <td>  0.00</td>  
</tr>
<tr>
  <th>Time:</th>                 <td>22:41:00</td>     <th>  Log-Likelihood:    </th> <td>4.3463e+05</td>
</tr>
<tr>
  <th>No. Observations:</th>      <td>1204025</td>     <th>  AIC:               </th> <td>-8.692e+05</td>
</tr>
<tr>
  <th>Df Residuals:</th>          <td>1204001</td>     <th>  BIC:               </th> <td>-8.689e+05</td>
</tr>
<tr>
  <th>Df Model:</th>              <td>    23</td>      <th>                     </th>      <td> </td>    
</tr>
<tr>
  <th>Covariance Type:</th>      <td>nonrobust</td>    <th>                     </th>      <td> </td>    
</tr>
</table>
<table class="simpletable">
<tr>
              <td></td>                <th>coef</th>     <th>std err</th>      <th>t</th>      <th>P>|t|</th>  <th>[0.025</th>    <th>0.975]</th>  
</tr>
<tr>
  <th>Intercept</th>                <td>   -0.0435</td> <td>    0.003</td> <td>  -13.482</td> <td> 0.000</td> <td>   -0.050</td> <td>   -0.037</td>
</tr>
<tr>
  <th>C(key)[T.1]</th>              <td>   -0.0374</td> <td>    0.001</td> <td>  -53.317</td> <td> 0.000</td> <td>   -0.039</td> <td>   -0.036</td>
</tr>
<tr>
  <th>C(key)[T.2]</th>              <td>    0.0017</td> <td>    0.001</td> <td>    2.701</td> <td> 0.007</td> <td>    0.000</td> <td>    0.003</td>
</tr>
<tr>
  <th>C(key)[T.3]</th>              <td>    0.0029</td> <td>    0.001</td> <td>    3.082</td> <td> 0.002</td> <td>    0.001</td> <td>    0.005</td>
</tr>
<tr>
  <th>C(key)[T.4]</th>              <td>   -0.0034</td> <td>    0.001</td> <td>   -4.860</td> <td> 0.000</td> <td>   -0.005</td> <td>   -0.002</td>
</tr>
<tr>
  <th>C(key)[T.5]</th>              <td>    0.0068</td> <td>    0.001</td> <td>    9.826</td> <td> 0.000</td> <td>    0.005</td> <td>    0.008</td>
</tr>
<tr>
  <th>C(key)[T.6]</th>              <td>   -0.0088</td> <td>    0.001</td> <td>  -10.894</td> <td> 0.000</td> <td>   -0.010</td> <td>   -0.007</td>
</tr>
<tr>
  <th>C(key)[T.7]</th>              <td>    0.0055</td> <td>    0.001</td> <td>    8.985</td> <td> 0.000</td> <td>    0.004</td> <td>    0.007</td>
</tr>
<tr>
  <th>C(key)[T.8]</th>              <td>   -0.0153</td> <td>    0.001</td> <td>  -19.315</td> <td> 0.000</td> <td>   -0.017</td> <td>   -0.014</td>
</tr>
<tr>
  <th>C(key)[T.9]</th>              <td>    0.0083</td> <td>    0.001</td> <td>   12.990</td> <td> 0.000</td> <td>    0.007</td> <td>    0.010</td>
</tr>
<tr>
  <th>C(key)[T.10]</th>             <td>   -0.0012</td> <td>    0.001</td> <td>   -1.563</td> <td> 0.118</td> <td>   -0.003</td> <td>    0.000</td>
</tr>
<tr>
  <th>C(key)[T.11]</th>             <td>   -0.0064</td> <td>    0.001</td> <td>   -8.564</td> <td> 0.000</td> <td>   -0.008</td> <td>   -0.005</td>
</tr>
<tr>
  <th>C(mode)[T.1]</th>             <td>    0.0222</td> <td>    0.000</td> <td>   65.108</td> <td> 0.000</td> <td>    0.022</td> <td>    0.023</td>
</tr>
<tr>
  <th>C(time_signature)[T.1.0]</th> <td>    0.2469</td> <td>    0.003</td> <td>   70.946</td> <td> 0.000</td> <td>    0.240</td> <td>    0.254</td>
</tr>
<tr>
  <th>C(time_signature)[T.3.0]</th> <td>    0.2428</td> <td>    0.003</td> <td>   73.598</td> <td> 0.000</td> <td>    0.236</td> <td>    0.249</td>
</tr>
<tr>
  <th>C(time_signature)[T.4.0]</th> <td>    0.2537</td> <td>    0.003</td> <td>   77.227</td> <td> 0.000</td> <td>    0.247</td> <td>    0.260</td>
</tr>
<tr>
  <th>C(time_signature)[T.5.0]</th> <td>    0.2252</td> <td>    0.003</td> <td>   66.116</td> <td> 0.000</td> <td>    0.219</td> <td>    0.232</td>
</tr>
<tr>
  <th>danceability</th>             <td>    0.5795</td> <td>    0.001</td> <td>  626.143</td> <td> 0.000</td> <td>    0.578</td> <td>    0.581</td>
</tr>
<tr>
  <th>energy</th>                   <td>    0.1740</td> <td>    0.001</td> <td>  285.605</td> <td> 0.000</td> <td>    0.173</td> <td>    0.175</td>
</tr>
<tr>
  <th>speechiness</th>              <td>   -0.0947</td> <td>    0.001</td> <td>  -66.944</td> <td> 0.000</td> <td>   -0.097</td> <td>   -0.092</td>
</tr>
<tr>
  <th>instrumentalness</th>         <td>   -0.0620</td> <td>    0.000</td> <td> -140.721</td> <td> 0.000</td> <td>   -0.063</td> <td>   -0.061</td>
</tr>
<tr>
  <th>liveness</th>                 <td>    0.0533</td> <td>    0.001</td> <td>   59.308</td> <td> 0.000</td> <td>    0.051</td> <td>    0.055</td>
</tr>
<tr>
  <th>tempo</th>                    <td>    0.0006</td> <td> 5.27e-06</td> <td>  120.648</td> <td> 0.000</td> <td>    0.001</td> <td>    0.001</td>
</tr>
<tr>
  <th>duration_ms</th>              <td>-1.661e-07</td> <td> 9.68e-10</td> <td> -171.665</td> <td> 0.000</td> <td>-1.68e-07</td> <td>-1.64e-07</td>
</tr>
</table>
<table class="simpletable">
<tr>
  <th>Omnibus:</th>       <td>11673.425</td> <th>  Durbin-Watson:     </th> <td>   1.325</td> 
</tr>
<tr>
  <th>Prob(Omnibus):</th>  <td> 0.000</td>   <th>  Jarque-Bera (JB):  </th> <td>12043.601</td>
</tr>
<tr>
  <th>Skew:</th>           <td>-0.239</td>   <th>  Prob(JB):          </th> <td>    0.00</td> 
</tr>
<tr>
  <th>Kurtosis:</th>       <td> 3.108</td>   <th>  Cond. No.          </th> <td>1.41e+07</td> 
</tr>
</table><br/><br/>Notes:<br/>[1] Standard Errors assume that the covariance matrix of the errors is correctly specified.<br/>[2] The condition number is large, 1.41e+07. This might indicate that there are<br/>strong multicollinearity or other numerical problems.



### The normality seems to be improved but residuals are still not normal. The interpretation of the model also becomes difficult.


```python
ggplot(data=m2.resid.to_frame().rename(columns={0: 'resid'})) +\
    geom_qq(mapping=aes(sample='resid')) +\
    geom_qq_line(mapping=aes(sample='resid'))
```


    
![png](README_files/README_65_0.png)
    





    <ggplot: (126839498734)>



### We will try to add polynomials to numeric variables affecting valence the most, in order to try and improve non-linearity problem. We reach up to polynomial of 4th degree. Rsquared is improved to 0.48 but the interpretation of the model becomes very difficult.


```python
m3 = smf.ols(formula='valence_trans ~ danceability + np.power(danceability, 2) + np.power(danceability, 3)+np.power(danceability, 4)+ energy + np.power(energy, 2)+ np.power(energy, 3)+np.power(energy, 4) + C(key) + C(mode) + speechiness+np.power(speechiness, 2)+np.power(speechiness, 3)+np.power(speechiness, 4)  + instrumentalness+np.power(instrumentalness, 2)+np.power(instrumentalness, 3)++np.power(instrumentalness, 4) + liveness + np.power(liveness, 2)+ liveness + np.power(liveness, 3)+np.power(liveness, 4) +tempo + duration_ms + C(time_signature)', data=data2).fit()
m3.summary()
```




<table class="simpletable">
<caption>OLS Regression Results</caption>
<tr>
  <th>Dep. Variable:</th>      <td>valence_trans</td>  <th>  R-squared:         </th>  <td>   0.481</td> 
</tr>
<tr>
  <th>Model:</th>                   <td>OLS</td>       <th>  Adj. R-squared:    </th>  <td>   0.481</td> 
</tr>
<tr>
  <th>Method:</th>             <td>Least Squares</td>  <th>  F-statistic:       </th>  <td>2.940e+04</td>
</tr>
<tr>
  <th>Date:</th>             <td>Sun, 06 Mar 2022</td> <th>  Prob (F-statistic):</th>   <td>  0.00</td>  
</tr>
<tr>
  <th>Time:</th>                 <td>22:41:46</td>     <th>  Log-Likelihood:    </th> <td>4.5876e+05</td>
</tr>
<tr>
  <th>No. Observations:</th>      <td>1204025</td>     <th>  AIC:               </th> <td>-9.174e+05</td>
</tr>
<tr>
  <th>Df Residuals:</th>          <td>1203986</td>     <th>  BIC:               </th> <td>-9.170e+05</td>
</tr>
<tr>
  <th>Df Model:</th>              <td>    38</td>      <th>                     </th>      <td> </td>    
</tr>
<tr>
  <th>Covariance Type:</th>      <td>nonrobust</td>    <th>                     </th>      <td> </td>    
</tr>
</table>
<table class="simpletable">
<tr>
                <td></td>                   <th>coef</th>     <th>std err</th>      <th>t</th>      <th>P>|t|</th>  <th>[0.025</th>    <th>0.975]</th>  
</tr>
<tr>
  <th>Intercept</th>                     <td>   -0.0490</td> <td>    0.003</td> <td>  -14.943</td> <td> 0.000</td> <td>   -0.055</td> <td>   -0.043</td>
</tr>
<tr>
  <th>C(key)[T.1]</th>                   <td>   -0.0305</td> <td>    0.001</td> <td>  -44.228</td> <td> 0.000</td> <td>   -0.032</td> <td>   -0.029</td>
</tr>
<tr>
  <th>C(key)[T.2]</th>                   <td>    0.0018</td> <td>    0.001</td> <td>    2.909</td> <td> 0.004</td> <td>    0.001</td> <td>    0.003</td>
</tr>
<tr>
  <th>C(key)[T.3]</th>                   <td>    0.0056</td> <td>    0.001</td> <td>    5.986</td> <td> 0.000</td> <td>    0.004</td> <td>    0.007</td>
</tr>
<tr>
  <th>C(key)[T.4]</th>                   <td>   -0.0032</td> <td>    0.001</td> <td>   -4.673</td> <td> 0.000</td> <td>   -0.005</td> <td>   -0.002</td>
</tr>
<tr>
  <th>C(key)[T.5]</th>                   <td>    0.0080</td> <td>    0.001</td> <td>   11.735</td> <td> 0.000</td> <td>    0.007</td> <td>    0.009</td>
</tr>
<tr>
  <th>C(key)[T.6]</th>                   <td>   -0.0049</td> <td>    0.001</td> <td>   -6.243</td> <td> 0.000</td> <td>   -0.006</td> <td>   -0.003</td>
</tr>
<tr>
  <th>C(key)[T.7]</th>                   <td>    0.0060</td> <td>    0.001</td> <td>    9.976</td> <td> 0.000</td> <td>    0.005</td> <td>    0.007</td>
</tr>
<tr>
  <th>C(key)[T.8]</th>                   <td>   -0.0111</td> <td>    0.001</td> <td>  -14.273</td> <td> 0.000</td> <td>   -0.013</td> <td>   -0.010</td>
</tr>
<tr>
  <th>C(key)[T.9]</th>                   <td>    0.0079</td> <td>    0.001</td> <td>   12.548</td> <td> 0.000</td> <td>    0.007</td> <td>    0.009</td>
</tr>
<tr>
  <th>C(key)[T.10]</th>                  <td>    0.0020</td> <td>    0.001</td> <td>    2.668</td> <td> 0.008</td> <td>    0.001</td> <td>    0.003</td>
</tr>
<tr>
  <th>C(key)[T.11]</th>                  <td>   -0.0034</td> <td>    0.001</td> <td>   -4.625</td> <td> 0.000</td> <td>   -0.005</td> <td>   -0.002</td>
</tr>
<tr>
  <th>C(mode)[T.1]</th>                  <td>    0.0200</td> <td>    0.000</td> <td>   59.674</td> <td> 0.000</td> <td>    0.019</td> <td>    0.021</td>
</tr>
<tr>
  <th>C(time_signature)[T.1.0]</th>      <td>    0.2268</td> <td>    0.004</td> <td>   53.752</td> <td> 0.000</td> <td>    0.219</td> <td>    0.235</td>
</tr>
<tr>
  <th>C(time_signature)[T.3.0]</th>      <td>    0.2216</td> <td>    0.004</td> <td>   54.364</td> <td> 0.000</td> <td>    0.214</td> <td>    0.230</td>
</tr>
<tr>
  <th>C(time_signature)[T.4.0]</th>      <td>    0.2324</td> <td>    0.004</td> <td>   57.205</td> <td> 0.000</td> <td>    0.224</td> <td>    0.240</td>
</tr>
<tr>
  <th>C(time_signature)[T.5.0]</th>      <td>    0.2055</td> <td>    0.004</td> <td>   49.419</td> <td> 0.000</td> <td>    0.197</td> <td>    0.214</td>
</tr>
<tr>
  <th>danceability</th>                  <td>    0.5455</td> <td>    0.027</td> <td>   20.308</td> <td> 0.000</td> <td>    0.493</td> <td>    0.598</td>
</tr>
<tr>
  <th>np.power(danceability, 2)</th>     <td>    0.8648</td> <td>    0.096</td> <td>    9.024</td> <td> 0.000</td> <td>    0.677</td> <td>    1.053</td>
</tr>
<tr>
  <th>np.power(danceability, 3)</th>     <td>   -1.6190</td> <td>    0.138</td> <td>  -11.715</td> <td> 0.000</td> <td>   -1.890</td> <td>   -1.348</td>
</tr>
<tr>
  <th>np.power(danceability, 4)</th>     <td>    0.7030</td> <td>    0.069</td> <td>   10.155</td> <td> 0.000</td> <td>    0.567</td> <td>    0.839</td>
</tr>
<tr>
  <th>energy</th>                        <td>    0.8218</td> <td>    0.010</td> <td>   79.340</td> <td> 0.000</td> <td>    0.801</td> <td>    0.842</td>
</tr>
<tr>
  <th>np.power(energy, 2)</th>           <td>   -3.0396</td> <td>    0.042</td> <td>  -71.898</td> <td> 0.000</td> <td>   -3.122</td> <td>   -2.957</td>
</tr>
<tr>
  <th>np.power(energy, 3)</th>           <td>    5.3920</td> <td>    0.064</td> <td>   84.636</td> <td> 0.000</td> <td>    5.267</td> <td>    5.517</td>
</tr>
<tr>
  <th>np.power(energy, 4)</th>           <td>   -3.0684</td> <td>    0.032</td> <td>  -96.824</td> <td> 0.000</td> <td>   -3.130</td> <td>   -3.006</td>
</tr>
<tr>
  <th>speechiness</th>                   <td>   -0.0849</td> <td>    0.015</td> <td>   -5.693</td> <td> 0.000</td> <td>   -0.114</td> <td>   -0.056</td>
</tr>
<tr>
  <th>np.power(speechiness, 2)</th>      <td>   -0.8151</td> <td>    0.084</td> <td>   -9.700</td> <td> 0.000</td> <td>   -0.980</td> <td>   -0.650</td>
</tr>
<tr>
  <th>np.power(speechiness, 3)</th>      <td>    2.4163</td> <td>    0.162</td> <td>   14.873</td> <td> 0.000</td> <td>    2.098</td> <td>    2.735</td>
</tr>
<tr>
  <th>np.power(speechiness, 4)</th>      <td>   -1.5654</td> <td>    0.097</td> <td>  -16.139</td> <td> 0.000</td> <td>   -1.756</td> <td>   -1.375</td>
</tr>
<tr>
  <th>instrumentalness</th>              <td>   -0.3237</td> <td>    0.009</td> <td>  -34.799</td> <td> 0.000</td> <td>   -0.342</td> <td>   -0.305</td>
</tr>
<tr>
  <th>np.power(instrumentalness, 2)</th> <td>    1.2127</td> <td>    0.048</td> <td>   25.009</td> <td> 0.000</td> <td>    1.118</td> <td>    1.308</td>
</tr>
<tr>
  <th>np.power(instrumentalness, 3)</th> <td>   -1.8548</td> <td>    0.081</td> <td>  -23.010</td> <td> 0.000</td> <td>   -2.013</td> <td>   -1.697</td>
</tr>
<tr>
  <th>np.power(instrumentalness, 4)</th> <td>    0.9340</td> <td>    0.042</td> <td>   22.138</td> <td> 0.000</td> <td>    0.851</td> <td>    1.017</td>
</tr>
<tr>
  <th>liveness</th>                      <td>   -0.5962</td> <td>    0.015</td> <td>  -39.158</td> <td> 0.000</td> <td>   -0.626</td> <td>   -0.566</td>
</tr>
<tr>
  <th>np.power(liveness, 2)</th>         <td>    3.1131</td> <td>    0.068</td> <td>   46.049</td> <td> 0.000</td> <td>    2.981</td> <td>    3.246</td>
</tr>
<tr>
  <th>np.power(liveness, 3)</th>         <td>   -5.1195</td> <td>    0.109</td> <td>  -46.802</td> <td> 0.000</td> <td>   -5.334</td> <td>   -4.905</td>
</tr>
<tr>
  <th>np.power(liveness, 4)</th>         <td>    2.6391</td> <td>    0.058</td> <td>   45.875</td> <td> 0.000</td> <td>    2.526</td> <td>    2.752</td>
</tr>
<tr>
  <th>tempo</th>                         <td>    0.0006</td> <td> 5.22e-06</td> <td>  114.184</td> <td> 0.000</td> <td>    0.001</td> <td>    0.001</td>
</tr>
<tr>
  <th>duration_ms</th>                   <td>-1.637e-07</td> <td> 9.61e-10</td> <td> -170.450</td> <td> 0.000</td> <td>-1.66e-07</td> <td>-1.62e-07</td>
</tr>
</table>
<table class="simpletable">
<tr>
  <th>Omnibus:</th>       <td>14892.689</td> <th>  Durbin-Watson:     </th> <td>   1.343</td> 
</tr>
<tr>
  <th>Prob(Omnibus):</th>  <td> 0.000</td>   <th>  Jarque-Bera (JB):  </th> <td>15520.795</td>
</tr>
<tr>
  <th>Skew:</th>           <td>-0.269</td>   <th>  Prob(JB):          </th> <td>    0.00</td> 
</tr>
<tr>
  <th>Kurtosis:</th>       <td> 3.144</td>   <th>  Cond. No.          </th> <td>4.07e+08</td> 
</tr>
</table><br/><br/>Notes:<br/>[1] Standard Errors assume that the covariance matrix of the errors is correctly specified.<br/>[2] The condition number is large, 4.07e+08. This might indicate that there are<br/>strong multicollinearity or other numerical problems.



### Non linearity problem is not fixed.


```python
plt.figure(figsize=(10,10))
plt.scatter(data.valence, m3.fittedvalues, c='black')
p1 = max(max(m3.fittedvalues), max(data.valence))
p2 = min(min(m3.fittedvalues), min(data.valence))
plt.plot([p1, p2], [p1, p2], 'b-')
plt.xlabel('True Values', fontsize=15)
plt.ylabel('Predictions', fontsize=15)
plt.axis('equal')
plt.show()
```


    
![png](README_files/README_69_0.png)
    


## Best model choice

### We will use anova to choose for the best model between m2 & m3. We reject Ho that the two models fit data equally well, so our best model is m3.


```python
table = sm.stats.anova_lm(m2,m3)
table
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
      <th>df_resid</th>
      <th>ssr</th>
      <th>df_diff</th>
      <th>ss_diff</th>
      <th>F</th>
      <th>Pr(&gt;F)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1204001.0</td>
      <td>34246.407640</td>
      <td>0.0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>1203986.0</td>
      <td>32901.047175</td>
      <td>15.0</td>
      <td>1345.360465</td>
      <td>3282.155237</td>
      <td>0.0</td>
    </tr>
  </tbody>
</table>
</div>



## Conclusion

### We used the ols regression as the only achievable alternative. The assumptions needed are violated and we tried to improve them with target variable square root transformation and polynomial terms but it has no effect. The final model explains the difference between actual and predicted values by 48% but it will fail to fit accurately on different data as assumptions are rejected. The interpretation of the model after all the transformations is very difficult to perform but in general, it seems that danceability, energy (positively) and instrumentalness, liveness (negatively) describe valence the most. 

# Q2: Predict Valence using 3 Machine Learning methods

### We will take a random sample from the dataset as the computational power of our computer is not enough to handle fast such a size of data for machine learning methods. The sample includes 200.000 observations.


```python
#taking sample
data_sample = data.sample(200000)
```

### We will create dummy variables for the categorical variables key, mode and time_signature. 


```python
# create dummies 
data_sample = pd.get_dummies(data_sample, columns=['key'], drop_first=True)
data_sample = pd.get_dummies(data_sample, columns=['mode'], drop_first=True)
data_sample = pd.get_dummies(data_sample, columns=['time_signature'], drop_first=True)
```

### As valence is a continuous variable we should use regression machine learning methods for prediction, but as the majority of ML methods been taught are for classification and we need at least three of them, we will also proceed with classification machine learning methods. As a result, we will perform a regression method based on the one been taught and 3 classification methods of our choice.

## For the Regression approach:

## 1) Random Forest

### We will separate our dataset to training and testing datasets to avoid overfitting. The testing dataset will be 25% of the initial.


```python
data3 = data_sample.copy()
# Get 2 dataframes with the values of independent and dependent variables
X1, y1 = (data3.loc[:, data3.columns != 'valence'].values, 
        data3['valence'].values)

# Split them both into a training and a testing set
# Test set will be the 25% of the initials taken randomly
X_train1, X_test1, y_train1, y_test1 = train_test_split(X1, y1, test_size=0.25, 
                                                    random_state=33)
```

### The method creates split points based on the variance reduction each split produces (variance reduction must be maximized) until a max depth of splits is performed. The collection of trees is uncorrelated and not affected by a very strong predictor in the data set offering us completely different trees. The method has an accuracy on prediction of 53% and a mean absolute error of 14.48%.


```python
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import cross_val_score
#the method
clf = RandomForestRegressor(n_estimators = 50, max_depth=None,min_samples_split=2, random_state = 0,n_jobs=-1)
#train the method
clf.fit(X_train1, y_train1)
#cross validation
feature_cols = [ col for col in data3.columns if col != 'valence' ]
scores = cross_val_score(clf, data3.loc[:, feature_cols], 
                         data3['valence'], cv=5)
#accuracy score
scores.mean()
```




    0.5339919008277978




```python
#predictions
y_pred = clf.predict(X_test1)
```

### We will use the Mean Absolute Error to evaluate our model


```python
#metric mae
mae = metrics.mean_absolute_error(y_pred,y_test1)
print(f'Mean Absolute Error: {mae}')
```

    Mean Absolute Error: 0.14476871331600003
    

## Importance of variables for best Regression model:

### We get an overall summary of the importance of each predictor in our best model. Danceability and energy are by far the most important features explaining valence, with danceability explaining it by 34% and energy by 16%. It seems that dancing and full of energy songs are happier than other songs. Also, it seems that the ML method is not affected by the pairwised correlation between energy and acousticness which we faced and dealt with in our statistical model by dropping acousticness and loudness in order to avoid multicollinearity.


```python
#importance of each feature
importances = clf.feature_importances_

std = np.std([tree.feature_importances_ for tree in clf.estimators_],
             axis=0)
indices = np.argsort(importances)[::-1]

for f in range(X_train1.shape[1]):
    print("%d. feature %d %s (%f)" % (f + 1, indices[f], feature_cols[indices[f]], importances[indices[f]]))
```

    1. feature 0 danceability (0.344185)
    2. feature 1 energy (0.158752)
    3. feature 8 duration_ms (0.083567)
    4. feature 4 acousticness (0.068589)
    5. feature 3 speechiness (0.067584)
    6. feature 7 tempo (0.063799)
    7. feature 2 loudness (0.058712)
    8. feature 5 instrumentalness (0.054226)
    9. feature 6 liveness (0.054152)
    10. feature 20 mode_1 (0.006361)
    11. feature 15 key_7 (0.004090)
    12. feature 10 key_2 (0.004062)
    13. feature 9 key_1 (0.003780)
    14. feature 17 key_9 (0.003616)
    15. feature 13 key_5 (0.003114)
    16. feature 12 key_4 (0.002822)
    17. feature 19 key_11 (0.002801)
    18. feature 18 key_10 (0.002649)
    19. feature 14 key_6 (0.002577)
    20. feature 16 key_8 (0.002567)
    21. feature 23 time_signature_4.0 (0.002540)
    22. feature 22 time_signature_3.0 (0.002056)
    23. feature 11 key_3 (0.001600)
    24. feature 24 time_signature_5.0 (0.000994)
    25. feature 21 time_signature_1.0 (0.000804)
    

### We also plot the importances.


```python
#plot of features
plt.figure(figsize=(10, 8))
plt.title("Feature importances")
plt.bar(range(X_train1.shape[1]), importances[indices],
        tick_label=[feature_cols[x] for x in indices],
        color="r", yerr=std[indices], align="center")
plt.xlim([-1, X_train1.shape[1]])
_ = plt.xticks(rotation=45)
```


    
![png](README_files/README_94_0.png)
    


## For the Classification approach:

### We will scale our numeric variables on a second dataset as they differ in variance which affects the methods we will use later.


```python
#the predictors before scaling
_ = data_sample[['danceability','energy','loudness','speechiness','acousticness','instrumentalness','liveness','tempo','duration_ms']].hist(bins=20, figsize=(12, 4))
```


    
![png](README_files/README_97_0.png)
    



```python
#scale them
from sklearn.preprocessing import StandardScaler
data4 = data_sample.copy()
scaler = StandardScaler()
scaler.fit(data4[['danceability','energy','loudness','speechiness','acousticness','instrumentalness','liveness','tempo','duration_ms']])
data4[['danceability','energy','loudness','speechiness','acousticness','instrumentalness','liveness','tempo','duration_ms']] = scaler.transform(data4[['danceability','energy','loudness','speechiness','acousticness','instrumentalness','liveness','tempo','duration_ms']])

```

### The features now have mean 0 and variance 1.


```python
#the predictors after scaling
_ = data4[['danceability','energy','loudness','speechiness','acousticness','instrumentalness','liveness','tempo','duration_ms']].hist(bins=20, figsize=(12, 4))
```


    
![png](README_files/README_100_0.png)
    


### Then, we must first convert valence to a categorical variable and split it to ordered levels. We split it to 4 ordered levels: sad - melancholic - uplifting - joyful, according to track's mood.


```python
#insert new column with labels
bins =[0,0.25,0.5,0.75,1]
data4['valence_cat'] = pd.cut(data4.valence,bins,include_lowest=True,labels=['sad','melancholic','uplifting','joyful'])
#turn labels to ordered numbers 
data4['valence_cat'] = data4['valence_cat'].astype('category')
data4['valence_cat'] = data4['valence_cat'].cat.codes
#drop valence column
data4 = data4.drop('valence', axis=1)
```

### We will separate our dataset to training and testing datasets to avoid overfitting. The testing dataset will be 25% of the initial.


```python
# Get 2 dataframes with the values of independent and dependent variables
X2, y2 = (data4.loc[:, data4.columns != 'valence_cat'].values, 
        data4['valence_cat'].values)

# Split them both into a training and a testing set
# Test set will be the 25% of the initials taken randomly
X_train2, X_test2, y_train2, y_test2 = train_test_split(X2, y2, test_size=0.25, 
                                                    random_state=33)
```

## 1) Stochastic Gradient Descent Classification

### The method tries to find a linear scoring function that will describe our data xi and its features based on some modelling parameters, so that the training error for n observations is minimized. The training error is calculated via the sum of a loss function and a regulization term that penalizes model's complexity.


```python
from sklearn.linear_model import SGDClassifier
#create model with the SGDC method
clf1 = SGDClassifier(alpha=0.001, max_iter=10000, tol=-np.inf, random_state=13,n_jobs=-1)
#train model
clf1.fit(X_train2, y_train2)
```




    SGDClassifier(alpha=0.001, max_iter=10000, n_jobs=-1, random_state=13, tol=-inf)



### We will use the Mean Absolute Error to evaluate our model


```python
#the predicted values
y_pred = clf1.predict(X_test2)
#the MAE test
mae1 = metrics.mean_absolute_error(y_pred,y_test2)
print(f'Mean Absolute Error: {mae1}')
```

    Mean Absolute Error: 0.74978
    

## 2) Gaussian Naive Bayes classifier using PCA

### We create a pipeline that will run PCA and GNBC in a sequence. Firstly, PCA will reduce the number of variables to 9 by creating 9 principal components which retain as much as possible of the characteristics of the initial dimensions. Afterwards, GNBC will segment continuous variables to classes and match the attributes of each observation to the class with the highest probability to belong, having as a scope to maximize the product of the probabilities of all attributes of an observation yi. 


```python
from sklearn.decomposition import PCA
from sklearn.pipeline import make_pipeline
from sklearn.naive_bayes import GaussianNB

#create model
clf2 = make_pipeline(PCA(n_components=9), GaussianNB())
#train model
clf2.fit(X_train2, y_train2)
#the predicted values
pred_test_std = clf2.predict(X_test2)
```

### We will use the Mean Absolute Error to evaluate our model


```python
mae2 = metrics.mean_absolute_error(y_test2, pred_test_std)
#check accuracy and MAE
print(f'Prediction accuracy: {metrics.accuracy_score(y_test2, pred_test_std):.2%}')
print(f'Mean Absolute Error: {mae2}')
```

    Prediction accuracy: 46.77%
    Mean Absolute Error: 0.70222
    

## 3) Random Forest

### Random forest method uses decision trees to perform multi-class classification on the dataset having as reference to minimize the Gini index which measures the probability that if we pick an item at random this will be classified wrongly. The collection of trees is uncorrelated and not affected by a very strong predictor in the data set offering us completely different trees.

### As scaling is not needed for this method, we will use our initial dataset of 200.000 observations after performing the appropriate transformations.


```python
data3 = data_sample.copy()
#insert new column with labels
bins =[0,0.25,0.5,0.75,1]
data3['valence_cat'] = pd.cut(data.valence,bins,include_lowest=True,labels=['sad','melancholic','uplifting','joyful'])
#turn labels to ordered numbers 
data3['valence_cat'] = data3['valence_cat'].astype('category')
data3['valence_cat'] = data3['valence_cat'].cat.codes
#drop valence column
data3 = data3.drop('valence', axis=1)
```


```python
# Get 2 dataframes with the values of independent and dependent variables
X3, y3 = (data3.loc[:, data3.columns != 'valence_cat'].values, 
        data3['valence_cat'].values)

# Split them both into a training and a testing set
# Test set will be the 25% of the initials taken randomly
X_train3, X_test3, y_train3, y_test3 = train_test_split(X3, y3, test_size=0.25, 
                                                    random_state=33)
```

### The method:


```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score
feature_cols = [ col for col in data3.columns if col != 'valence_cat' ]
#create trees
clf3 = RandomForestClassifier(n_estimators=50, max_depth=None,
                                min_samples_split=2)
#train the tree
clf3.fit(X_train3, y_train3)

#cross validation
scores = cross_val_score(clf3, data3.loc[:, feature_cols], 
                         data3['valence_cat'], cv=5)
#average accuracy
scores.mean()               
```




    0.5254099999999999



### We will use the Mean Absolute Error to evaluate our method. The Random Forest method is the best for classification.


```python
#test tree
predicted = clf3.predict(X_test3)
#mae
metrics.mean_absolute_error(y_test3,predicted)
```




    0.57976



## Importance of variables for best Classification model:

### We get an overall summary of the importance of each predictor in our best model. Danceability seems to describe valence the most on a rate of 15% being followed by energy of 12% and loudness, duration_ms, acousticness of 10% creating the top-5 of features to describe valence.  It seems that dancing and loud songs, that are full of energy and are characterized by acousticness and larger duration are happier than other songs. The classification approach gives more importance to loudness instead of speachiness in contrast to the regression model. Finally, it seems that the ML method is not affected by the pairwised correlation between energy and loudness, acousticness which we faced and dealt with in our statistical model by dropping acousticness and loudness in order to avoid multicollinearity.


```python
importances = clf3.feature_importances_

std = np.std([tree.feature_importances_ for tree in clf3.estimators_],
             axis=0)
indices = np.argsort(importances)[::-1]

for f in range(X_train3.shape[1]):
    print("%d. feature %d %s (%f)" % (f + 1, indices[f], feature_cols[indices[f]], importances[indices[f]]))
```

    1. feature 0 danceability (0.156156)
    2. feature 1 energy (0.118225)
    3. feature 2 loudness (0.098692)
    4. feature 8 duration_ms (0.095252)
    5. feature 4 acousticness (0.092826)
    6. feature 3 speechiness (0.088885)
    7. feature 7 tempo (0.088297)
    8. feature 6 liveness (0.081484)
    9. feature 5 instrumentalness (0.079916)
    10. feature 20 mode_1 (0.012000)
    11. feature 15 key_7 (0.009089)
    12. feature 10 key_2 (0.008868)
    13. feature 17 key_9 (0.008270)
    14. feature 12 key_4 (0.006976)
    15. feature 13 key_5 (0.006843)
    16. feature 9 key_1 (0.006718)
    17. feature 19 key_11 (0.006588)
    18. feature 18 key_10 (0.006194)
    19. feature 23 time_signature_4.0 (0.006183)
    20. feature 16 key_8 (0.005702)
    21. feature 14 key_6 (0.005652)
    22. feature 22 time_signature_3.0 (0.004629)
    23. feature 11 key_3 (0.003412)
    24. feature 24 time_signature_5.0 (0.001747)
    25. feature 21 time_signature_1.0 (0.001393)
    

### We also plot the importances.


```python
plt.figure(figsize=(10, 8))
plt.title("Feature importances")
plt.bar(range(X_train3.shape[1]), importances[indices],
        tick_label=[feature_cols[x] for x in indices],
        color="r", yerr=std[indices], align="center")
plt.xlim([-1, X_train3.shape[1]])
_ = plt.xticks(rotation=45)
```


    
![png](README_files/README_127_0.png)
    


## Conclusion

### Based on the Regression approach and the Random Forest Regression, the best model clf has metric mean absolute error equal to 0.14 which is very good but it is needed to be checked with an out of sample in order to make sure it is not overfitted.
### Based on the Classification approach, the best model, having mean absolute error equal to 0.58, is clf3 which resulted from the Random Forest Classification method.
### The 5 most important variables affecting valence the most are set to be: danceability, energy, duration_ms, loudness, acousticness and speechiness. 

# Retraining of best model

### As we chose our best model is the Random Forest Rergression model, we will retrain in it on the whole dataset.


```python
# create dummies 
data = pd.get_dummies(data, columns=['key'], drop_first=True)
data = pd.get_dummies(data, columns=['mode'], drop_first=True)
data = pd.get_dummies(data, columns=['time_signature'], drop_first=True)
```


```python
# Get 2 dataframes with the values of independent and dependent variables
X, y = (data.loc[:, data.columns != 'valence'].values, 
        data['valence'].values)

# Split them both into a training and a testing set
# Test set will be the 25% of the initials taken randomly
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, 
                                                    random_state=33)
```


```python
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import cross_val_score
#the method
clf_final = RandomForestRegressor(n_estimators = 50, max_depth=None,min_samples_split=2, random_state = 0,n_jobs=-1)
#train the method
clf_final.fit(X_train, y_train)
```




    RandomForestRegressor(n_estimators=50, n_jobs=-1, random_state=0)




```python
#predictions
y_pred = clf_final.predict(X_test)
```


```python
mae = metrics.mean_absolute_error(y_pred,y_test)
print(f'Mean Absolute Error: {mae}')
```

    Mean Absolute Error: 0.13909926361291078
    

# Random Sample Predictability 

### We will use some randomly given track ids to test the predictability of our best model over them. 

### To do so, we must first scrap our data from Spotify based on tracks' ids. We will use an API for Spotify to do so.


```python
#import API
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
```

### Import the csv file of track ids and check for dublicates.


```python
#import the csv file (the initial was a txt file and we convert it to csv)
data_test = pd.read_csv("spotify_ids.csv", header=None)
data_test = data_test.rename(columns={0:"track_id"})
#all values are unique
data_test = data_test.drop_duplicates(subset = ["track_id"])
data_test.head()
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
      <th>track_id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>7lPN2DXiMsVn7XUKtOW1CS</td>
    </tr>
    <tr>
      <th>1</th>
      <td>5QO79kh1waicV47BqGRL3g</td>
    </tr>
    <tr>
      <th>2</th>
      <td>0VjIjW4GlUZAMYd2vXMi3b</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4MzXwWMhyBbmu6hOcLVD49</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5Kskr9LcNYa0tpt5f0ZEJx</td>
    </tr>
  </tbody>
</table>
</div>



### We connect to the web API with our credentials


```python
from spotify_config import config

client_credentials_manager = SpotifyClientCredentials(config['client_id'],
                                                      config['client_secret'])
sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)
```

### Create a dictionary with all the track ids


```python
features = {}
all_track_ids = list(data_test['track_id'].unique())
```

### We call for up to 100 tracks' audio features per iteration


```python
start = 0
num_tracks = 100
while start < len(all_track_ids):
    print(f'getting from {start} to {start+num_tracks}')
    tracks_batch = all_track_ids[start:start+num_tracks]
    features_batch = sp.audio_features(tracks_batch)
    features.update({ track_id : track_features 
                     for track_id, track_features in zip(tracks_batch, features_batch) })
    start += num_tracks
```

    getting from 0 to 100
    getting from 100 to 200
    getting from 200 to 300
    getting from 300 to 400
    getting from 400 to 500
    getting from 500 to 600
    getting from 600 to 700
    getting from 700 to 800
    getting from 800 to 900
    getting from 900 to 1000
    getting from 1000 to 1100
    getting from 1100 to 1200
    


```python
tracks = pd.DataFrame.from_dict(features, orient='index')
```

### We will clean our dataset so it has the appropriate features to get used in our model.


```python
tracks = tracks.drop(['type','id','uri','track_href','analysis_url'], axis=1)
```

### We create dummy variables for the categorical variables


```python
# create dummies 
tracks = pd.get_dummies(tracks, columns=['key'], drop_first=True)
tracks = pd.get_dummies(tracks, columns=['mode'], drop_first=True)
tracks = pd.get_dummies(tracks, columns=['time_signature'], drop_first=True)
```


```python
# Add a dummy column of time signature 1 with 0 values as time_signature_1 was included in the data we trained our model with
tracks.insert(22,'time_signature_1', 0) 
```


```python
X_final, y_final = (tracks.loc[:, tracks.columns != 'valence'].values, tracks['valence'].values)
```

### We use the Random Forest Regression model to predict as it is our best model.


```python
y_pred = clf_final.predict(X_final)
```

### The metric MAE is equal to 0.1495


```python
mae = metrics.mean_absolute_error(y_pred,y_final)
print(f'Mean Absolute Error: {mae}')
```

    Mean Absolute Error: 0.14957366724039012
    
