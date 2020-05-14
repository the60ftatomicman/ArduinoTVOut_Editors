# Arduino TVOut Powershell Scripts
I wrote these so I didn't have to get large java programs on my local computer, and so I could make custom fonts (ooOOoOOo) for the Arduino TVOut liberary

  - bitmapArduino.ps1 -- converts PNG and BMP's to the PROGMEM const unsigned char structure needed to show bitmaps
  - textmapArduino.ps1 -- converts PNG and BMP's to the PROGMEM const unsigned char structure needed to make fonts
  - 
### How it Works
- Only 255,255,255 pure white pixels are detected for what pixels to display
- bitmapArduino.ps1
    - draw an image
    - save as png or bmp
    -  .\bitmapArduino.ps1 <path to image>
    -  copy and paste the output of the code at the bottom of the script
    -  ex: .\bitmapArduino.ps1 .\test.png
- textmapArduino.ps1
    - draw an image
        - note the image file will be read assuming 1 pixel barriers will be between letters for both height and width 
    - save as png or bmp
    -  .\textmapArduino.ps1 <path to image> <letter height> <letter width> <start index>
        - if you open the powershell script you'll see the common indexes to start at for modifying the section you want of the structure.  
    -  copy and paste the output of the code at the bottom of the script
    -  ex: .\textmapArduino.ps1 .\test.png 6 8 33
### Theory!
Bitmaps and Arduino TVOut Library
- Looks like the structure below
>  // I think I drew an otter's body here
    {
    15 , 15 ,
    0x40,0x04,0x88,0x22,0x94,
    0x52,0x82,0x82,0x84,0x42,
    0x88,0x22,0x80,0x02,0x80,
    0x02,0x80,0x02,0x80,0x02,
    0x80,0x02,0x80,0x02,0x80,
    0x02,0x80,0x02,0x80,0x02 
    };
>
- Broken down it's {x,y,<hex values representing every 8 bits, each CHAR is 4 bits>}
- 0x40 really looks like <0100-0000> which means our second pixel in that set of 8 would be white
- While the first two indexes represent the true height and width of our image, the count of our hex values do not! We must round up to the nearest multiple of 8.

Text and Arduino TVOut Library
- Similar to bitmap, but represented as the actual bytes.
> {
8,6,32,
// !
0b01100000,
0b01100000,
0b01100000,
0b00000000,
0b01100000,
0b00000000,
// Now some other letter etc etc
>
- Broken down it's {bytes wide, text height, ??, <bytes representing lines of characters>
- I don't honestly know what the 32 stands for...something since it's a third of our character count at 96?
- Far less complicated. Just note EVERY chatacter is represented in the same structure. 
- Lower != Upper case as well.
- There is also an extra 0 byte added between [ and / in all fonts.
