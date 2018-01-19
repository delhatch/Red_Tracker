# Red_Tracker

This project interfaces with a D8M camera module by Terasic. It detects any red object, and tracks it.

![Demo_video](https://github.com/delhatch/Red_Tracker/blob/master/aaa_demo_video.mp4)

![image](https://github.com/delhatch/Red_Tracker/blob/master/screenshot.JPG)

The incoming camera video (at 60 fps) is filtered for red pixels and creates a frame buffer. This red-pixel frame buffer is shown on the MP4 video file.

It then finds the center of the largest red mass, and overlays a crosshair on it.

This project uses the Cyclone IV FPGA used in the DE2-115 evaluation board to:

a) configure and interface to the camera module

b) buffer the raw video into an SDRAM frame buffer

c) simultaneously, detect red pixels and create a second frame buffer

d) while doing this, also low-pass filters that video,

e) and also while creating/filtering the second frame buffer, detect the largest red mass

f) generate the x,y coordinate of the center of the red mass

g) overlay a crosshair onto the video going to the VGA output

h) FPGA also has a VGA frame buffer and creates the VGA waveform


*** Possible Improvements ***

1) Could create a PWM signal to drive servo motors to move the camera to track the red object.

2) Fire a nerf cannon at the red object.
