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



