/*
 * Simple turn-based game controller.
 * 
 * - 2 Players, represented by boolean flag
 * - Timer for random events like wind
 * - Score tracker
 */
class Game {
  
  private boolean p1turn = true;
  int xStart = 0, yStart = 0, xEnd, yEnd, GROUND_LEVEL = 300, PLAYER_WIDTH = 200, BLOCK_NO = 10, BLOCK_HEIGHT = 20, blockWidth, p1score = 0, p2score = 0;
  long time, prev;
  int fr = int(frameRate);
  
  ForceRegistry forceReg;
  Wind wind;
  Gravity gravity;
  Projectile p;  
  Plane ground;
  Block[][] blocks;
  ContactResolver cr;
  ArrayList<Contact> contacts;
  
  Game() {
    GROUND_LEVEL = Engine.GROUND_LEVEL; // Load in ground level from main class.
    ground = new Plane(0, GROUND_LEVEL, width, GROUND_LEVEL);
    
    // Create the columns of particles for ground blocks.
    blockWidth = (width - PLAYER_WIDTH*2) / BLOCK_NO; //10 Columns for blocks.
  
    // Create force registry
    forceReg = new ForceRegistry();
  
    // Create forces.
    gravity = new Gravity(new PVector(0f, 0.1f));
    wind = new Wind(new PVector(random(-.003f, .003f), 0f));
    
    // Set timeout until wind change.
    time = setTimeout();
    prev = System.currentTimeMillis();
    
    cr = new ContactResolver();
    contacts = new ArrayList<Contact>();
    
    blocks = new Block[BLOCK_NO][];
    for(int i = 0; i < blocks.length; i++) {
      int r = int(random(0,7))+1;
      blocks[i] = new Block[r];
      for(int j = 0; j < r; j++) {
        Block b = new Block(new PVector(PLAYER_WIDTH+i*blockWidth, GROUND_LEVEL-((j+1)*BLOCK_HEIGHT)), blockWidth, BLOCK_HEIGHT, 0.0000001); // Finite mass so gravity works.
        blocks[i][j] = b;
        forceReg.add(gravity, b); 
      }
    }
  }
  
  void tick() {
    forceReg.updateForces(); // Update forces in all registered particles
    integrate();
    detectCollisions();
    if(System.currentTimeMillis()/1000 > time) {
      time = setTimeout();
      wind.randomWind();
    }
    cr.resolveContacts(contacts);
    contacts.clear();
  }
  
  void integrate() {
    if(p != null) p.integrate();
    for(int i = 0; i < blocks.length; i++) {
      for(int j = 0; j < blocks[i].length; j++) {
        if(blocks[i][j] != null) blocks[i][j].integrate();
      }
    }
  }
  
  void render() {
    fill(0);
    text("P1 Score: "+p1score, 20, 20);
    text("P2 Score: "+p2score, width-100, 20);
    text("Wind: "+wind, width/2-50, 20);
    int player = p1turn ? 1 : 2;
    text("Player "+player+"'s turn!", width/2-40, 40);
    if(System.currentTimeMillis()/1000 - prev/1000 > 1)  {
      prev = System.currentTimeMillis();
      fr = int(frameRate);
    }
    text(fr+"fps", width/2-20, 60);
  
    drawBlocks();
    stroke(0);
    
    if (mousePressed) line(xStart, yStart, mouseX, mouseY) ;
    PVector temp = new PVector(mouseX - xStart, mouseY - yStart);
    int angle = 0;
    int power = 0;
    if(mousePressed) {
        angle = int(-temp.heading()*180.0/PI); // Convert from rad to deg.
        power = int(temp.mag()); // Get magnitude.
      }
    if(p1turn) {
      text("Angle: "+angle, 20, 40);
      text("Power: "+power, 20, 60);
      text("Angle: "+0, width-100, 40);
      text("Power: "+0, width-100, 60);
    }
    else {
      if(mousePressed)angle = (int)(angle-90); // Fix the angle for calculating from the opposite direction.
      text("Angle: "+0, 20, 40);
      text("Power: "+0, 20, 60);
      text("Angle: "+angle, width-100, 40);
      text("Power: "+power, width-100, 60);
    }
    
    if(p != null) {
      stroke(255);
      fill(0);
      ellipse(p.position.x, p.position.y, p.radius, p.radius);
    }
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
    p = new Projectile(new PVector(xStart,yStart),new PVector((xEnd - xStart)/12, (yEnd - yStart)/12), 0.4f, 5) ; // Create Particle.
    forceReg.add(gravity, p);
    forceReg.add(wind, p);
  }
  
  private long setTimeout() {
    return (System.currentTimeMillis()/1000)+int(random(0, 7));
  }
  
  private void detectCollisions() {
    if(p != null) {
      // Check for collision with the ground first, as this is fairly easy.
      PVector c = new PVector(p.position.x - ground.x1, p.position.y - ground.y1);
      int collisionDistance = ground.projectOntoNormal(c);
      if(abs(collisionDistance) <= p.radius/2) {
        forceReg.remove(wind, p);
        forceReg.remove(gravity, p);
        p = null;
        endTurn();
      }
    } 
    /*
     * Now collision detection between blocks
     * Only bother with collisions downward, not concerned about block touching neighbour to left/right
     */
    for(int i = 0; i < blocks.length; i++) {
      for(int j = 0; j < blocks[i].length; j++) {
        Block curr = blocks[i][j];
        if(j == 0) { // Deal with ground case.
          PVector c = new PVector(curr.position.x - ground.x1, curr.position.y - ground.y1);
          int collisionDistance = ground.projectOntoNormal(c);
          if(abs(collisionDistance) <= curr.height) {
            Contact contact = new Contact(curr, null, 0, ground.cnorm);
            contacts.add(contact);
          }
        }
        else { // Not ground collision, so collision with block below.
          Block lower = blocks[i][j-1];
          PVector dist = curr.position.copy();
          dist.sub(lower.position);
          println(dist.mag());
          println("Curr height "+curr.height);
          if(abs(dist.mag()) < curr.height) {
            Contact nc = new Contact(curr, null, 0, dist.normalize());
            contacts.add(nc);
          }
        }
      }
    }
    /*
     * Collision between projectile and blocks.
     */
     for(int i = 0; i < blocks.length; i++) {
       for(int j = 0; j < blocks[i].length; j++) {
         
       }
     }
         
  }
  
  void endTurn() {
    p1turn = !p1turn;
  } 
  
  private void drawBlocks() {
    for(int i = 0; i < blocks.length; i++) {
      for(int j = 0; j < blocks[i].length; j++) {
        Block temp = blocks[i][j];
        if(temp != null) {
          //stroke(255);
          /*fill(0);
          rect(temp.position.x,temp.position.y, temp.width, temp.height);*/
          beginShape();
          texture(Engine.block);
          vertex(temp.position.x, temp.position.y+temp.height, 0, 0);
          vertex(temp.position.x+temp.width, temp.position.y+temp.height, 1, 0);
          vertex(temp.position.x+temp.width, temp.position.y, 1, 1);
          vertex(temp.position.x, temp.position.y, 0, 1);
          endShape();
        }
      }
    }
  }
  
}