import KinectPV2.*;


static class SimParams
{
  static int WiggleProb = 1;            // probability (out of 100) that each fish reorients at each frame 
  static int WiggleIntensity = 5;      // Range, in degrees, of wiggling angle (i.e. heading from straight forward. +/-, uniformly distributed)
  static int FrameRate = 10;             // unit is frames per second. Max = 60
  static int ScreenSize = 1024;         // Pixel size of visible screen area -- it's square at the moment
  static int TotalNumberOfFish = 20;  // Currently equally divided between two visual types
  static int FramesInAnimation = 40;    // Currently the same for all the fish types
  static int FishSpeed = 10;          // upper bound of linear pixel distance per frame (uniformly distributed). Large => more variability across fish
  static int MinimumFishSpeed = 3;    // baseline speed. Larger => faster overall motion
  static int PanicRange = 200;        // How close the mouseclick must be to cause avoidance
  static int PanicInterval = 50;     // How many frames it takes to return to normal swimming
  static int PanicOrientation = 45;   // Avoidance orientation. 90 =  all the way toward the edge
  static int ScaleFactor = 3;        // Size the images to the visible space
  static int EdgeAvoidanceTurnSize = 2; // in degrees. Keeps the fish more in the middle
  static int EdgeAvoidanceMoveSize = 1;
}


int nFish;
Fish[] fishArray;
KinectPV2 kinect;
boolean someoneHere;
PImage backgroundImage;

//====================================================================================
void setup()
{
  frameRate(SimParams.FrameRate);
  //size(SimParams.ScreenSize, SimParams.ScreenSize); // Not permitted. Seems dumb. PEH.
  size(1024,1024);
  backgroundImage = loadImage("water.jpg");
  
  stroke(155);
  fill(255,0,0);
  
  kinect = new KinectPV2(this);
  kinect.enableBodyTrackImg(true);
  kinect.init();
  someoneHere = false;
  
  nFish = SimParams.TotalNumberOfFish;
  fishArray = new Fish[nFish];
  
  int nFrames = SimParams.FramesInAnimation; 
  PImage[] troutImageArray = new PImage[nFrames];
  for (int i=0; i<nFrames; i++)
  {
    String troutFileName = "troutfish_000";
    if (i < 10)
      troutFileName += "0";
    troutFileName += String.valueOf(i) + ".png";
    troutImageArray[i] = loadImage(troutFileName);
  }
  
  PImage[] salmonImageArray = new PImage[nFrames];
  for (int i=0; i<nFrames; i++)
  {
    String salmonFileName = "salmon_000";
    if (i < 10)
      salmonFileName += "0";
    salmonFileName += String.valueOf(i) + ".png";
    salmonImageArray[i] = loadImage(salmonFileName);
  }
  

  
  for (int f1=0; f1 < nFish/2; f1++)
  {
    fishArray[f1] = new Fish(troutImageArray, floor(random(width)), floor(random(height)));
  }
  
  for (int f2=nFish/2; f2 < nFish; f2++)
  {
    fishArray[f2] = new Fish(salmonImageArray, floor(random(width)), floor(random(height)));
  }
  
  
} // end setup

//====================================================================================
// Timer handler
void draw()
{
  background(190,225,225);
  
  if (mousePressed)
    ellipse(mouseX, mouseY,25,25);  // For testing only -- to be replaced with motion detection
    
  
  for (int f=0; f<nFish; f++)
    fishArray[f].Update(); //<>//
   
  for (int f=0; f<nFish; f++)
    fishArray[f].Action();
  
  // You can scare them once, then you have to go out of range before you can scare them again
  
  // Currently applying to all fish in pond, not using a distance measure
  // Would need to be able to get position data from the Kinect to do this precisely
  ArrayList<PImage> bodyTrackList = kinect.getBodyTrackUser();
  
  if (bodyTrackList.size() == 0)  //reset
  {
    someoneHere = false;
  }     
  if (!someoneHere)
  {
    if (bodyTrackList.size() > 0)
    {
      someoneHere = true;
      fishAllPanic();
    }
  }  
} // end Timer Handler

//====================================================================================
void mouseClicked()
{ 
  for (int f=0; f<nFish; f++)
  {
    Fish currentFish = fishArray[f]; //<>//
    
   // Currently running off Kinect, so applying to all fish in pond, not using a distance measure
    // Would need to be able to get position data from the Kinect to do this precisely
    //int checkPointX = currentFish.xLoc + currentFish.images[0].width;
    //int checkPointY = currentFish.yLoc + currentFish.images[0].height;
    //float distance = linearDistance(checkPointX, checkPointY, mouseX, mouseY);
    //if (distance < currentFish.panicRange)
    
     currentFish.Panic(mouseX, mouseY);
  }
} // end mouseclicked

//====================================================================================
void fishAllPanic()
{
  for (int f=0; f<SimParams.TotalNumberOfFish; f++)
  {
    // everybody head away from the center
    fishArray[f].Panic(width/2, height/2);
  }
}

//====================================================================================
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
//class declarations
//==================================================================================================

enum EFishState
{
  SWIMMING,
  PANICKING,
  RECOVERING
}
  
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
    EFishState fishState;
    
    Fish(PImage[] images, int startXLoc, int startYLoc)
    {
      this.images = images;

      xLoc = startXLoc;
      yLoc = startYLoc;
      speed = floor(random(SimParams.FishSpeed) + SimParams.MinimumFishSpeed) * -1;
      
      frameCounter = floor(random(SimParams.FramesInAnimation));    // so they aren't in lock step

      orientation = 0;
      Turn(orientation);    // sets xVel and yVel
        
       panicRange = SimParams.PanicRange;
       panicking = false;
       panicCount = 0;
       panicInterval = SimParams.PanicInterval;
       
       fishState = EFishState.SWIMMING;
    }
    
    //========================================================================
    // FSM Methods
    //========================================================================
    void Update()
    {
      switch (fishState)
      {
        case SWIMMING:
          // Fish moved out of this state asynchronously in Timer and mouseDown. Would be better here... !!!
        break;
        case PANICKING:
          if (panicCount <= 0)
            fishState = EFishState.RECOVERING;
        break;
        case RECOVERING:
          if (orientation == 0)
          {
            fishState = EFishState.SWIMMING;
            Turn(orientation);
          }
        break;
      }
    } // end FSM update
    
    void Action()
    {
      switch(fishState)
      {
        case SWIMMING:
          //Move & Draw is the default action for all states
        break;
        case PANICKING: // calm down
          panicCount--;
        break;
        case RECOVERING: // returning gradually to forward
         if (orientation < 0)
           orientation++;
           else
           orientation--;
          
         Turn(orientation);
        break;
      } // end switch
      Move();
      Draw();
    } // end FSM action
    
    //========================================================================
    // General Methods 
    //========================================================================
    
    
    void Draw()
    { 
      frameCounter = (frameCounter + 1) % images.length;
      PImage currentImage = images[frameCounter];
      
      pushMatrix();
      translate(xLoc,yLoc);
      rotate(radians(-orientation));
      image(currentImage, 0,0, currentImage.width/SimParams.ScaleFactor, currentImage.height/SimParams.ScaleFactor);
      popMatrix();
    }
    
     //========================================================================
    // Move with Wiggle and edge adjustment
    void Move()
    {
      
      xLoc += xVel;
      yLoc += yVel;
      
      // If you swim off the edge, wrap around
      if (xLoc < -images[0].width/SimParams.ScaleFactor)
      {
        xLoc = width;
      }
        
      if (xLoc > width)
      {
         xLoc = 0;
      }
        
      // Wrap around at the top
      if (yLoc <  -images[0].height/SimParams.ScaleFactor)
        yLoc = height;
        
      // Not needed since they only go up, but here for completeness
      if (yLoc > height)
        yLoc = 0;
       
      // Stochastic change in orientation
      wiggle();
    }
    
    void wiggle()
    {
      // Probabilistic wiggle, not when fleeing. Probably better to get this difference up into the FSM !!!
        if ((random(100) < SimParams.WiggleProb) && (fishState != EFishState.PANICKING))
        {
          orientation = floor(random(SimParams.WiggleIntensity));  // we want them to aim basically forward. between -WI and +WI degrees
          if (random(10) < 5)  // half left/ half right wiggles
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
    
    void Panic(int enemyX, int enemyY)  // enemyY not used in this version 3-8-17
    {
      fishState = EFishState.PANICKING;
      panicCount = panicInterval;  // The fish will panic for this many cycles
      
      if (enemyX < xLoc) // you are to the right of the mouse, so turn clockwise to flee
        orientation = -SimParams.PanicOrientation;
      else
        orientation = SimParams.PanicOrientation;
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