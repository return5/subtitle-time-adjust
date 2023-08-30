--[[
	stradjust: program to adjust the time codes in a srt subtitle file.
	must provide inputfile, time code offset in milliseconds,number offset as integer, and output file.
	stradjust [flags] [input] [timeOffset] [numOffset] [outputFile]
    Copyright (C) <2023>  <return5>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local floor <const> = math.floor

local function getMils(h,m,s,mil) return h * 3600000 + m * 60000 + s * 1000 + mil end

local function getHours(time) return floor(time / 3600000 ) end

local function removeHours(time) return time % 3600000 end

local function removeMins(time) return time % 60000 end

local function getMinutes(time) return floor(time / 60000) end

local function getSeconds(time) return floor(time / 1000 ) end

local function getMilSec(time) return floor( time % 1000 ) end

local function leadingZero(time) return time < 10 and "0" .. time or time end

local function leadingZeroMS(time) return (time < 10 and "00" .. time) or (time < 100 and "0" .. time) or time end

local function adjustTime(time)
	local hour <const> = getHours(time)
	local noHour <const> = removeHours(time)
	local minutes <const> = getMinutes(noHour)
	local noMin <const> = removeMins(noHour)
	local sec <const> = getSeconds(noMin)
	local mils = getMilSec(noMin)
	return hour,minutes,sec,mils
end

local function writeSub(num,t1,t2,sub,file)
	local h1 <const>,m1 <const>,s1 <const>,ms1 <const> = adjustTime(t1)
	local h2 <const>,m2 <const>,s2 <const>,ms2 <const> = adjustTime(t2)
	file:write(num,"\n",leadingZero(h1),":",leadingZero(m1),":",leadingZero(s1),",",leadingZeroMS(ms1)," --> "
	,leadingZero(h2),":",leadingZero(m2),":",leadingZero(s2),",",leadingZeroMS(ms2),"\n",sub,"\n\n")
end

local function printHelp()
	io.write("program to adjust the time codes of subtitles.\n", "srtadjust [flags] [inputfile] [timeOffset] [numOffset] [outputfile]\n",
	"\tinputfile: srt file which contains the subtitles.\n", "\ttimeOffset: time in milliseconds to adjust the subtitles.\n",
	"\tnumOffset: integer value to increase the subtitle count by.\n", "\toutputfile: file to write the adjusted subtitles to.\n",
	"  flags\n", "\t-h --help  printHelp message.\n",
	"\t-l instead of offsetting both time codes,instead increase time subtitles on screen by milliseconds.\n",
	"\t-b offset timecodes and also increase time of subtitles on screen. this options requires 5 args:\n",
	"\t\tsrtadjust -b [inputfile] [timeOffset] [numOffset] [displayIncr] [outputfile]\n")
end

local function printAndExit() printHelp();os.exit(-1) end

local function checkInputs(input,message) if not input then io.stderr:write(message);printAndExit() end end

local function checkInputArgs(inputI,timeI,numI,outputI)
	local offset <const> = arg[timeI]
	checkInputs(offset,"error: did not include timeOffset.\n")
	if not tonumber(offset) then checkInputs(false,"Error, timeOffset is not a number.\n") end
	local numOffset <const> = arg[numI]
	checkInputs(numOffset,"error: did not include numOffset.\n")
	if not tonumber(numOffset) then checkInputs(false,"Error, numOffset is not a number.\n") end
	checkInputs(arg[outputI],"error: did not include output file.\n")
	return {arg[inputI],offset,numOffset,arg[outputI]}
end

local function lFlag()
	checkInputs(#arg <= 5, "error: too many arguments.\n")
	return checkInputArgs(2,3,4,5)
end

local function bFlag()
	checkInputs(#arg <= 6, "error: too many arguments.\n")
	checkInputs(arg[5],"error: did not include displayIncr.\n")
	if not tonumber(arg[5]) then checkInputs(false,"error: displayIncr is not a number.\n") end
	local t <const> = checkInputArgs(2,3,4,6)
	t[#t + 1] = arg[5]
	return t
end

local function main()
	checkInputs(arg[1],"error: did not include any arguments.\n")
	local flagsTable <const> = {["-h"] = printAndExit, ["--help"] = printAndExit, ["-b"] = bFlag,["-l"] = lFlag}
	local input,offset <const>,numOffset <const>,output <const>,displayIncr <const> = table.unpack((flagsTable[arg[1]] and flagsTable[arg[1]]()) or checkInputArgs(1,2,3,4))
	local file = io.open(input,"r")
	checkInputs(file,"error: cannot open file\n")
	local text  <const> = file:read("*a")
	file:close()
	local outputFile <const> = io.open(output,"w+")
	checkInputs(outputFile,"error: cannot open output file.\n")
	local t1Offset <const> = arg[1] == "-l" and 0 or offset
	local t2Offset <const> = arg[1] == "-b" and offset + displayIncr or offset
	for num,h1,m1,s1,ms1,h2,m2,s2,ms2,sub in text:gmatch("(%d+)%s+(%d+):(%d+):(%d+),(%d+)%s*%-%-%>%s*(%d+):(%d+):(%d+),(%d+)%s+([%g%s]-)[\n\r][\n\r]") do
		local t1 <const> = getMils(h1,m1,s1,ms1) + t1Offset
		local t2 <const> = getMils(h2,m2,s2,ms2) + t2Offset
		writeSub(num + numOffset,t1,t2,sub,outputFile)
	end
	outputFile:close()
end

main()
