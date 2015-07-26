library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        
        download.file(fileURL, filename)
        #download.file(fileURL, filename, method="curl")  NOTE: IF your system requires "curl" comment out above line and use this version.
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
}

# Load activity labels + features
activity <- read.table("UCI HAR Dataset/activity_labels.txt")
activity[,2] <- as.character(activity[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation  to fulfill requirement 2 needing only mean and standard deviation.
featuresNeed <- grep(".*mean.*|.*std.*", features[,2])
featuresNeed.names <- features[featuresNeed,2]
featuresNeed.names = gsub('-mean', 'Mean', featuresNeed.names)
featuresNeed.names = gsub('-std', 'Std', featuresNeed.names)
featuresNeed.names <- gsub('[-()]', '', featuresNeed.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresNeed]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresNeed]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add meaningful labels to fulfill Requirement 1 and 3
data <- rbind(train, test)
colnames(data) <- c("subject", "activity", featuresNeed.names)

# turn activities & subjects into factors to fulfill requirement 4 of descriptive variable names instead of V1, V2, V3, etc.
data$activity <- factor(data$activity, levels = activity[,1], labels = activity[,2])
data$subject <- as.factor(data$subject)

data.melted <- melt(data, id = c("subject", "activity"))
data.mean <- dcast(data.melted, subject + activity ~ variable, mean)

#Fulfilling requirement 5, by providing a "tidy" dataset  inline with definition of "Tidy Data" from teching assistant
# David Hood's web article from the class forum: https://class.coursera.org/getdata-030/forum/thread?thread_id=107

write.table(data.mean, "tidy.txt", row.name = FALSE, quote = FALSE)