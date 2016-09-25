/*
 * Simple turn-based game controller.
 * 
 * - 2 Players, represented by boolean flag
 * - Timer for random events like wind
 * - Score tracker
 */
class Game {
  
  private boolean p1turn = true;
  int xStart = 0, yStart = 0, xEnd, yEnd, GROUND_LEVEL = 300, PLAYER_WIDTH = 200, BLOCK_NO = 10, BLOCK_HEIGHT = 10, colWidth, p1score = 0, p2score = 0;
  long time;
  
  ForceRegistry forceReg;
  Wind wind;
  Gravity gravity;
  Particle p;  
  Particle[][] blocks;
  
  Game() {
    GROUND_LEVEL = Engine.GROUND_LEVEL; // Load in ground level from main class.
    
    // Create the columns of particles for ground blocks.
    colWidth = (width - PLAYER_WIDTH*2) / BLOCK_NO; //10 Columns for blocks.
  
    // Create force registry
    forceReg = new ForceRegistry();
  
    // Create forces.
    gravity = new Gravity(new PVector(0f, 0.1f));
    wind = new Wind(new PVector(random(-.003f, .003f), 0f));
    
    // Set timeout until wind change.
    time = setTimeout();
  }
  
  void tick() {
    forceReg.updateForces(); // Update forces in all registered particles
    if(System.currentTimeMillis()/1000 > time) {
      time = setTimeout();
      wind.randomWind();
    }
    
  }
  
  void render() {
    fill(0);
    text("P1 Score: "+p1score, 20, 20);
    text("P2 Score: "+p2score, width-100, 20);
    text("Wind: "+wind, width/2-50, 20);
    int player = p1turn ? 1 : 2;
    text("Player "+player+"'s turn!", width/2-40, 40);
  
    //drawBlocks();
    
    stroke(0);
    if (mousePressed) line(xStart, yStart, mouseX, mouseY) ;
    if(p != null) {
      p.integrate();
      PVector pos = p.position;
      stroke(255);
      fill(0);
      rect(pos.x, pos.y, 5,5);
    }
  }
  
  long setTimeout() {
    return (System.currentTimeMillis()/1000)+int(random(0, 7));
  }
  
  // When mouse is pressed, store x, y coords
  void mousePressed(int x, int y) {
    xStart = x ;
    yStart = y ;
  }

  // When mouse is released create new vector relative to stored x, y coords
  void mouseReleased(int x, int y) {
    xEnd = x ;
    yEnd = y ;
    p = new Particle(xStart,yStart,(xEnd - xStart)/12, (yEnd - yStart)/12, 0.04f) ; // Create Particle.
    forceReg.add(gravity, p);
    forceReg.add(wind, p);
  }
  
}