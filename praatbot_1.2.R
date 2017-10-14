# This is a script to automatically compile Praat .txt outputs into Excel spreadsheets.
# written by Randy Gao
# Load "dplyr" and "writexl" package. If they are not yet installed, 
# install the packages and load them.
if(!require(dplyr)){
    install.packages("dplyr")
    library(dplyr)
}

if(!require(writexl)){
    install.packages("writexl")
    library(writexl)
}

# Part I: Pitch Results
setwd("./output/pitch/") # replace the path with wherever the .txt files are
filelist <- list.files() # get all file names in the folder
filelist <- sub("\\.txt$", "", filelist) # remove extensions from the file names
pitch_results <- tibble()

prato <- function(name) {
	# 1. Use data.table to read Praat's .txt output. Save the file names.
	df1 <- read.table(paste0(name, ".txt"), header = T) %>%
	as_tibble() %>% mutate(pitch = as.numeric(paste(F0_Hz)))

	# 2. Get each dataframe's lengths and pauses and calculate proportion of pauses.
	stats <- data.frame(track = paste(name), length = as.numeric(tally(df1)), 
	pause = as.numeric(tally(df1, is.na(pitch)))) %>%
	as_tibble() %>%
	mutate(pause_percent = pause / length * 100, length = length / 100) 

	# 3. Categorize the tracks.
	stats <- stats %>%
	mutate(language = case_when(grepl("MAN", as.character(track)) ~ "Chinese", 
		grepl("ENG", as.character(track)) ~ "English",
		grepl("HIN", as.character(track)) ~ "Hindi", 
		grepl("SPA", as.character(track)) ~ "Spanish"),
		id = unique(na.omit(as.numeric(unlist(strsplit(as.character(track), "[^0-9]+"))))), 
		mind = case_when(grepl("MF", as.character(track)) ~ "mindful", grepl("ML", as.character(track)) ~ "mindless"), 
		story = case_when(grepl("EMO", as.character(track)) ~ "emotion", grepl("DEC", as.character(track)) ~ "decision"),
		gender = case_when(grepl("M$", as.character(track)) ~ "male", grepl("F$", as.character(track)) ~ "female") 
		)

	# 4. Get each dataframe's summary statistics and save them.
	pitch_results <<- mutate(stats,
	mean = mean(df1$pitch, na.rm = TRUE), sd = sd(df1$pitch, na.rm = TRUE),
	min = min(df1$pitch, na.rm = TRUE), max = max(df1$pitch, na.rm = TRUE)) %>%
	select(-track, -pause) %>%
	bind_rows(pitch_results)
}

# 4. Run through each track.
invisible(lapply(filelist, prato))

pitch_results %>% as.data.frame %>% 
writexl::write_xlsx("../pitch_results.xlsx")
pitch_results

# Part II: Intensity Results
setwd("../intensity") # replace the path with wherever the .txt files are
filelist <- list.files() # get all file names in the folder
filelist <- sub("\\.txt$", "", filelist) # remove extensions from the file names
intensity_results <- tibble()


prato <- function(name) {
	# 1. Use data.table to read Praat's .txt output. Save the file names.
	df1 <- read.table(paste0(name, ".txt"), header = T) %>%
	as_tibble() %>% mutate(amplitude = as.numeric(paste(Intensity_dB)))

	# 2. Get each dataframe's lengths and pauses and calculate proportion of pauses.
	stats <- data.frame(track = paste(name), length = as.numeric(tally(df1)) / 100) %>%
	as_tibble()

	# 3. Categorize the tracks.
	stats <- stats %>%
	mutate(language = case_when(grepl("MAN", as.character(track)) ~ "Chinese", 
		grepl("ENG", as.character(track)) ~ "English",
		grepl("HIN", as.character(track)) ~ "Hindi", 
		grepl("SPA", as.character(track)) ~ "Spanish"),
		id = unique(na.omit(as.numeric(unlist(strsplit(as.character(track), "[^0-9]+"))))), 
		mind = case_when(grepl("MF", as.character(track)) ~ "mindful", grepl("ML", as.character(track)) ~ "mindless"), 
		story = case_when(grepl("EMO", as.character(track)) ~ "emotion", grepl("DEC", as.character(track)) ~ "decision"),
		gender = case_when(grepl("M$", as.character(track)) ~ "male", grepl("F$", as.character(track)) ~ "female") 
		)

	# 4. Get each dataframe's summary statistics and save them.
	intensity_results <<- mutate(stats,
	mean = mean(df1$amplitude, na.rm = TRUE), sd = sd(df1$amplitude, na.rm = TRUE),
	min = min(df1$amplitude, na.rm = TRUE), max = max(df1$amplitude, na.rm = TRUE)) %>%
	select(-track) %>%
	bind_rows(intensity_results)
}

# 4. Run through each track.
invisible(lapply(filelist, prato))
intensity_results %>% as.data.frame %>% 
writexl::write_xlsx("../amplitude_results.xlsx")
intensity_results
