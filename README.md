### srtadjust

program to adjust time codes in a srt subtitle file.  
Provide as cmd line args: the input file, time in milliseconds to offset time codes, integer off set for subtitle numbering, and the output file to write to.


### flags
- -h
  - print help message
- --help
  - print help message
- -l
  - increment or decrement the duration that the subtitle is shown on screen rather than offsetting the time code of when the subtitles appear on screen.
- -b
  - increment the time code in which the subtitle appears on screen plus also increment or decrement the duration that the subtitle is shown on screen.

### example1:
input file:  
```
1
00:03:13,026 --> 00:03:15,427
What a surprise!

2
00:03:15,962 --> 00:03:22,067
We never expected a military band!
Such fun!

3
00:03:25,538 --> 00:03:30,342
We're not often entertained like this!

```
using this command we will increment the time code when the subtitles appear on screen by one second, we also increase subtitle number by two:  
```lua srtadjust inputfile 10000 2 outputfile```  
it will write this to 'outputfile'  
```
3
00:03:23,026 --> 00:03:25,427
What a surprise!

4
00:03:25,962 --> 00:03:32,067
We never expected a military band!
Such fun!

5
00:03:35,538 --> 00:03:40,342
We're not often entertained like this!

```

subtitle numbers are incremented by 2 and all timecodes are increased by 10 seconds.

### example2  
using the input file from example1 we will adjust the subtitles to stay on screen for one second longer:  
using this command:  
```lua srtadjust -l inputfile 1000 0 outputfile```  
it will write this output file:  
```
1
00:03:13,026 --> 00:03:16,427
What a surprise!

2
00:03:15,962 --> 00:03:23,067
We never expected a military band!
Such fun!

3
00:03:25,538 --> 00:03:31,342
We're not often entertained like this!

```

the subtitles now stay on screen for one second longer.  


### example3  
using the input file form example 1 we can increase the time code when subtitles appear by two seconds and also increase the duration they stay on screen by one second: 

using this command:  
```lua srtadjust -b inputfile 2000 0 1000 outputfile```  
it will write this output file:  
```
1
00:03:15,026 --> 00:03:18,427
What a surprise!

2
00:03:17,962 --> 00:03:25,067
We never expected a military band!
Such fun!

3
00:03:27,538 --> 00:03:33,342
We're not often entertained like this!

```

the subtitles now appear on screen two seconds later but also stay on screen for one second longer than previous.

