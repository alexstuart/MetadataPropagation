#!/usr/bin/env Rscript --vanilla
#

help <- function() {
	cat("\nusage: plot.R [-h] <results file>\n\n")
}

args<-commandArgs(TRUE)
if ( length(args) == 0 ) { 
	cat ("ERROR: Must provide a results file\n") 
	help()
	q(status=1)
}
if ( args[[1]] == "-h" ) {
	help()
	q(status=0)
}

inputfile <- args[[1]]
# Check if this script can read inputfile
if (file.access(inputfile, 4) != 0 ) {
	cat ("ERROR: input file '", inputfile, "' must be readable\n", sep="")
	q(status=1) 
}

# Ensure outputfile doesn't exist
outputfile <- paste0(inputfile, ".png")
if (file.exists(outputfile) != 0 ) {
        cat ("ERROR: output file '", outputfile, "' already exists\n", sep="")
        q(status=1) 
}

data <- read.table(inputfile, sep=" ")
timestamp <- strptime( data$V1, tz = "UTC", "%Y-%m-%dT%H:%M:%SZ")
png(outputfile)
plot(timestamp, data$V2, type="l", xlab="Time", ylab="Number of IdPs which have downloaded metadata", main="Metadata propagation through the UK federation")
dev.off()

