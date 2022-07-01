# Eye Tracking Accuracy Calculator
Shiny App for calculating spatial offset error in degreees by manually tagging the point of gaze and validation target from head-mounted eye tracking videos.
Author: John Franchak
[https://john-franchak.shinyapps.io/Eye-Tracking-Accuracy-Calculator/](https://john-franchak.shinyapps.io/Eye-Tracking-Accuracy-Calculator/)

### Status of tool

This project is a work in progress. The basic functions work: Setting the field of view of the camera, uploading a calibration image, drawing the validation offset, and saving the output. As of July 1, 2022, it still has not been tested extensively by different users across different inputs. If you find that it does not work with an image file that you believe should work, please log an issue on Github and provide an example image so that I can troubleshoot. 

More features are planned to improve the usability of the app:
- Uploading multiple images with an interface to move between images
- More detailed, customizable output file
- Ability to delete or edit already-logged validation points

### How to use the calculator

What you need:
- The **field of view** (in degrees) for the horizontal and vertical axes of your eye tracker's scene camera. This should be provided from the manufacturer. Not all scene cameras from the same manufacturer will have the same field of view (e.g., Positive Science sells standard and wide-angle scene cameras). It's critical to get the correct field of view, otherwise the pixels-to-degrees calculation will be incorrect.
- **Validation image files** that have a rendered point-of-gaze estimate (crosshair, bullseye, etc.) at moments where the participant is fixating a known target. The app opens up with an example image. Validation images can be exported from a rendered eye tracking video using ffmpeg, VLC, or a third-party video-to-frame tool. Screenshots will not yield an accurate result because the dimension of the screenshot won't perfectly match the dimension of the point-of-gaze video. 

What you do:
1. [Open the app](https://john-franchak.shinyapps.io/Eye-Tracking-Accuracy-Calculator/)
2. Enter the horizontal and vertical field of view in degrees
3. Use the file browser to upload a validation image
4. Use the mouse to drag between the actual point of gaze (where the eye tracker estimates that the participant is looking) and the validation target (where they are supposed to be looking). 
  a. A rectangular box will stay on the image (the diagonal of the box is the calibration error).
  b. The error of the point will show in the "current validation point" box
  c. Adjust it or redraw it to be located correctly
5. Click the "save validation point to table" button to accept the point
6. Repeat steps 3-5 with additional images to populate the table. As a rule of thumb, we assess the validity for a participant based on 5 successive video frames per validation target, using 5 validation targets in different locations across the field of view. 
7. Click download to export the degrees of accuracy to your local computer. Nothing will be retained/saved if you close and reopen the app (or leave the app idle for a while), so be sure to download the result of your work. 

