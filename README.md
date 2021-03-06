# GUI for SATP Validation Experiments

Hi, thanks for checking out this repository! This repository contains the MATLAB code that our team from Nanyang Technological University (NTU), Singapore is using for our Stage 2 validation experiments for the Soundscape Attributes Translation Project (SATP). The GUI runs in two modes:

  - **Debug mode** - Used for debugging or simple exploration (video demonstration available at https://youtu.be/TRRQxgYLnUE)
  - **Live (non-debug) mode** - Used for actual implementation of experiment with participants (video demonstration available at https://youtu.be/LyxceoRABsc)

The readme is currently a work in progress (we're looking to add more documentation and usage help), but the code files themselves (under `./code`) already contain some detailed comments and documentation, so please feel free to download them and have a look.

# Quickstart

After downloading this repository, run the MATLAB script at `./code/main.m`. When prompted to choose whether you want to enter debug mode, enter `0` to start a sample run of the GUI in live (non-debug) mode, or `1` to start a sample run of the experiment in debug mode.

# Environment

This GUI was designed and tested on a Windows 10 laptop running MATLAB R2018b at a screen resolution of 1920 x 1080. To our knowledge, the GUI doesn't use any functionalities that appeared in MATLAB after R2015b, so it should be fine running on anything after R2015b though we can't guarantee that. In addition, the code used to generate the GUI should adapt all the font sizes and layout to your current screen resolution, but in case any display issues occur on your end, please try setting your screen resolution to 1920 x 1080 and see if that fixes your issue.

# Contact

If you discover any bugs or problems with the code, please drop me (Kenneth) an email at wooi002@e.ntu.edu.sg. Feel free to use the code for your own SATP validation experiments (you will have to translate the text by yourself, however). If you want to repurpose the code for other subjective experiments outside of the SATP validation experiments, feel free to do so as well, but in that case, I would appreciate it if you could acknowledge us (according to the metadata in `CITATION.cff`) in any work or publication that results from those experiments. Thank you :)
