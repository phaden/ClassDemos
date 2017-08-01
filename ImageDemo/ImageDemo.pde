// The array will hold a set of PImage objects.
// We put the images in however we want.
// We can select whichever one we want by accessing its position in the array

PImage[] imageArray; 
int imageIndex;  // Will hold the position of the image we want
int imageCount;  // Will hold the number of images, so we know how big an array to create

// There is only one cover image, so we'll keep it in its own variable
PImage coverImage;

// These variables will hold the pixel value of the left edge of the foreground and background images
int imageLeft;
int coverLeft;


// Initialisation code goes here
void setup() 
{
  size(720, 960);
  
  // Creating space in memory for the array, and loading the images
  imageCount = 3;
  imageArray = new PImage[imageCount];
  imageArray[0] = loadImage("alpaca.jpg");
  imageArray[1] = loadImage("cat.jpg");
  imageArray[2] = loadImage("shaggycow.jpg");
  
  // Locations in arrays are numbered starting with 0, not 1.
  // Need to start somewhere, so we'll start with the first image.
  imageIndex = 0;
  imageLeft = 0;
  
  // Initialise the cover image
  coverImage = loadImage("cows.jpg");

}

// When the user clicks, increase the imageIndex so next time we grab from the array, we grab a new location
// The % operator makes this increasing wrap around 0, 1, 2, 0, 1, 2, etc. so we always access a location 
// in the array.
void mouseClicked()
{
  imageIndex = (imageIndex + 1) % imageCount;
}


// When the mouse is dragged, we compute the position of the two images, foreground and background, and draw them
void mouseDragged()
{
  // The foreground image starts at the mouse position, and doesn't disappear off the left-hand edge. It stops at 0
  
  // Set the left edge location
  coverLeft = mouseX;
  if (coverLeft < 0)
    coverLeft = 0;
  
  // Draw it  
  image(coverImage,coverLeft,0); 
  
  
  // The background image must be placed so that its right-hand edge abuts the left-hand edge of the cover
  // So if the cover image start, say 10 pixels in from the right hand edge, we need to shove the background image *off* the left of the screen by 10 pixels
  // The equation below computes this value.
  // A negative pixel location means "off the left edge of the screen"
  
  imageLeft = -(width - coverLeft);
  if (imageLeft > 0)
    imageLeft = 0;
    
  // We don't want the background image to wander off the right-hand edge of the screen though, so we stop it here  
  image(imageArray[imageIndex], imageLeft, 0);
}
  

// This is running method (not sure what the framerate is...)
// Just use this to keep the screen refreshed.
void draw() 
{ 
  // when the mouse isn't pressed
  image(imageArray[imageIndex], imageLeft, 0); 
  
  // when the mouse is pressed
  image(coverImage, coverLeft, 0);
}