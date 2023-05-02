**TASKS**

**A.**   Use the Token Blocking (not to be confused with Standard Blocking) method to create blocks in the form of K-V (Key-value) pairs. The key for every entry will be each distinct Blocking Key (BK) derived from the entities’ attribute values and the values for each BK will be the entities’ ids. Please note that the id column in the data can be used only as reference for the blocking index and it will NOT be used in the blocking process (block index creation). Please also note that you are advised to transform every string to lower case during the tokens’ creation (before you insert it in the index) to avoid mismatches. At the end of the creation use a function to pretty-print the index.

**B.**   Compute all the possible comparisons that shall be made to resolve the duplicates within the blocks that were created in Step A. After the computation, please print the final calculated number of comparisons.

**C.**    Create a Meta-Blocking graph of the block collection (created in step A) and using the CBS Weighting Scheme (i.e., Number of common blocks that entities in a specific comparison have in common) i) prune (delete) the edges that have weight < 2 ii) re-calculate the final number of comparisons (like in step B) of the new block collection that will be created after the edge pruning.

**D.**   Create a function that takes as input two entities and computes their Jaccard similarity based on the attribute title. You are not requested to perform any actual comparisons using this function.


**SOLUTION**

**ETL Data**


```python
import pandas as pd

data = pd.read_csv('ER-Data.csv',sep=';')
#change year type to string
data.year = data.year.astype(str)
#Replace NAs with string value None
data = data.fillna('None')

#convert all letters to lowercase and split them on blanks to create tokens
data.authors = data.authors.str.casefold().str.split()
data.year = data.year.str.casefold().str.split()
data.venue = data.venue.str.casefold().str.split()
data.title = data.title.str.casefold().str.split()

#concatenate the attributes' columns
data["tokens"] = data.authors+data.venue+data.year+data.title 

#as some extra commas exist after the split which we do not want to include in our tokens, 
#replace the extra commas with nothing
for i in range(0, len(data)):
    for j in range(0,len(data.tokens[i])):
        data.tokens[i][j] = data.tokens[i][j].replace(',','')
        
#delete rest of columns
data1 = data.drop(['authors','venue','title','year'], axis=1)

#display data final format
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
      <th>id</th>
      <th>tokens</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>[qd, inc, san, diego, nan, 11578, sorrento, va...</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>[as, argon, jg, hannoosh, phil., mag, nan, ini...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>[gh, hansen, ll, wetterberg, h, sjã¶strã¶m, o,...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>[tm, hammett, p, harmon, w, rhodes, see, nan, ...</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>[jr, cogdell, new, directions, for, teaching, ...</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>66874</th>
      <td>66875</td>
      <td>[a, shukla, p, deshpande, j, naughton, k, rama...</td>
    </tr>
    <tr>
      <th>66875</th>
      <td>66876</td>
      <td>[none, none, 2003.0, call, for, book, reviews]</td>
    </tr>
    <tr>
      <th>66876</th>
      <td>66877</td>
      <td>[r, ramakrishnan, d, ram, vldb, 1996.0, modeli...</td>
    </tr>
    <tr>
      <th>66877</th>
      <td>66878</td>
      <td>[j, shafer, r, agrawal, m, mehta, vldb, 1996.0...</td>
    </tr>
    <tr>
      <th>66878</th>
      <td>66879</td>
      <td>[none, none, 2003.0, report, on, the, first, i...</td>
    </tr>
  </tbody>
</table>
<p>66879 rows × 2 columns</p>
</div>



**A.** We create an empty dictionary where each token will take place as a key in it. We search for each token in the column tokens per row and append to the dictionary the ids of the rows we find to include each token in. Each key must include at least 2 values to exist. Finally, we delete keys equal to nan, none and blanks as they are nonmeaningful and pretty print the key-value pairs.

###### Each token will take place as a key in our dictionary. We search for each token in the column tokens per row and append to the dictionary the ids of the rows we find to include each token in. Each key must include at least 2 values to exist.


```python
#initialize the dictionary
kv_pairs = {}

#iterate each row
for i in range(len(data1)):
    #take every item in the tokens list per row
    for key in data1.tokens[i]:
        #search if the token already exists as a key
        if key in kv_pairs:
            #append the id of the row to the appropriate key in the dictionary
            kv_pairs[key].append(data1.id.iloc[i])
        else:
            #else first create the key and an empty list for it and then append the id of the row to the key
            kv_pairs[key] = []
            kv_pairs[key].append(data1.id.iloc[i])
            
#delete keys equal to nan, none and blanks
kv_pairs.pop('nan')
kv_pairs.pop('none')
kv_pairs.pop('')

#print the first 5 key value pairs
counter = 0
for key,values in kv_pairs.items():
    if counter < 5:
        print('Token:',key,'\n' 'Entities including it:',values,'\n')
        counter+=1
```

    Token: qd 
    Entities including it: [1, 55360] 
    
    Token: inc 
    Entities including it: [1, 852, 923, 2857, 3057, 3486, 4378, 4854, 5589, 6339, 7038, 8574, 9368, 10500, 11596, 15004, 16358, 17005, 18337, 21912, 22216, 22275, 23987, 24308, 26475, 27244, 29327, 30987, 32596, 36256, 36411, 38590, 39000, 40028, 41393, 42111, 42685, 43073, 43918, 43918, 44647, 44908, 45497, 46763, 47124, 49406, 50987, 51988, 52505, 53149, 56545, 56805, 57323, 58857, 59169, 60213, 61288, 61397, 62978, 65238] 
    
    Token: san 
    Entities including it: [1, 8, 11, 65, 215, 219, 352, 382, 496, 574, 607, 698, 732, 743, 780, 826, 852, 923, 1184, 1290, 1375, 1603, 1673, 1805, 1907, 1958, 1980, 2001, 2004, 2076, 2147, 2263, 2340, 2415, 2658, 2816, 2857, 2897, 2922, 2944, 3057, 3104, 3117, 3204, 3342, 3434, 3463, 3468, 3601, 3654, 3655, 3715, 3718, 3759, 3812, 3892, 3918, 3962, 4031, 4200, 4203, 4266, 4378, 4384, 4449, 4581, 4664, 4766, 5087, 5424, 5830, 5937, 5997, 6065, 6109, 6194, 6433, 6529, 6589, 6600, 6650, 6749, 6802, 6811, 6858, 6978, 7096, 7193, 7313, 7315, 7407, 7476, 7787, 7904, 7946, 7989, 8136, 8150, 8269, 8515, 8555, 8597, 8649, 8651, 8769, 8792, 8804, 8853, 9066, 9109, 9126, 9242, 9323, 9336, 9418, 9508, 9634, 9717, 9750, 9763, 9842, 10229, 10253, 10350, 10411, 10466, 10502, 10586, 10592, 10615, 10648, 10716, 10717, 10724, 10801, 10804, 10843, 10916, 10935, 11122, 11341, 11379, 11483, 11496, 11631, 11662, 11762, 11844, 11872, 11891, 12120, 12193, 12388, 12533, 12628, 12689, 13015, 13103, 13224, 13317, 13546, 13561, 13593, 13607, 13649, 13723, 13731, 13770, 13940, 13941, 13985, 14011, 14050, 14169, 14220, 14264, 14324, 14492, 14845, 14938, 14965, 15004, 15006, 15033, 15089, 15201, 15263, 15294, 15478, 15665, 15735, 15795, 15839, 15886, 16193, 16223, 16264, 16299, 16321, 16496, 16537, 16700, 16754, 17011, 17069, 17069, 17135, 17151, 17223, 17376, 17459, 17503, 17531, 17673, 17680, 17753, 17770, 17821, 17859, 18102, 18137, 18238, 18239, 18487, 18507, 18539, 18988, 18705, 18776, 18989, 18830, 18885, 18916, 18922, 19054, 19070, 19128, 19165, 19412, 19499, 19537, 19567, 19769, 19787, 20066, 20149, 20314, 20477, 20746, 20797, 20806, 20911, 21202, 21228, 21314, 21561, 21630, 21662, 21954, 21988, 22021, 22059, 22090, 22216, 22275, 22403, 22526, 22732, 22930, 22966, 23026, 23095, 23256, 23494, 23519, 23543, 23575, 23806, 23819, 24214, 24297, 24308, 24512, 24512, 24677, 24745, 24855, 24984, 25060, 25143, 25187, 25241, 25282, 25360, 25690, 25701, 25905, 25955, 25955, 25981, 26013, 26167, 26294, 26302, 26346, 26404, 26411, 26475, 26645, 26647, 26689, 26755, 26861, 26888, 26890, 26979, 27065, 27291, 27329, 27351, 27542, 27599, 27622, 27687, 27780, 28190, 28302, 28377, 28442, 28487, 28520, 28548, 28553, 28616, 28706, 28900, 28981, 29048, 29054, 29089, 29089, 29089, 29158, 29205, 29322, 29691, 29743, 29765, 29945, 30135, 30288, 30323, 30369, 30466, 30480, 30703, 30754, 30987, 31043, 31066, 31096, 31105, 31126, 31139, 31321, 31510, 31529, 31541, 31563, 31696, 31774, 31804, 31899, 32034, 32127, 32339, 32562, 32596, 32605, 32613, 32773, 32874, 32935, 33075, 33118, 33165, 33273, 33501, 33888, 33935, 34019, 34098, 34146, 34273, 34524, 34559, 34629, 34840, 34914, 34969, 35065, 35090, 35145, 35277, 35395, 35435, 35450, 35484, 35503, 35617, 35659, 35829, 35943, 36016, 36068, 36130, 36150, 36175, 36210, 36258, 36420, 36426, 36501, 36578, 36638, 36748, 37158, 37925, 38073, 38190, 38206, 38209, 38266, 38316, 38406, 38436, 38460, 38482, 38566, 38599, 38626, 38645, 38755, 38788, 39000, 39072, 39077, 39080, 39218, 39535, 39669, 39716, 39763, 39790, 39836, 39939, 39967, 40053, 40145, 40218, 40316, 40423, 40450, 40502, 40539, 40649, 40683, 40768, 40831, 40896, 40925, 40971, 41036, 41131, 41237, 41364, 41394, 41420, 41553, 41590, 41726, 41727, 41999, 42056, 42066, 42235, 42324, 42391, 42403, 42488, 42524, 42652, 42681, 42841, 42867, 42892, 42926, 42955, 42977, 42981, 43073, 43077, 43116, 43243, 43348, 43476, 43779, 43922, 43932, 43950, 43982, 44041, 44123, 44146, 44518, 44869, 44898, 44908, 44950, 45034, 45227, 45307, 45360, 45451, 45497, 45554, 45619, 45801, 45802, 45948, 45982, 46130, 46201, 46219, 46227, 46308, 46481, 46499, 46696, 46763, 46796, 47124, 47211, 47216, 47441, 47691, 47708, 47771, 47791, 47862, 48032, 48257, 48422, 48451, 48464, 48491, 48697, 48831, 48943, 48994, 49278, 49406, 49450, 49459, 49504, 49642, 49674, 49700, 49714, 49776, 49794, 49935, 49952, 50119, 50310, 50400, 50452, 50623, 50628, 50823, 50825, 50930, 50945, 50987, 51002, 51121, 51320, 51415, 51430, 51526, 51736, 51747, 51836, 51861, 51903, 51919, 52542, 51988, 52114, 52164, 52287, 52449, 52505, 52536, 52739, 52812, 52974, 52993, 53131, 53149, 53195, 53305, 53365, 53469, 53518, 53551, 53661, 53826, 53855, 53934, 53980, 54001, 54170, 54419, 54502, 54506, 54510, 54569, 54683, 54855, 54989, 55047, 55101, 55103, 55470, 55532, 55613, 55677, 55793, 55815, 55869, 55871, 55873, 55913, 55965, 56030, 56120, 56298, 56306, 56409, 56590, 56626, 56669, 56669, 56775, 56797, 56801, 56805, 56995, 57264, 57323, 57348, 57398, 57439, 57725, 57884, 57923, 58053, 58053, 58342, 58554, 58587, 58777, 58857, 59096, 59115, 59184, 59221, 59294, 59335, 59356, 59371, 59394, 59531, 59586, 59684, 59870, 59967, 60144, 60329, 60390, 60438, 60560, 60634, 60677, 60695, 60893, 60925, 61333, 61354, 61391, 61471, 61517, 61559, 61656, 61742, 61865, 61891, 62012, 62053, 62187, 62237, 62325, 62368, 62396, 62429, 62472, 62539, 62610, 62636, 63063, 63211, 63284, 63319, 63346, 63414, 63644, 63736, 63900, 63955, 63990, 64547] 
    
    Token: diego 
    Entities including it: [1, 11, 65, 219, 352, 382, 574, 743, 780, 826, 923, 1184, 1375, 1427, 1603, 1673, 1805, 1907, 1980, 2001, 2004, 2076, 2178, 2340, 2415, 2658, 2816, 2857, 2897, 2922, 2944, 3057, 3117, 3342, 3463, 3468, 3654, 3715, 3718, 3759, 3812, 3918, 4031, 4200, 4203, 4266, 4378, 4449, 4664, 4766, 5424, 5486, 5830, 5937, 5997, 6065, 6109, 6433, 6529, 6600, 6650, 6749, 6811, 6858, 7096, 7313, 7315, 7407, 7787, 7904, 8515, 8597, 8649, 8792, 8804, 8853, 9066, 9109, 9126, 9242, 9330, 9336, 9418, 9508, 9717, 9750, 9842, 10253, 10350, 10466, 10502, 10586, 10592, 10615, 10648, 10716, 10717, 10724, 10785, 10804, 10843, 10935, 11122, 11341, 11379, 11496, 11631, 11762, 11844, 11891, 12120, 12388, 12533, 12628, 12689, 13015, 13103, 13224, 13317, 13546, 13561, 13593, 13607, 13731, 13770, 13940, 13941, 13985, 14011, 14050, 14220, 14264, 14324, 14492, 14845, 14938, 15004, 15033, 15089, 15201, 15263, 15665, 15735, 15839, 15886, 16193, 16264, 16537, 16700, 17011, 17069, 17069, 17135, 17223, 17376, 17503, 17680, 17859, 18102, 18137, 18238, 18239, 18487, 18507, 18539, 18988, 18705, 18776, 18989, 18885, 18916, 18922, 19054, 19128, 19165, 19412, 19567, 19769, 19787, 20066, 20149, 20746, 20797, 20806, 20911, 21202, 21228, 21314, 21561, 21662, 21954, 21988, 22059, 22090, 22216, 22275, 22930, 22966, 23494, 23543, 23575, 23806, 23819, 24308, 24512, 24512, 24677, 24702, 24745, 24855, 24984, 25060, 25143, 25187, 25241, 25282, 25360, 25690, 25701, 25905, 25981, 26013, 26167, 26302, 26404, 26411, 26475, 26645, 26647, 26689, 26888, 26890, 26979, 27291, 27351, 27558, 27687, 27780, 28302, 28377, 28442, 28487, 28520, 28548, 28553, 28616, 28981, 29048, 29054, 29089, 29089, 29089, 29158, 29205, 29691, 29743, 29945, 30135, 30288, 30323, 30466, 30703, 30754, 30987, 31043, 31066, 31096, 31105, 31321, 31529, 31541, 31563, 31696, 31774, 31804, 32034, 32127, 32339, 32562, 32596, 32773, 32874, 33075, 33118, 33273, 33501, 33935, 34098, 34273, 34524, 34629, 34840, 34969, 35090, 35145, 35190, 35277, 35395, 35450, 35484, 35503, 35617, 35829, 35943, 36068, 36130, 36150, 36175, 36210, 36258, 36420, 36578, 36638, 36748, 37158, 37925, 38073, 38190, 38209, 38460, 38482, 38566, 38626, 38645, 38755, 38788, 39000, 39077, 39218, 39716, 39967, 40053, 40145, 40218, 40316, 40502, 40649, 40768, 40831, 40925, 41364, 41394, 41553, 41590, 41726, 41727, 41999, 42066, 42235, 42324, 42391, 42524, 42652, 42681, 42841, 42867, 42892, 42955, 42981, 43073, 43077, 43116, 43330, 43348, 43476, 43779, 43922, 43950, 43982, 44041, 44123, 44869, 44898, 44908, 45034, 45187, 45227, 45307, 45360, 45451, 45497, 45554, 45802, 45948, 45982, 46201, 46219, 46227, 46308, 46481, 46499, 46696, 46763, 46796, 47124, 47211, 47216, 47771, 47791, 47862, 48032, 48422, 48464, 48994, 49406, 49459, 49504, 49700, 49776, 49794, 49935, 50400, 50628, 50930, 50945, 51002, 51415, 51736, 51747, 51861, 51919, 52542, 51988, 52114, 52505, 52536, 52812, 52974, 53149, 53195, 53305, 53365, 53469, 53518, 53551, 53661, 53826, 53855, 53934, 53980, 54001, 54170, 54419, 54502, 54506, 54510, 54569, 54683, 54989, 55047, 55103, 55470, 55532, 55793, 55815, 55869, 55871, 55873, 55913, 55965, 56030, 56120, 56298, 56306, 56409, 56626, 56669, 56669, 56775, 56797, 56801, 56805, 57323, 57348, 57398, 57439, 57725, 57884, 57923, 58053, 58053, 58342, 58554, 58587, 58777, 58857, 59096, 59221, 59294, 59356, 59394, 59586, 59684, 59870, 59967, 60329, 60390, 60438, 60695, 60893, 60925, 61333, 61354, 61391, 61471, 61656, 61742, 61891, 62012, 62053, 62187, 62237, 62325, 62396, 62429, 62472, 62539, 62610, 63211, 63284, 63346, 63414, 63898, 63900, 63955, 64547] 
    
    Token: 11578 
    Entities including it: [1] 
    
    

**B.** As a token might be included more than one times per row, it is possible that duplicate entities have been appended to some keys. The duplicates increase the number of comparisons per block. To count all the possible combinations, we firstly calculate all the possible combinations of the entities inside the same block and then sum all the combinations per block to get the total number of combinations. 

###### As a token might be included more than one times per row, it is possible that duplicate entities have been appended to some keys. The duplicates increase the number of comparisons per block.


```python
#empty list that will hold the number of comparisons per block
number_of_comp_per_token = []
#take each block
for values in kv_pairs.values():
    #count the number of entities it includes
    n = len(values)
    #count the number of comparisons for n number of entities per block
    comparisons = n*(n-1)/2
    #add the number to the list
    number_of_comp_per_token.append(comparisons)
#sum the list for the total number of comparisons
total_number_of_comp = sum(number_of_comp_per_token)

print('The number of total comparisons is:',int(total_number_of_comp))
```

    The number of total comparisons is: 2644696280
    

**C.** We will use the Meta-Blocking method to reduce the number of duplicates as well as the number of nonmeaningful comparisons and optimize the blocking procedure. 
Firstly, we will create a dictionary where the keys will be the concatenated ids of the entities we compare and the values will be the number of common blocks each pair of entities has.¶Then, we will iterate through each block, choose the first entity in it and create all the concatinated pairs of it with the rest of the entities in the block. As we want the graph to be undirected, for pairs created inside the same block and after all the possible pairs for the entity inside the block have been created, we delete the entity from the block and continue with the next entity (which now takes the 1st position in the block) to avoid creating reversed pairs. For pairs which we want to make sure that do not exist already in the dictionary as keys (in normal or reverse form), we will also create the reverse pair of each comparison and check if the reverse key is already included in the already existing keys of the dictionary to avoid creating it again if it exists in reverse. As the number of possible pairs is extremely high, we will use the first 100 entities and their possible pairs as a toy example. We will then count the number of 1s for each key which will show us the weight of each pair. Finally, we will prune the pairs that have weight less than 2.
We recalculate the number of comparisons as in task B. To do so, we will sum the weights of all pairs. As we used only 100 entities to create the dictionary, we are not able to calculate the exact number of combinations, but the methodology remains the same.

##### We will use the Meta-Blocking method to reduce the number of duplicates as well as the number of nonmeaningful comparisons and optimize the blocking procedure.

##### Firstly, we will create a dictionary where the keys will be the concatenated ids of the entities we compare and the values will be the number of common blocks each pair of entities has.



```python
#create empty dictionary to store the entities - weights pairs
entities_weights_pairs = {}
```

###### To do so, we will iterate through each block, choose the first entity in it and create all the concatinated pairs of it with the rest of the entities in the block. As we want the graph to be undirected, for pairs created inside the same block and after all the possible pairs for the entity inside the block have been created, we delete the entity from the block and continue with the next entity (which now takes the 1st position in the block) to avoid creating reversed pairs. For pairs which we want to make sure that do not exist already in the dictionary as keys (in normal or reverse form), we will also create the reverse pair of each comparison and check if the reverse key is already included in the already existing keys of the dictionary to avoid creating it again if it exists in reverse.

###### As the number of possible pairs is extremely high, we will use the first 100 entities and their possible pairs as a toy example.


```python
total_entities = 0
stop = 0
#check all blocks
for block in kv_pairs.values():
    #take each entity in the block
    for entity in block:
        total_entities += 1
        if total_entities > 100:
            stop = 1
            break
        else:
            #check the length of the block as the following iteration would go out of index if it is <=1
            if len(block) == 1:
                break
            #iterate i times
            for i in range(0,len(block)-1):
                #create 1 key with the concatenation of the id of the entity we are checking 
                #and the rest of entities' ids in the block
                key1 = str(entity)+','+str(block[i+1])
                #create second key with the concatenation of the id of the entity we are checking 
                #and the rest of entities' ids in the block but in reverse
                key2 = str(block[i+1])+','+str(entity)
                #check if the key or the reverse key already exist in dictionary and create a key in it if not with value 1
                if key1 not in entities_weights_pairs.keys() and key2 not in entities_weights_pairs.keys():
                    entities_weights_pairs[key1] = [1,]
                #if the reverse key already exists then go and append 1 in the reverse key
                elif key2 in entities_weights_pairs.keys():
                    entities_weights_pairs[key2].append(1)
                #else append to the key the number 1
                else:
                    entities_weights_pairs[key1].append(1)
            #finally remove the entity from the block so that the the next in line entity to be chosen in the next iteration
            block.remove(entity)
            #we want only 10 entities
        if stop == 1:
            break
```

###### We will then count the number of 1s for each key which will show us the weight of each pair.


```python
#count number of 1s by summing them
for key,values in entities_weights_pairs.items():
    entities_weights_pairs[key] = sum(values) 
```

###### Finally, we will prune the pairs that have weight less than 2.


```python
entities_weights_pairs_final = {key: values for key, values in entities_weights_pairs.items() if values >= 2}

#print the first 5 key value pairs
counter = 0
for key,values in entities_weights_pairs_final.items():
    if counter < 5:
        print('Nodes:',key,'\n' 'Number of Common Blocks:',values,'\n')
        counter+=1
```

    Nodes: 1,852 
    Number of Common Blocks: 2 
    
    Nodes: 1,923 
    Number of Common Blocks: 2 
    
    Nodes: 1,2857 
    Number of Common Blocks: 2 
    
    Nodes: 1,3057 
    Number of Common Blocks: 2 
    
    Nodes: 1,4378 
    Number of Common Blocks: 2 
    
    

###### We recalculate the number of comparisons as in task B. To do so, we will sum the weights of all pairs. As we used only 100 entities to create the dictionary we are not able to calculate the exact number of combinations but the methodology remains the same.


```python
number_of_comp_after_prune = 0
#sum the weights of all pairs
for values in entities_weights_pairs_final.values():
        number_of_comp_after_prune += values  
        
print('The number of total comparisons is:',number_of_comp_after_prune)
```

    The number of total comparisons is: 1127
    

**D.** We assume that the dataset is tokenized per column and each column (attribute title) includes lists of the tokens per row. A fixed dataset with dummy variables will be used for reference. The scope of the function is to be fed the 2 entities ids as well as the dataset and then calculate their Jaccard similarity per attribute comparing the lists of tokens that correspond to them.¶
The function iterates each column and for the rows that match the ids given, the lists of tokens are appended to a new list. From this list we take the intersection and union of the lists of tokens it includes and finally calculate the Jaccard similarity per attribute by dividing intersection with union. 

###### We assume that the dataset is tokenized per column and each column (attribute title) includes lists of the tokens per row. A fixed dataset with dummy variables will be used for reference. The scope of the function is to be fed the 2 entities ids as well as the dataset and then calculate their Jaccard similarity per attribute comparing the lists of tokens that correspond to them. 



```python
#create the dataset and fill it with dummy data
dataset = pd.DataFrame(columns=['id','attribute1','attribute2'])

dataset['id'] = [1,2]
dataset['attribute1'] = [['this','is','an','example'],['this','is','another','example']]
dataset['attribute2'] = [['1996'],['1997']]    

#function that calculates jaccard similarity
def Jaccard_similarity(x,y,data):
    k=0
    lista=[]
    #read each columns
    for column in dataset.columns:
        #for the columns except of the id columns
        if column != 'id':
            #read per row
            for i in range(len(dataset)):
                #if the id column matches with the given entities
                if dataset.id.iloc[i] == x or dataset.id.iloc[i] == y:
                    #add to a list the tokens corresponding to the column and row 
                    lista.append(dataset[column].iloc[i])
                    k+=1
                    #when k==2 both entities given have been added to the list
                    if k==2:
                        #calculate the intersection
                        intersection =  len([value for value in lista[0] if value in lista[1]])
                        #calculate the union
                        union = len([value for value in lista[0]]) + len([value for value in lista[1] if value not in lista[0]])
                        #calculate jaccard similarity
                        Jaccard = intersection/union
                        #renew the constant and list in order to procced to the next column in the next iteration
                        k=0
                        lista = []
                        #print the entities, and their jaccard similarities per column
                        print('The Jaccard similarity of entities',x,'and',y,'for the column',column,'is:',Jaccard)
                        
#the jaccard similiarities of our dummy entities
Jaccard_similarity(1,2,dataset)
```

    The Jaccard similarity of entities 1 and 2 for the column attribute1 is: 0.6
    The Jaccard similarity of entities 1 and 2 for the column attribute2 is: 0.0
    
