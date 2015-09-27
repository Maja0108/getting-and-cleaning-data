#If needed:
#install.packages("data.table")
#install.packages("reshape2")
#setwd to the directory where UCI HAR Dataset exists

library(data.table)
library(reshape2)

# Loading activity labels and features
activity_labels <- read.table("./activity_labels.txt")[,2]
features <- read.table("./features.txt")[,2]

# Loading X_test/train and y_test/train data.
X_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")

X_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/y_train.txt")
subject_train <- read.table("./train/subject_train.txt")

names(X_test) = features
names(X_train) = features

# Extracting the mean and standard deviation.
extracted_features <- grepl("mean|std", features)
X_test = X_test[,extracted_features]
X_train = X_train[,extracted_features]

# Processing test/train activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) =  c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Binding data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)
train_data <- cbind(as.data.table(subject_train), y_train, X_train)
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Calculating mean
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt", row.names = FALSE)
