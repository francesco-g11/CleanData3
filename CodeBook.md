## The *run_analysis.R* script


### *Introduction*

The *Human Activity Recognition Using Smartphones Dataset* contains data about an experiment carried out with a group of 30 volunteers. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone on the waist. The main dataset captured values from accelerometer and gyroscope and have been randomly partitioned into two *training* and *testing* sets. Data concerning subjects, activity codes and labels have been also kept apart, into three separate files. 


### *Purpose*

The goal is to create a new tidy dataset from the two merged source datasets, extracting only information about mean and standard deviation, associating the measures to respective activity and subject and finally making the variables more readable. A second purpose is to summarize the new dataset calculating averages for each value, per subject and activity.


### *The source data*

The initial data come in a form of a group of text files, starting from a folder named *[UCI HAR Dataset]*, organized as follows (only files used in the script are listed):

/

	activity_labels.txt			contains activity labels (e.g. WALKING,...)
    feature.txt					contains feature (i.e. variable names, e.g. tBodyAcc-mean()-X,...)
    README.txt					explanation file
    
/train

	subject_train.txt			contains subject (i.e. volunteer) codes for training set
    X_train.txt					contains training set measures
    Y_train.txt					contains training set activity codes
    
/test

	subject_test.txt			contains subject (i.e. volunteer) codes for testing set
    X_test.txt					contains testing set measures
    Y_test.txt					contains testing set activity codes
    
### *The script*

The script contains two functions
* getHARdataset()
* calcAvgHARdataset()

the first function gets data from the source and provides a tidy dataset, while the other one calculates the averages as the second goal requires.

##### getHARdataset()
This function takes as parameter the path for the *UCI HAR Dataset* (the one containing the README file) and uses the source text files performing opeartions to return clean and tidy data. If no path is provided, the *getwd()* result will be used. After having acquired the activity and feature label, it uses a for-loop to import train and test dataset, taking advantage of very similar name structure. The function requires the *dplyr* package.
###### Merge and extract vs. Extract and merge
There are two dataset to merge and a subset of columns to extract. A preliminary overview showed there are only 66 columns out of 561 containing mean and standard deviation to be captured for the analysis. Since the total rows (test+train) equals to 10299, the *getHARdataset()* function first extracts the columns and then merges the datasets. This to avoid to have an unuseful temporary dateset in memory with size 10299x561.
###### The operations in detail
*	**Step 1** : loads activity labels and feature names from their respective text files
*	**Step 2** : creates an extra column on feature dataframe to bypass the issue about duplicate column name. This because some unuseful columns on the dataset have the same name. As example the columns #316, #330, #344 share the label *fBodyAcc-bandsEnergy()-25,48*. A duplicate column name will prevent a future use of the *contains()* function to get only mean and std columns. This step creates an unique name binding the number to the label, so for the first column in the example the name becomes *316:fBodyAcc-bandsEnergy()-25,48*; the second will be *330:fBodyAcc-bandsEnergy()-25,48* and so on.
*	**Step 3** : loads the main training dataset into a temprary dataframe and applies the column names as defined on step 2
*	**Step 4** : loads activity codes
*	**Step 5** : loads subject codes
*	**Step 6** : rearranges the dataframe: selects only columns containing mean or std; binds subject and activity codes; joins with activity labels, using the activity code
*	**Step 7** : performs a series of substitution on the column headings to make them more readable: strips away the number used to have a unique name (step 2); put a "-" before each capital letter; tears off the trailing parenthesis after "mean" and "std"; changes the initial "t" into "Time" and the initial "f" into "Frequency". As example, at the end of this step the variable *tBodyAcc-mean()-X* changes its name into *Time-Body-Acc-mean-X*
*	**Step 8** : creates the result dataset (first iteration) or appends data to it (second)
*	**Step 9** : removes the temporary dataset

The steps #3 to #9 take place twice. The first iteration uses *training* dataset while the second one uses the *testing* dataset. Search the script comment for {step 1} to {step 9} to see where the operation is performed.  

###### The resulting dataset and variables
The resulting dataset has 10299 rows and 69 columns.
The descriptive variables are:
*	subject_code	(range 1 to 30, identifying the volunteer)
*	activity_code (range 1 to 6)
*	activity_name	(WALKING, SITTING,...)

The measure variable labels all share the same format:
*	First part is *Time* or *Frequency*
*	Last part is *mean* or *std*, followed by *X, Y, Z* if needed
*	Central part explains the information observed

As example, the first measure column is *Time-Body-Acc-mean-X*, stating *Mean of Time of Body-Acc(elerometer) measure on X axis* 

*Units*
*	Values concerning accelerometer (name contains *Acc*), are in standard gravity units *g*
*	Values concerning angular velocity measured by the gyroscope (name contains *Gyro*) are in radians/second
*	Feature are normalized and bounded within [-1,1]

##### calcAvgHARdataset()
This function takes the previous explained dataset as parameter and use it to create a new dataset with averages of each measure. It also requires the *dplyr* package.
###### The operations in detail
*	**Step 1** : creates a dataset summarizing each measure column of the source dataset, grouping by subject code and activity name. The activity code is no longer useful on this new dataset (activity name is more explanatory) and so it is excluded
*	**Step 2** : change the column names adding the prefix "Avg-"

###### The resulting dataset and variables
The resulting dataset has 180 rows and 68 columns.
The descriptive variables are the same descripted for *getHARdataset()* function, excluded the activity_code no longer present. The measure variables have also the same name but each one is prefixed by "Avg-" (e.g. *Avg-Time-Body-Acc-mean-X*), stating it is an average. This because tidy data means also that two columns with different values (single observations and averages) cannot share the same name.


### *How to use*

After loaded the script using
```javascript
source("run_analysis.R")
```
you can assign a variable to use as recipient for the incoming dataset

```javascript
myHARdf <- getHARdataset("path_to_the_source_data")
```
then you can get the averages into another dataframe using the second function

```javascript
myAvgHARdf <- calcAvgHARdataset(myHARdf)
```