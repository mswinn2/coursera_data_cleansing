### data_cleaning.R
###
### This script takes an input of the human movement files
### from the RawData subfolder within the working directory
### and produces as output a cleansed file optimised for analysis

library(utils)
library(dplyr)
library(stringi)

# Load training and test datasets. These are text files in fixed width format -
# there are 561 variables, each of width 16 characters
dTrain = read.fwf("./RawData/train/X_train.txt", widths = rep(16, 561), header = FALSE)
dTest = read.fwf("./RawData/test/X_test.txt", widths = rep(16, 561), header = FALSE)

# Load training and test labels, and subject IDs
dTrainLbl = read.table("./RawData/train/y_train.txt", header = FALSE)
dTestLbl = read.table("./RawData/test/y_test.txt", header = FALSE)
dTrainSubj = read.table("./RawData/train/subject_train.txt", header = FALSE)
dTestSubj = read.table("./RawData/test/subject_test.txt", header = FALSE)

dTrain$activity = dTrainLbl$V1
dTest$activity = dTestLbl$V1
dTrain$subject = dTrainSubj$V1
dTest$subject = dTestSubj$V1

# Merge (union) training and test datasets
d = rbind(dTrain, dTest)


# Load feature names and apply them to columns
featNames = read.table("./RawData/features.txt")
names(d)[1:561] = as.character(featNames[,2])


# Keep only columns which represent mean or standard deviation
# specifically these can be identified as those which have
# either 'mean()' or 'std()' within the variable name
# also keep activity and subject columns

validColumns = grep('mean()|std()|subject|activity', names(d))
d = d[,validColumns,]


# Load activity mapping file and turn the activity column from
# the code to the descriptive name
actMap = read.table("./RawData/activity_labels.txt", header = FALSE)
names(actMap) = c('code', 'activityName')

d = merge(d, actMap, by.X = activity, by.Y = code)
d$activity = NULL # drop - this is a duplicate
d$code = NULL # drop - the code is redundant, we want only the description


# Create a tidy data set with average of each variable for
# each subject and each activity, and write out to file
dSummary = aggregate(. ~ activityName + subject, d, mean)
write.table(dSummary, file = "data_summary.txt", row.names = FALSE)