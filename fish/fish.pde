Fish fish1;
Fish fish2;
Fish fish3;

Fish[] fishArray;

void setup()
{
  frameRate(30);
  size(512, 521);
  stroke(155);
  fill(255,0,0);
  
  fishArray = new Fish[3];
  fishArray[0] = new Fish("westFish1.png", "eastFish1.png", 100, 100);
  fishArray[1] = new Fish("westFish2.png", "eastFish2.png", 300, 250);
  fishArray[2] = new Fish("westFish3.png", "eastFish3.png", 500, 400);
}

void draw()
{
  background(255);
  
  if (mousePressed)
    ellipse(mouseX, mouseY,25,25);
  
  for (int f=0; f<3; f++)
    fishArray[f].Draw();
   
  for (int f=0; f<3; f++)
    fishArray[f].Move();
}

void mouseClicked()
{ 
  for (int f=0; f<3; f++)
  {
    Fish currentFish = fishArray[f]; //<>//
    int checkPointX = currentFish.xLoc + currentFish.displayImage.width/16;
    int checkPointY = currentFish.yLoc + currentFish.displayImage.height/16;
  
    
    float distance = linearDistance(checkPointX, checkPointY, mouseX, mouseY);
    if (distance < 200)
     currentFish.Flip();
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



  //class declaration
  
  class Fish
  {
    int xLoc;
    int yLoc;
    PImage displayImage;
    PImage westImage;
    PImage eastImage;
    int xVel;
    int yVel;
    
    Fish(String westImageName, String eastImageName, int startXLoc, int startYLoc)
    {
      displayImage = new PImage();
      westImage = new PImage();
      eastImage = new PImage();
      westImage = loadImage(westImageName);
      eastImage = loadImage(eastImageName);
      displayImage = westImage;
      xLoc = startXLoc;
      yLoc = startYLoc;
      xVel = floor(random(4) + 1) * -1;
      yVel = 0;
      
      //if (random(1) == 0)
      //  xVel *= -1;
    }
    
    void Draw()
    {
      image(displayImage, xLoc, yLoc, displayImage.width/16, displayImage.height/16);
    }
    
    void Move()
    {
      xLoc += xVel;
      yLoc += yVel;
      
      if (xLoc < -displayImage.width/16)
        xLoc = width;
        
      if (xLoc > width)
      xLoc = -displayImage.width/16;
    }
    
    void Flip()
    {
      if (xVel < 0)  // you are currently heading west; change your image to east
        displayImage = eastImage;
      else
        displayImage = westImage;
        
      xVel *= -1;
    }
    
    
    
  } // end class Fish