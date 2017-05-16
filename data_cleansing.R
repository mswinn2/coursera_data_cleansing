### data_cleaning.R
### M Swinn
### Last updated 2017-05-16
###
### This script takes an input of the human movement files
### from the RawData subfolder within the working directory
### and produces as output a cleansed file optimised for analysis,
### and an extended codebook which overwrites the original 'features.txt'

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

# Merge training and test datasets
d = rbind(dTrain, dTest)


# Load feature names and apply them to columns
featNames = read.table("./RawData/features.txt")
names(d)[1:561] = as.character(featNames[,2])


# Keep only columns which represent mean or standard deviation
# specifically these can be identified as those which have
# either 'mean()' or 'std()' within the variable name
# also keep activity and subject columns

validColumns = grep('mean()|std()', names(d))
d = d[,c(validColumns, 562:563)]


# Load activity mapping file and turn the activity column from
# the code to the descriptive name
actMap = read.table("./RawData/activity_labels.txt", header = FALSE)
names(actMap) = c('code', 'activityName')

d = merge(d, actMap, by.X = activity, by.Y = code)
d$activity = NULL
d$code = NULL


# Turn variable names into more desciptive/intuitive forms
# They are already reasonably descriptive, but this script removes
# some redundant characters such as '()', and the 't' or 'f' at the start
# of variable names. It also expandsd various terms, e.g.
# 'Acc' to 'Acceleration' etc.
#
# First, extract a vector of the original variable names, then
# work on this and finally apply it back

vNames = names(d[1:79])
vOriginalNames = vNames # keep a copy of original names - we will need this
                        # to help with codebook at a later stage
vNames = substring(vNames, 2)  # remove first character (the 'f' or 't')
vNames = gsub("\\()", "", vNames)   # remove brackets
vNames = gsub("-", "_", vNames)   # replace dash with underscore
# Replace various abbreviated terms with full terms, and separated with underscore
vNames = gsub("Acc", "_accelerometer", vNames)
vNames = gsub("Gyro", "_gyroscope", vNames)
vNames = gsub("BodyBody", "body", vNames)
vNames = gsub("Freq", "_frequency", vNames)
vNames = gsub("Jerk", "_jerk", vNames)
vNames = gsub("Mag", "_magnitude", vNames)
vNames = tolower(vNames)   # convert everything lower case
names(d)[1:79] = as.character(vNames)


# Create a codebook from variable names, based on the file 'features.txt'
# Note that we have only summarised and processed a subset of all the
# variables in that file, so we will only be modifying some rows
#
# Start by using featNames as a base (this is directly from the original codebook)
# then overwrite that file when done
# 
# Final codebook will contain:
# 1 - feature number
# 2 - original feature name
# 3 - (full descriptive feature name)
# 4 - (feature type - mean or std dev) 
# 5 - (feature spatial dimension - X, Y or Z
# 6 - (feature mean value)
# 7 - (feature standard deviation)
#
# note that min and max summary stats would be of no value, since the data 
# is already standarised such that these are already -1 and 1 respectively

cbtemp = data.frame(cbind(vOriginalNames, vNames))
cbtemp$measurement_type = ifelse(grepl("_std", cbtemp$vNames), "std",
                                 ifelse(grepl("_mean", cbtemp$vNames), "mean", ""))
cbtemp$spatial_dimension = ifelse(stri_sub(cbtemp$vNames,-2, -1) %in% c('_x', '_y', '_z'), 
                                  stri_sub(cbtemp$vNames, -1), "")

# calculte column mean and standard deviation, then append to cbtemp
col_std = apply(d[,1:79], MARGIN = 2, FUN = sd)
col_mean = apply(d[,1:79], MARGIN = 2, FUN = mean)
cbtemp$mean = col_mean
cbtemp$std = col_std

names(cbtemp)[1:2] = c('original_name', 'descriptive_name')

# merge the cbtemp with the original features 'codebook',
# reorder the first two column so that feature number is first,
# then write out the final codebook
featNames = merge(featNames, cbtemp, by.x = 'V2', by.y = 'original_name', all.x = TRUE)
names(featNames)[1:2] = c('original_name', 'feature_number')
featNames = featNames[,c(2,1,3:7)]
write.table(featNames, file = "features_codebook.txt", row.names = FALSE, na = "")



# Create a tidy data set with average of each variable for
# each subject and each activity
dSummary = aggregate(. ~ activityName + subject, d, mean)
write.table(dSummary, file = "data_summary.txt", row.names = FALSE)
