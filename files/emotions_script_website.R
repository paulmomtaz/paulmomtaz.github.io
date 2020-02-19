# THIS SCRIPT WAS USED FOR THE PAPER: "CEO EMOTIONS AND FIRM VALUATION IN INITIAL COIN OFFERINGS: AN ARTIFICIAL EMOTIONAL INTELLIGENCE APPROACH" (PAUL MOMTAZ, 2020)
## THIS SCRIPT ESTIMATES SEVEN BASIC EMOTIONS FROM FACIAL EXPRESSIONS (EKMAN, 1999)
### THE SCRIPT CAN DEAL WITH PHOTOS. VIDEOS AS INPUT MATERIAL NEED TO BE SPLITTED INTO FRAMES FIRST.
#### THE SCRIPT RELIES ON MICROSOFT'S FACE API AND CAN BE CONNECTED TO OTHER DATABASES/PROGRAMS.

options(stringsAsFactors = FALSE)

# Load neccessary packages
if (!require(openxlsx)) {
  install.packages("openxlsx")
}
if (!require(httr)) {
  install.packages("httr")
}
if (!require(dplyr)) {
  install.packages("dplyr")
}

library(openxlsx)
library(httr)
library(dplyr)


# Input initial settings
file_name <- "YOUR-FILE-NAME.xlsx"
url_column_name <- "photo"
bad_url_values <- c("", "N/A", "No Pic Found")

FaceAPI_url <- "YOUR-LINK"
# For example: https://westus.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=false&returnFaceLandmarks=false&returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur,exposure,noise
FaceAPI_key <- "YOUR-KEY"


# Read Excel file
file_data <- read.xlsx(file_name)

# Run loop over rows
cat("Start of processing...\n")
result <- lapply(1:nrow(file_data), function(rown) {
  
  img_url <- file_data[rown, url_column_name]
  cat(paste0("URL #", rown, "   ", img_url, "\n"))
  
  # check if link is meaningful
  if (is.na(img_url) || (img_url %in% bad_url_values)) {
    
    cat("Bad URL\n\n")
    return(NULL)
    
  } else {
    
    result <- NULL
    
     #tryCatch({
      
      if (!startsWith(img_url, "http")) {
       img_url <- paste0("https://", img_url)
      }
      
      # make request to FaceAPI
      request <- POST(
        url = FaceAPI_url,
        content_type('application/json'), 
        add_headers(.headers = c('Ocp-Apim-Subscription-Key' = FaceAPI_key)),
        body = list(url = img_url),
        encode = 'json'
      )
      
      # process request result
      if (request$status_code == 200) {
        
        result <- content(request)[[1]]
        result <- result$faceAttributes
        result$hair$hairColor <- lapply(result$hair$hairColor, function(x) {
          y <- list(x$confidence)
          names(y) <- paste0(x$color, "_confidence")
          y
        })
        result <- as.data.frame(t(unlist(result)))
        
        cat("Processed successfully\n\n")
        
      } else {
        
        result <- content(request)
        cat(paste0("Error: ", result$error$message, "\n\n"))
        result <- NULL
        
      }
      
    #}, error = function(err) {
      
   #   cat("Unknown error\n\n")
  #    result <<- NULL
      
  #  })
    
    # make pause before next request (limit 20 requests/minute)
    Sys.sleep(3.5)
    
    return(result)
    
  }

})
# End of loop
cat("Processing finished\n")


# Append result to data
result <- lapply(result, function(x) if (is.null(x)) data.frame(smile = NA) else x)
result <- do.call(bind_rows, result)
file_data <- cbind(file_data, result)

# Write to new Excel file
output_file_name <- paste0("Processed", file_name)
write.xlsx(file_data, output_file_name)
