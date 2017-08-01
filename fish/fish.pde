int nFish;
Fish[] fishArray;

int wiggleProb;

void setup()
{
  frameRate(24);
  size(1024, 1024);
  stroke(155);
  fill(255,0,0);
  
  nFish = 100;
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
    fishArray[f1] = new Fish(imageArrayFish1, floor(random(width)), floor(random(height)));
  }
  
  for (int f2=nFish/2; f2 < nFish; f2++)
  {
    fishArray[f2] = new Fish(imageArrayFish2, floor(random(width)), floor(random(height)));
  }
  
  wiggleProb = 5;
  
}

// Timer handler
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
     currentFish.Panic(mouseX, mouseY);
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
    int speed;   // linear speed, used with sin and cos to compute xVel and yVel
    int frameCounter;
    int panicRange;
    int orientation;  // this is in degrees. Has to be converted to radians when used in sin and cos
    boolean panicking;
    int panicCount;
    int panicInterval;
    
    Fish(PImage[] images, int startXLoc, int startYLoc)
    {
      this.images = images;

      xLoc = startXLoc;
      yLoc = startYLoc;
      speed = floor(random(4) + 2) * -1;

      orientation = 0;
      Turn(orientation);    // sets xVel and yVel
        
       panicRange = 250;
       panicking = false;
       panicCount = 0;
       panicInterval = 100;
    }
    
    void Draw()
    { 
      frameCounter = (frameCounter + 1) % images.length;
      PImage currentImage = images[frameCounter];
      
      pushMatrix();
      translate(xLoc,yLoc);
      rotate(radians(-orientation));
      image(currentImage, 0,0);
      popMatrix();
    }
    
    void Move()
    {
      if (panicking)
      {
        panicCount--;
        if (panicCount <= 0)
        {
          panicking = false;
          orientation = 0;
          Turn(orientation);
        }
      }
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
        
        if ((random(100) < wiggleProb) && (!panicking))
        {
          orientation = floor(random(30));  // we want them to aim basically forward. between -30 and 30 degrees
          if (random(10) < 5)
            orientation *= -1;
          Turn(orientation);
        }
    }
    
    void Stop()
    {
      xVel = 0;
      yVel = 0;
    }
    
    void Turn(int turnAngle)
    {
      float turnRadians = radians(turnAngle);
      xVel = floor(sin(turnRadians) * speed);
      yVel = floor(cos(turnRadians) * speed);
     
    }
    
    void Panic(int enemyX, int enemyY)
    {
      panicking = true;
      panicCount = panicInterval;  // The fish will panic for this many cycles
      
      if (enemyX < xLoc) // you are to the right of the mouse, so turn clockwise to flee
        orientation = -90;
      else
        orientation = 90;
      Turn(orientation);
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