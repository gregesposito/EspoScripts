@echo off
set /p input="Insert your Http link: "
set /p input1="Insert your Local IP address: "
rem VLC
cd "C:\Program Files\VideoLAN\VLC"

start vlc.exe %input% :sout=#transcode{vcodec=VP80,vb=2000,acodec=vorb,ab=128,channels=2,samplerate=44100}:http{mux=webm,dst=:8080/stream} :sout-all :sout-keep

cd "C:\Program Files (x86)\Google\Chrome\Application"
start chrome.exe "https://dabble.me/cast/?video_link=http://%input1%/stream"
exit