
#   getHARdataset
#    
#   Creates a dataframe using as source the contents of "UCI HAR Dataset" directory and train/test subdirectories
#   the [loadpath] parameter has to points to "UCI HAR Dataset" position. 
#   If not provided, the standard work directory will be used
#   
#   the comments {step 1}..{step x} refer to the explanations on CodeBook.md

getHARdataset <- function(loadpath="") {

    require(dplyr)
    
    if (loadpath=="")
            loadpath <- getwd()
    
    #   {step 1}
    #   PRELIMINARY PHASE : load labels
    #   the third line {step 1} creates a unique name binding the column number and the name (e.g. "1","first" -> "1:first")
    #   this to avoid duplicates in column headings (there are some on datasource)
    #
    activities <- read.delim(paste0(loadpath,"/activity_labels.txt"),sep=" ",header=FALSE, col.names = c("activity_code","activity_name"))
    features <- read.delim(paste0(loadpath,"/features.txt"),sep=" ",header=FALSE, col.names = c("feature_column","feature_name"))
    features$feature_uniquename <- paste(features$feature_column,features$feature_name,sep = ":")
    
    #   MAIN PHASE
    #   two-step loop: the first one loads train data, the second one loads test data
    #   the [loadfile] variable uses substitution to point to X, Y or subject file "txt"
    #
    for (i in 1:2) {
        if (i==1)
            tmploadfile <- paste0(loadpath,"/train/0_train.txt")
        else
            tmploadfile <- paste0(loadpath,"/test/0_test.txt")
        
        loadfile <- sub("0","X",tmploadfile)
        
        #{step 3}   loads main data, columns are fixed width of 16, the number of them matches to the length of [features]
        tempdata <- read.fwf(loadfile,widths = rep(16,length(features$feature_uniquename)),header=FALSE)
        names(tempdata) <- features$feature_uniquename

        #{step 4}   loads activity codes
        loadfile <- sub("0","Y",tmploadfile)
        act_codes <- read.delim(loadfile,sep=" ",header=FALSE, col.names = c("activity_code"))

        #{step 5}   loads subjects codes
        loadfile <- sub("0","subject",tmploadfile)
        subj_codes <- read.delim(loadfile,sep=" ",header=FALSE, col.names = c("subject_code"))
        
        #{step 6}
        #   selects only column contining mean and std, then binds to subjects and actitivies codes
        #   the result is joined to [activity] to get the names
        tempdata <- inner_join(
                                cbind(
                                        subj_codes,
                                        act_codes,
                                        select(tempdata,contains("mean()"),contains("std()"))
                                    ),
                                activities, by = "activity_code"
                              )
        
        #{step 7}   performs a series of substitution on the column headings to make them more readable
        names(tempdata) <- gsub("^[^:]*:","",names(tempdata))
        names(tempdata) <- gsub("([a-z])([A-Z])", "\\1-\\2", names(tempdata))
        names(tempdata) <- gsub("([()])","", names(tempdata))
        names(tempdata) <- gsub("^t","Time", names(tempdata))
        names(tempdata) <- gsub("^f","Frequency", names(tempdata))
        
        #{step 8}   creates the dataframe or adds data (second iteration)
        if (i==1)
            HARdataset <- tempdata
        else
            HARdataset <- rbind(HARdataset,tempdata)
        
        #{step 9}   remove temporary dataset
        rm(tempdata)
        
        
    }
    
    return(HARdataset)
    
}


#   calcAvgHARdataset
#    
#   Creates a new dataframe using the previous one (HARdataset) as source.
#   Calculates the average for every data column, grouping by subject and activity.
#   the comments {step 1}..{step x} refer to the explanations on CodeBook.md
calcAvgHARdataset <- function(HARdataset){
    
    require(dplyr)
    
    #{step 1}   calculates averages by groups
    avgHARdataset <- 
        select(HARdataset,-activity_code) %>% 
        group_by(subject_code,activity_name) %>% 
        summarise_each(funs(mean))
    
    #{step 2}   prefixes each data column with "Avg-" to explain that values are averages
    names(avgHARdataset) <- gsub("(^[T|F])","Avg-\\1",names(avgHARdataset))
    avgHARdataset
}