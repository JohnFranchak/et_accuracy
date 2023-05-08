# Eye Tracking Accuracy Calculator
Shiny App for calculating spatial offset error in degreees by manually tagging the point of gaze and validation target from head-mounted eye tracking videos.

Author: John Franchak 

[https://john-franchak.shinyapps.io/Eye-Tracking-Accuracy-Calculator/](https://john-franchak.shinyapps.io/Eye-Tracking-Accuracy-Calculator/) 

If you use this tool in a paper, please cite it as: Franchak, J. (2022). Eye Tracking Accuracy Calculator (Version 0.2) [Computer software] 

### Status of tool

This project is a work in progress. The basic functions work: Setting the field of view of the camera, uploading a calibration image, drawing the validation offset, and saving the output. If you find that it does not work with an image file, please log an issue on Github and provide an example image so that I can troubleshoot. 

More features are planned to improve the usability of the app:
- Keyboard shortcuts
- Visualizing calibration on previously-coded frames

**Shinapps.io version**. My current account limits the number of hours/month that the app can be used. I'm working on a hosting solution, but I recommend for now that you download the repository and run the shiny app locally from RStudio. Simply open the .RProj file, install any needed packages, and then click on the "Run App" button—it will run locally on your own computer without any limits.

### How to use the calculator

What you need:
- The **field of view** (in degrees) for the horizontal and vertical axes of your eye tracker's scene camera. This should be provided from the manufacturer. Not all scene cameras from the same manufacturer will have the same field of view (e.g., Positive Science sells standard and wide-angle scene cameras). It's critical to get the correct field of view, otherwise the pixels-to-degrees calculation will be incorrect.
- **Validation image files** that have a rendered point-of-gaze estimate (crosshair, bullseye, etc.) at moments where the participant is fixating a known target. The app opens up with an example image. Validation images can be exported from a rendered eye tracking video using the bundled Matlab script, "extract_frames_time.m", with ffmpeg, VLC, or a third-party video-to-frame tool. Screenshots will not yield an accurate result because the dimension of the screenshot won't perfectly match the dimension of the point-of-gaze video. 

What you do:
1. [Open the app](https://john-franchak.shinyapps.io/Eye-Tracking-Accuracy-Calculator/)
2. Go to the setup tab and enter the horizontal and vertical field of view in degrees
3. Use the file browser to upload a set of validation images (no more than 25 at a time recommended because of UI limits
4. Use the mouse to drag between the actual point of gaze (where the eye tracker estimates that the participant is looking) and the validation target (where they are supposed to be looking). 
  a. A rectangular box will stay on the image (the diagonal of the box is the calibration error).
  b. The error of the point will show in the "current validation point" box
  c. Adjust it or redraw it to be located correctly
5. Click the "save validation point to table" button to accept the point
6. Repeat steps 3-5 with additional images to populate the table. As a rule of thumb, we assess the validity for a participant based on 5 successive video frames per validation target, using 5 validation targets in different locations across the field of view. 
  a. You can click on any row to pull up an image and record a measurement for that image
  b. If you want to overwrite an image, just re-record the measurement. If there's no box drawn on the image, saving the point it will clear the measurement for that image.
  c. You can use the previous/next images to move more quickly between images.
  d. You can use the "Save Validation and Advance" button to record a measurement and then immediately move to the next frame.
7. Click download to export the degrees of accuracy to your local computer. Nothing will be retained/saved if you close and reopen the app (or leave the app idle for a while), so be sure to download the result of your work. 
  a. The exported file will also include the image resolution (automatically detected in pixels) and the user-input field of view (in degrees) used to make the calculation.   

