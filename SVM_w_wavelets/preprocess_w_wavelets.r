## try using wavelet transform for SVM stroke classification

## load one large, flat, labeled, segmented .csv datafile
## in the case of "quick brown", there are not many unique strokes
##
## preprocess data:
##
## load data
## only grab strokes
## number the strokes for later ease
## 
## for each stroke
##    stroke_label = label  
##    for each param (acc_x, ...)
##      - X_param = resample from the wavelet transform to build input vector 
##          - X_param_scale = at each scale, according to (t_{end} - t_{start}) * 1/scale  (= total time * frequency)
##        X_param = concat(X_param_scales)
##    X_stroke = concat(X_param's)
##    ONLY CENTER, NORM ENTIRE STROKE INFORMATION
##    X^2_stroke = X_stroke * X_stroke
## input_vector_X = [X_stroke, X^2_stroke, stroke_length, stroke_label]^T  
## save all input_vectors to file (.csv) for processing with python SVM (and other ML methods)

rm(list = ls())

require(graphics)
library(wmtsa)


## ##################### Falk Data (segmented, labeled)  ############################

## segmented, labeled, full data
##infilename <- "../data/full_segmented_labeled_data/thequick/thequick.csv"
##pen.data = read.csv(infilename, header = TRUE, sep = ",")

## infilename <- "../data/full_segmented_labeled_data/thequick/thequick.Rdata"
## load(infilename)

## # get the list of parameters to process
## param_names <- names(pen.data)[-5:-1]

## ## automatically number the strokes
## ## find when the pen state changes
## ## diff vector with itself, prepend 0
## ## replace -1 with 0 in pen.change, find the cumulative sum
## ## append to pen.data
## pen.change = diff(pen.data$press)
## pen.change = append(0, pen.change)
## s <- pen.change + 1
## s <- floor(s/2)
## stroke_id = cumsum(s)
## pen.data$stroke_id <- stroke_id

## ## get the strokes only (not the space in between) # MAY HAVE TO PAD THIS OUT BEFORE AND AFTER STROKE
## with_strokes <- subset(pen.data, press == 1)

## free some memory
##rm(pen.data)

## split to individual strokes
##strokes <- split(with_strokes, with_strokes$stroke_id)
################### END FALK DATA  #####################

infilename <-  "../data/segmented_flat.Rdata"
load(infilename)

param_names <- names(pen.data)[-5:-1]

strokes <- split(pen.data, pen.data$Stroke_ID)

num_scales <- 7 # the number of different scales for the wavelet transform

## just take 20 samples at each scale, since the mean stroke length is 16
num_samples <- 20 # the number of samples to take per stroke

output_frame <- data.frame()


#stroke = subset(with_strokes, stroke_id == 1)

## for testing, shorten
#strokes = head(strokes)

#i = 0
for (stroke in strokes) {
#    print(i)
    label <- unique(stroke$label)
    stroke_length <- dim(stroke)[1] # the total "time" of the signal

    X_stroke <- c()
    X_2_stroke <- c()



                                        #param <- "acc_x"
    for (param in param_names) {

#        print(param)
        y <- signalSeries(stroke[[param]])
        
        ## calculate CWT using Mexican hat filter  CONSIDER USING SPLINE WAVELET
        wavelet_type <- "gaussian1"
        
        ## very discrete, only 7 scales from 2^1 to 2^6
        ## guaranteed to run on every signal
        ##        W <- wavCWT(y, wavelet=wavelet_type, n.scale = num_scales, scale.range = c(1, 64))

        num_scales = 4
        W <- wavCWT(y, wavelet=wavelet_type, n.scale = num_scales, scale.range = c(1, 8))
        
        ## more scales (5 per order of magnitude: 5 * 7 = 35)
        ##W <- wavCWT(y, wavelet=wavelet_type, n.scale = 35, scale.range = c(1, 64))

        ## get the time, frequency matrix of amplitudes
        ## first column is high-frequency, last column is low-frequency
        w_mat <- as.matrix(W)

        ## from 2^0 to 2^6
        X_param <- c()

                                        #scale = 1
        for (scale in 1:num_scales) {

            ## fit a spline to the scale column data
            scale_col_dat <- w_mat[,scale]
            f <- splinefun(scale_col_dat)
            
            ## resample from the spline, so that the number of samples is proportional to the frequency
            ##   sample_interval <- stroke_length / 2^(6 - scale)
            ##   sampling_times <- seq(1,stroke_length, sample_interval) # sample times according to interval
            ##   spline_samples <- f(sampling_times)
            ##            sample_interval <- stroke_length / num_samples
            sampling_times <- seq(1,stroke_length, length.out = num_samples)
            ##   sampling_times <- seq(1,stroke_length, sample_interval) # sample times according to interval
            spline_samples <- f(sampling_times)

            ## print("num samples")
            ## print(num_samples)
            ## print("stroke length")
            ## print(stroke_length)
            ## print("length of sampling times")
            ## print(length(sampling_times))
            
            X_param <- c(X_param, spline_samples)
        }

        X_stroke <- c(X_stroke, X_param)
        ##        print(length(X_stroke))
    }

    # outer product and flatten into vector
    X_stroke <- c(X_stroke)
#    X_2_stroke <- c(outer(X_stroke, X_stroke)) 

#    print("flattened, outer")
    
    ## center and normalize 
    variance_X <- var(X_stroke)
    X_stroke <- c(scale(X_stroke, center = TRUE, scale = variance_X))
#    variance_X_2 <- var(X_2_stroke)
#    X_2_stroke <- c(scale(X_2_stroke, center = TRUE, scale = variance_X_2))

#    print("centered, normed")

    ## for now, keep label as integer
    ## for now, don't do feature expansion, to save space
    ##    final_X <- c(X_stroke, X_2_stroke, stroke_length, label)
    final_X <- c(X_stroke, stroke_length, label)

    # print vector to .csv

    
#    print("built vector")
    
    ## now build output matrix

    temp_frame <- data.frame(t(final_X))

    output_frame <- rbind(output_frame, temp_frame)

#    i = i + 1
#    print("done once")
}
    

## save resulting vector as .csv file
outfilename <- "./feature_vector.csv"
write.table(output_frame, outfilename, sep = ",", row.names = FALSE, col.names = FALSE)
