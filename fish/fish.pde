int nFish;
Fish[] fishArray;

int wiggleProb;

void setup()
{
  frameRate(30);
  size(1024, 1024);
  stroke(155);
  fill(255,0,0);
  
  nFish = 20;
  fishArray = new Fish[nFish];
  
  int nFrames = 3;  //temp !!!
  PImage[] imageArrayFish1 = new PImage[nFrames];
  imageArrayFish1[0] = loadImage("fish1_0.png");
  imageArrayFish1[1] = loadImage("fish1_1.png");
  imageArrayFish1[2] = loadImage("fish1_2.png");
 
  PImage[] imageArrayFish2 = new PImage[nFrames];
  imageArrayFish2[0] = loadImage("fish2_0.png");
  imageArrayFish2[1] = loadImage("fish2_1.png");
  imageArrayFish2[2] = loadImage("fish2_2.png");
  
  for (int f1=0; f1 < nFish/2; f1++)
  {
    fishArray[f1] = new Fish(imageArrayFish1, 50 * f1, floor(random(height)));
  }
  
  for (int f2=nFish/2; f2 < nFish; f2++)
  {
    fishArray[f2] = new Fish(imageArrayFish2, 50 * f2 + 10, floor(random(height)));
  }
  
  wiggleProb = 10;
  
}

void draw()
{
  background(255);
  
  if (mousePressed)
    ellipse(mouseX, mouseY,25,25);
  
  for (int f=0; f<nFish; f++)
    fishArray[f].Draw();
   
  for (int f=0; f<nFish; f++)
    fishArray[f].Move();
}

void mouseClicked()
{ 
  for (int f=0; f<nFish; f++)
  {
    Fish currentFish = fishArray[f]; //<>//
    int checkPointX = currentFish.xLoc + currentFish.images[0].width;
    int checkPointY = currentFish.yLoc + currentFish.images[0].height;
  
    
    float distance = linearDistance(checkPointX, checkPointY, mouseX, mouseY);
    if (distance < currentFish.panicRange)
     currentFish.Stop();
  }
}

float linearDistance(int x1, int y1, int x2, int y2)
{
  // h**2 = horiz**2 + vert**2
  int horizontal = x2 - x1;
  int vertical = y2 - y1;
  float squaredDistance = (horizontal * horizontal) + (vertical * vertical);
  float distance = sqrt(squaredDistance);
  return distance;
}

//==================================================================================================

  //class declaration
  
  class Fish
  {
    int xLoc;
    int yLoc;
    PImage[] images; 
    int xVel;
    int yVel;
    int frameCounter;
    int panicRange;
    
    Fish(PImage[] images, int startXLoc, int startYLoc)
    {
      this.images = images;

      xLoc = startXLoc;
      yLoc = startYLoc;
      yVel = floor(random(4) + 1) * -1;
      xVel = floor(random(2) + 1);
       
      if (random(1) == 0)
        xVel *= -1;
        
       panicRange = 100;
    }
    
    void Draw()
    { 
      frameCounter = (frameCounter + 1) % images.length;
      PImage currentImage = images[frameCounter];
      image(currentImage, xLoc, yLoc);
    }
    
    void Move()
    {
      xLoc += xVel;
      yLoc += yVel;
      
      if (xLoc < 0)
        xLoc = width;
        
      if (xLoc > width)
        xLoc = 0;
        
      if (yLoc < 0)
        yLoc = height;
        
      if (yLoc > height)
        yLoc = 0;
        
        if (random(100) < wiggleProb)
          xVel *= -1;
    }
    
    void Stop()
    {
      xVel = 0;
      yVel = 0;
    }
    
    void Flip()
    {
      //if (xVel < 0)  // you are currently heading west; change your image to east
      //  displayImage = eastImage;
      //else
      //  displayImage = westImage;
        
      //xVel *= -1;
    }
    
    
    
  } // end class Fish