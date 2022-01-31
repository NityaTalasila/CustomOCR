# Custom_OCR

This project was created to read two values from a Parvo medical cart, a device that measures metabolic rates of a human being. These values were used to access the impact of a hip-exoskeleton manufactured by a robotics lab at Georgia Institute of Technology. Ideally, this hip-exoskeleton would reduce the metabolic cost as it provides support for paralyzed patients during a walking period. 

It was necessary to retreive the metabolic values in real time to modify resistance parameters of the device. This allowed for the exoskeleton to be personalized to each patient based on each step in real time. The Parvo cart, however, did not have a way for the numbers to be retreived in real time. To make this project possible, I used OCR and a webcam to read the metabolic rates from the Parvo cart's screen itself. 

In the drive link below you will find webcam footage of the Parvo screen (input_video) and the modified video after running through some post-processing code (output_video). The input of the webcam would post-processed through ocr_processing.m in real time and the values in each frame would be outputted as a dynamic variable. This allowed the researcher to read metabolic values in real time and modify resistance parameters of the robotic exoskeleton to ensure reduction of metabolic cost. 

https://drive.google.com/drive/folders/1ulSrZDjRCo9nsode7uVrbRaNin6HWHZj?usp=sharing
