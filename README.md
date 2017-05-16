# Readme for Coursera data cleansing project

The project files comprise several parts

1) An R script (run_analysis.R) which performs all data structuring and analysis. This is descibed in more detail below.
2) A subfolder (/RawData) which contains all raw data, as extracted from the dataset [available here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). **Note this has not been uploaded to github due to the size** but if the zip file is extracted into a folder called RawData placed within the working directory, the script will run using this.
3) An output file (data_summary.txt) which contains the mean of all variables by subject and activity - this is one of the outputs of the data_cleansing R script
4) A codebook file (codebook.md) which describes the dataset
5) This README.md file


# Description of run_analysis.R script
An overview of steps is as follows. Further detail can be found in the comments of the script itself.

1) Load the training and test datasets from the RawData folder and its subfolders
2) Load data labels (activity) and subject IDs, and merge these in
3) Join together (i.e. union) the training and test datasets into a single datasets
4) Load feature names from the features.txt file in the RawData folder and apply them to columns 
5) Keep only features representing the mean or standard deviation
6) Load in activity mapping data from activity_labels.txt file and replace actiity ID with descriptive name (e.g. 'Walking')
7) Create a tidy dataset with an average of each feature across each subject / activity combination, and write this out to file (data_summary.txt)