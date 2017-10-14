######################################################
######################################################
# Pitch and intensity reading script, Randy Gao, 2017
# Adapted from Formant reading script by Daniel Briggs:
# http://praatscriptingtutorial.com/filesExtendedExample
#
#
# This script will open every .wav file in a folder, 
# and export their pitch and intensity listings.
#
#
# This script expects that in the same folder as this
# script, there is another folder called "data", that 
# contains .wav files. It will create a folder "output", 
# and make a value-separated spreadsheet.
#
#
#####################################################
#### Don't change anything below unless you want to 
#### alter how the script works
#####################################################
clearinfo

# Will use the directory containing the script
wd$ = "./"

# input directory
inDir$ = wd$ + "data/"
# I know I'll want only wav files
inDirWavs$ = inDir$ + "*.wav"

# make sure inDir$ exists
if not fileReadable: inDir$
	exitScript: "The input folder doesn't exist"
endif

# out file
outDir$ = wd$ + "output/"
pitchOutDir$ = outDir$ + "pitch/"
intensityOutDir$ = outDir$ + "intensity/"


# if the output folder doesn't exist, create it.
# This won't throw an error if it already exists.
createDirectory: outDir$
createDirectory: pitchOutDir$
createDirectory: intensityOutDir$

###### Get a list of wav files in the input directory
wavList = Create Strings as file list: "wavList", inDirWavs$

numFiles = Get number of strings
for fileNum from 1 to numFiles

	selectObject: wavList
	wavName$ = Get string: fileNum

	wavPath$ = inDir$ + wavName$

	wav = Read from file: wavPath$
	# get object name
	objName$ = selected$: "Sound"
	appendInfoLine: "analyzing pitch for " + objName$

	if (endsWith(objName$, "M"))
		minHz = 75
	else
		minHz = 150
	endif

	writeFileLine: pitchOutDir$ + objName$ + ".txt", "Time_s", "   ", "F0_Hz"

	timeStep = 0.01

	# set minimum Hz for males
	# mminHz = 75 
	# set minimum Hz for females
	# fminHz = 150
	# set maximum Hz
	maxHz = 500

	# create a pitch object
	selectObject: wav
	tmin = Get start time
	tmax = Get end time

	pitchObj = To Pitch: 0.001, minHz, maxHz

#
			for i to (tmax - tmin)/0.01
				time = tmin + i * 0.01
				# selectObject: pitchObj
				pitchObj = Get value at time: time, "Hertz", "Linear"
				appendFileLine: pitchOutDir$ + objName$ + ".txt", fixed$ (time, 2), "   ", fixed$ (pitchObj, 6)

	endfor

	removeObject: wav
	# removeObject: pitchObj

endfor

# Now we do the same thing with intensity

for fileNum from 1 to numFiles

	selectObject: wavList
	wavName$ = Get string: fileNum

	# some specification for intensity, not needed for now

	# set minimum dB for males
	# mminHz = 75 
	# set minimum dB for females
	# fminHz = 150
	# set maximum dB
	# maxHz = 500

	wavPath$ = inDir$ + wavName$

	wav = Read from file: wavPath$
	# get object name
	objName$ = selected$: "Sound"
	appendInfoLine: "analyzing intensity for " + objName$

	writeFileLine: intensityOutDir$ + objName$ + ".txt", "Time_s", "   ", "Intensity_dB"


	timeStep = 0.01

	# create a pitch object
	selectObject: wav
	tmin = Get start time
	tmax = Get end time

	intensityObj = To Intensity: 75, 0.001

#
			for i to (tmax - tmin)/0.01
				time = tmin + i * 0.01
				# selectObject: pitchObj
				intensityObj = Get value at time: time, "Cubic"
				appendFileLine: intensityOutDir$ + objName$ + ".txt", fixed$ (time, 2), "   ", fixed$ (intensityObj, 6)

	endfor

	removeObject: wav
	# removeObject: intensityObj

endfor

removeObject: wavList

exitScript: "Task completed!"