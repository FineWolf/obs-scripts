# Random Stinger Video

This OBS Studio Script automatically sets a new video to a stinger transition every single time the scene changes.

## Credits

 - **[FineWolf](https://twitter.com/FineWolf) (me)**: Development.
 - **[extraxterrestrial](https://twitter.com/extrax_el)**: Original Idea, Bug Finding, Refining.

## Installation Instructions

> ℹ **Important**:  
> This script does not make any changes to the stinger transition
> source other than the video path. All videos part of the rotation must
> therefore have the exact same transition point and/or track matte settings.

1. Store all the video files you want to be part of your rotation within a folder.
2. Download the `RandomStingerVideo.lua` file to your computer.
   (Right click on [this link](https://raw.githubusercontent.com/FineWolf/obs-scripts/master/RandomStingerVideo/RandomStingerVideo.lua) › Save link as...)
3. From the **Scene Transitions** panel in OBS Studio, create a new Stinger transition. Give it any name you want.
4. Configure the new **Stinger transition** according to the video files you want on rotation (you can configure it as
   if you would configure a normal Stigner transition for one of the videos in the folder).
5. Open the **Scripts** window (**Tools** Menu › **Scripts**).
6. Load the `RandomStingerVideo.lua` script.
7. In the settings panel on the right side, select the **Stinger transition** configured during **Step 4** in the *Transition* dropdown list.
8. In the settings panel on the right side, in the *Video folder* input, navigate to the folder created during **Step 1**.

## Changelog

### Version 1.03

- Initial Public Release