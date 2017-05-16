*** Readme for Coursera data cleaning project ***

The project files comprise several parts

1) An R script (data_cleansing.R) which performs all data structuring and analysis. This is descibed in more detail below.
2) A subfolder (/RawData) which contains all data
3) An output file (data_summary.txt) which contains the mean of all variables by subject and activity - this is one of the outputs of the data_cleansing R script
4) A codebook file (features_codebook.txt) which contains all featues, and extra information on any features which represent the mean or standard deviation, as per the items in brackets below. For the other variables, only feature number and original name are recorded.
	* feature number
	* original feature name
	* (full descriptive feature name)
	* (feature type - mean or std dev) 
	* (feature spatial dimension - X, Y or Z)
	* (feature mean value)
	* (feature standard deviation)
5) This README.md file


*** Description of data_cleansing.R script
An overview of steps is as follows. Further detail can be found in the comments of the script itself.

1) Load the training and test datasets from the RawData folder and its subfolders
2) Load data labels (activity) and subject IDs, and merge these in
3) Join together (i.e. union) the training and test datasets into a single datasets
4) Load feature names from the features.txt file in the RawData folder and apply them to columns 
5) Keep only features representing the mean or standard deviation
6) Load in activity mapping data from activity_labels.txt file and replace actiity ID with descriptive name (e.g. 'Walking')
7) Turn all feature names into intuitive descriptive forms, by expanding out abbreviations, removing redundant characters and similar
8) Create a codebook for all original variables, with additional information such as spatial dimension, measurement type etc. being extracted from the variable name.
9) Write this codebook out to file (features_codebook.txt)
10) Create a tidy dataset with an average of each feature across each subject / activity combination, and write this out to file (data_summary.txt)