/*
 * Simple turn-based game controller.
 * 
 * - 2 Players, represented by boolean flag
 * - Timer for random events like wind
 * - Score tracker
 */
class Game {
  
  private boolean p1turn = true, hit = false, gameOver = false, gameStart = false, fired = false;
  int xStart = 0, yStart = 0, xEnd, yEnd, GROUND_LEVEL = 300, PLAYER_WIDTH = 250, BLOCK_NO = 10, MAX_BLOCKS = 10, BLOCK_HEIGHT = 20, blockWidth, p1score = 0, p2score = 0;
  long time, prev, hitScreenEnd;
  int fr = int(frameRate);
  
  Tank p1;
  Tank p2;
  
  ForceRegistry forceReg;
  
  UserForce p1f, p2f;
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
    
    // Create the players.
    p1 = new Tank(new PVector(10, GROUND_LEVEL-50), 100, 50, 0.00001, Engine.tRight);
    p2 = new Tank(new PVector(width-110, GROUND_LEVEL-50), 100, 50, 0.00001, Engine.tLeft);
    p1f = new UserForce(new PVector(0f,0f));
    p2f = new UserForce(new PVector(0f,0f));
    forceReg.add(p1f, p1);
    forceReg.add(p2f, p2);
   
    // Generate the terrain randomly.
    blocks = new Block[BLOCK_NO][];
    for(int i = 0; i < blocks.length; i++) {
      int r = int(random(0,MAX_BLOCKS))+1;
      blocks[i] = new Block[r];
      for(int j = 0; j < r; j++) {
        Block b = new Block(new PVector(PLAYER_WIDTH+i*blockWidth, GROUND_LEVEL-((j+1)*BLOCK_HEIGHT)), blockWidth, BLOCK_HEIGHT, 0.0000001); // Finite mass so gravity works.
        blocks[i][j] = b;
        forceReg.add(gravity, b); 
      }
    }
  }
  
  void tick() {
    if(p1score == 10 || p2score == 10) {
      gameOver = true;
    }
    if(!gameOver && gameStart) {
      forceReg.updateForces(); // Update forces in all registered particles
      integrate(); // Apply forces.
      detectCollisions(); // No guessing what this does.
      if(System.currentTimeMillis()/1000 > time) { // Apply some random wind at a random time.
        time = setTimeout();
        wind.randomWind();
      }
      cr.resolveContacts(contacts); // Resolve the contacts.
      contacts.clear();
    }
  }
  
  /*
   * Apply the forces to all of the active particles in the game.
   *
   * Instead of just blindly calling integrate on the particles that are known,
   * could instead create a list of particles that are active on the field, and then
   * loop over list and call update on each node. However, since we know full game state,
   * this is simpler.
   */
  void integrate() {
    if(p != null) p.integrate();
    for(int i = 0; i < blocks.length; i++) {
      for(int j = 0; j < blocks[i].length; j++) {
        if(blocks[i][j] != null) blocks[i][j].integrate();
      }
    }
    if(p1 != null) p1.integrate();
    if(p2 != null) p2.integrate();
  }
  
  /*
   * Update the graphics.
   */
  void render() {
    if(!gameStart) {
      drawMainScreen();
    }
    else if(gameOver) {
      drawGameOver();
    }
    else if(hit) {
      drawHitScreen();
    }
    else {
      textFont(Engine.sans, 16);
      textAlign(LEFT, CENTER);
      fill(0);
      text("P1 Score: "+p1score, 20, 20);
      text("P2 Score: "+p2score, width-100, 20);
      text("Wind: "+wind, width/2-50, 20);
      text("Player "+(p1turn ? 1 : 2)+"'s turn!", width/2-40, 40);
    
      if(System.currentTimeMillis()/1000 - prev/1000 > 1)  {
        prev = System.currentTimeMillis();
        fr = int(frameRate);
      }
      text(fr+"fps", width/2-20, 60);
  
      drawBlocks();
      drawTanks();

      stroke(0);    
      if (mousePressed && !fired) line(xStart, yStart, mouseX, mouseY);
      PVector temp = new PVector((mouseX - xStart), (mouseY - yStart));
      int angle = 0;
      int power = 0;
      if(mousePressed && !fired) {
        angle = int(-temp.heading()*180.0/PI); // Convert from rad to deg.
        power = int(temp.mag()); // Get magnitude.
        if(power > 150) power = 150;
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
  }
  
  void keyPressed() {
    if(key == CODED) {
      if(keyCode == LEFT) {
        if(p1turn) p1f.set(-5000f);
        else p2f.set(-5000f);
      }
      else if(keyCode == RIGHT) {
        if(p1turn) p1f.set(5000f);
        else p2f.set(5000f);
      }
    }
    else if(key == ENTER || key == RETURN) {
      gameStart = true;
    }
  }
  
  void keyReleased() {
    p2f.set(0);
    p1f.set(0);
  }
  
  // When mouse is pressed, store x, y coords
  void mousePressed(int x, int y) {
    if(!fired) {
      if(p1turn) {
        xStart = int(p1.position.x+p1.width);
        yStart = int(p1.position.y-1);
      }
      else {
        xStart = int(p2.position.x);
        yStart = int(p2.position.y-1);
      }    
    }
  }

  // When mouse is released create new vector relative to stored x, y coords
  void mouseReleased(int x, int y) {
    if(!fired && !hit) {
      xEnd = x ;
      yEnd = y ;
      PVector power = new PVector((xEnd - xStart), (yEnd - yStart));
      if(power.mag() > 12) {
        power.normalize();
        power.mult(12);
      }
      p = new Projectile(new PVector(xStart,yStart), power, 0.3f, 5) ; // Create Particle.
      forceReg.add(gravity, p);
      forceReg.add(wind, p);
      fired = true;
      Engine.fire.rewind();
      Engine.fire.play();
    }
  }
  
  private long setTimeout() {
    return (System.currentTimeMillis()/1000)+int(random(0, 7));
  }
  
  private void detectCollisions() {
    boolean destroyed = false;
    if(p != null) {
      // Walls.
      if(p.position.x > width || p.position.x < 0) {
        forceReg.remove(wind, p);
        forceReg.remove(gravity, p);
        p = null;
        endTurn(false);
        destroyed = true;
      } 
    } 
    if(p != null) {
      // Check for collision with the ground first, as this is fairly easy.
      PVector c = new PVector(p.position.x - ground.x1, p.position.y - ground.y1);
      int collisionDistance = ground.projectOntoNormal(c);
      if(abs(collisionDistance) <= p.radius) {
        forceReg.remove(wind, p);
        forceReg.remove(gravity, p);
        p = null;
        endTurn(false);
        destroyed = true;
      } 
    } 
    /*
     * Projectile and tank collision, very similar to method used for projectile and block.
     */
    if(p != null) {
      // Try P1 tank first.
      float xp = p.position.x;
      float yp = p.position.y;
      int cx = (int)clamp(xp, p1.position.x, p1.position.x+p1.width);
      int cy = (int)clamp(yp, p1.position.y, p1.position.y+p1.height);
      PVector collision = new PVector(xp - cx, yp - cy);
      if(collision.mag() <= p.radius) {
        // Contact is made. So remove projectile and block, then shift blocks left down in the array.
        forceReg.remove(wind, p);
        forceReg.remove(gravity, p);
        p = null;
        p2score++; // Give PLAYER 2 a point even if P1 hit self.
        endTurn(true);
        return;
      }
      // Now try P2 Tank.
      cx = (int)clamp(xp, p2.position.x, p2.position.x+p2.width);
      cy = (int)clamp(yp, p2.position.y, p2.position.y+p2.height);
      collision = new PVector(xp - cx, yp - cy);
      if(collision.mag() <= p.radius) {
        // Contact is made. So remove projectile and block, then shift blocks left down in the array.
        forceReg.remove(wind, p);
        forceReg.remove(gravity, p);
        p = null;
        p1score++; // Give PLAYER 1 a point even if P2 hit self.
        endTurn(true);
        return;
      }
    }
    if(p != null) {
      /*
       * Collision between projectile and blocks.
       */
       if(!destroyed) {
         if(p1turn) { // Loop forward across block columns as p1 has x value close to 0.
           for(int i = 0; i < blocks.length; i++) {
             if(detectInColumn(blocks[i])) break; 
           }
         }
         else {
           for(int i = blocks.length-1; i >= 0; i--) {
             if(detectInColumn(blocks[i])) break;
           }
         }
       } 
    }
    /*
     * Now collision detection between blocks
     * Only bother with collisions downward, not concerned about block touching neighbour to left/right
     */
    for(int i = 0; i < blocks.length; i++) {
      if(blocks[i][0] == null)  continue;
      for(int j = 0; j < blocks[i].length; j++) {
        Block curr = blocks[i][j];
        if(curr == null) break;
        if(j < 1) { // Deal with ground case.
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
          if(abs(dist.mag()) < curr.height) {
            Contact nc = new Contact(curr, null, 0, dist.normalize());
            contacts.add(nc);
          }
        }
      }
    }
    /*
     * Tank and wall collisions.
     */
     if(p1turn && p1 != null) {
       for(int i = 0 ; i < blocks.length; i++) {
         Block temp = blocks[i][0];
         if(temp == null) continue;
         PVector dist = new PVector(temp.position.x - p1.position.x, 0);
         if(dist.mag() <= p1.width) {
           Contact cn = new Contact(p1, null, 1, dist.normalize());
           contacts.add(cn);
           break;
         }
       }
     }
     else if(p2 != null){
       for(int i = blocks.length-1 ; i > 0; i--) {
         Block temp = blocks[i][0];
         if(temp == null) continue;
         PVector dist = new PVector(temp.position.x - p2.position.x, 0);
         if(dist.mag() <= temp.width) { // Tank particle is top left of tank, and block is also top left, so need to check box width this time.
           Contact cn = new Contact(p2, null, 1, dist.normalize());
           contacts.add(cn);
           break;
         }
       }
     }
     /*
      * Tank and tank.
      */
      if(p1 != null && p2 != null) {
        PVector dist = new PVector(p2.position.x - p1.position.x, p2.position.y - p1.position.y);
        if(dist.mag() <= p1.width) {
          Contact cn = new Contact(p1, p2, 1, dist.normalize());
          contacts.add(cn);
        }
      }
  }
  
  void endTurn(boolean hit) {
    Engine.explode.rewind();
    Engine.explode.play();
    
    hitScreenEnd = System.currentTimeMillis()+3000;
    this.hit = hit;
    if(hit) {
      // Reset locations of tanks.
      p1.position.x = 10; // Could use static final int variables, but this is fine.
      p2.position.x = width-110;
    }
    p1turn = !p1turn;
    fired = false;
  } 
  
  /*
   * Private method to detect collision between projectile and 
   * a column of blocks.
   *
   */
  private boolean detectInColumn(Block[] column) {
    int xp = (int)p.position.x;
    int yp = (int)p.position.y;
    for(int j = 0; j < column.length; j++) {
      Block temp = column[j];
      // Check if blocks exist in column.
      if(temp != null) {
        // If so then check that the particle is inside the box bounded by the blocks co-ordinates.
        // Find the closest point between projectile center and rectangle
        int cx = (int)clamp(xp, temp.position.x, temp.position.x+temp.width);
        int cy = (int)clamp(yp, temp.position.y, temp.position.y+temp.height);
        PVector collision = new PVector(xp - cx, yp - cy);
        if(collision.mag() <= p.radius) {
          // Contact is made. So remove projectile and block, then shift blocks left down in the array.
          forceReg.remove(wind, p); //<>//
          forceReg.remove(gravity, p);
          p = null;
          forceReg.remove(gravity, temp);
          column[j] = null;
          shift(column, j);
          endTurn(false);
          return true;
        }
      }
    }
    return false;
  }
  
  /* 
   * Clamp a vlue to within the range min..max.
   */
  private float clamp(float val, float min, float max) {
    if(val < min) {
      return min;
    }
    else if(val > max) {
      return max;
    }
    return val;
  }
  
  /*
   * Shift values down an array and fill the empty space with null.
   */
  private void shift(Block[] shifty, int index) {
    if(index >= shifty.length) return;
    else {
      for(int next = index+1; next < shifty.length; next++) {
        shifty[index++] = shifty[next];
        shifty[next] = null;
      }
    }
  }
  
  private void drawMainScreen() {
    drawWallTexture();
    fill(255);
    textFont(Engine.main, 100);
    textAlign(CENTER, BOTTOM);
    text("Tankie", int(width/2)-1, int(height/2)); 
    text("Tankie", int(width/2), int(height/2)-1); 
    text("Tankie", int(width/2)+1, int(height/2)); 
    text("Tankie", int(width/2), int(height/2)+1); 
    fill(0);
    text("Tankie", width/2, height/2);
    fill(255);
    textFont(Engine.sans, 20);
    textAlign(LEFT, TOP);
    text("Move:", 200, height/2+50); 
    text("Left & Right Keys", 200, height/2+75);
    textAlign(CENTER, TOP);
    text("Play:", width/2, height/2+50);
    text("Press Enter", width/2, height/2+75);
    textAlign(RIGHT, TOP);
    text("Aim:", 900, height/2+50);
    text("Draw Vector", 900, height/2+75);
  }
  
  private void drawGameOver() {
    drawWallTexture();
    fill(255);
    textFont(Engine.main, 100);
    textAlign(CENTER, BOTTOM);
    text("GAME OVER!", int(width/2)-1, int(height/2)); 
    text("GAME OVER!", int(width/2), int(height/2)-1); 
    text("GAME OVER!", int(width/2)+1, int(height/2)); 
    text("GAME OVER!", int(width/2), int(height/2)+1); 
    fill(0);
    text("GAME OVER!", width/2, height/2);
    // If it's now player 1's turn, then p2 scored.
    String player = p1score == 10 ? "Player 1 Wins" : "Player 2 Wins";
    textSize(50);
    fill(255);
    text(player, int(width/2)-1, int(height/2)+100); 
    text(player, int(width/2), int(height/2)+99); 
    text(player, int(width/2)+1, int(height/2)+100); 
    text(player, int(width/2), int(height/2)+101); 
    fill(0);
    text(player, width/2, height/2+100);
  }
  
  private void drawBlocks() {
    for(int i = 0; i < blocks.length; i++) {
      for(int j = 0; j < blocks[i].length; j++) {
        Block temp = blocks[i][j];
        if(temp != null) {
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
  
  private void drawWallTexture() {
    beginShape();
    texture(Engine.wall);
    vertex(0, 0, 0, 0);
    vertex(width, 0, 2, 0);
    vertex(width, height, 2, 1);
    vertex(0, height, 0, 1);
    endShape();
  }
  
  private void drawTanks() {
    // p1 first.
    if(p1 != null) {
      beginShape();
      texture(p1.texture);
      vertex(p1.position.x, p1.position.y, 0, 0);
      vertex(p1.position.x+p1.width, p1.position.y, 1, 0);
      vertex(p1.position.x+p1.width, p1.position.y+p1.height, 1, 1);
      vertex(p1.position.x, p1.position.y+p1.height, 0, 1);
      endShape();
    }
    // p2.
    if(p2 != null){
      beginShape();
      texture(p2.texture);
      vertex(p2.position.x, p2.position.y, 0, 0);
      vertex(p2.position.x+p2.width, p2.position.y, 1, 0);
      vertex(p2.position.x+p2.width, p2.position.y+p2.height, 1, 1);
      vertex(p2.position.x, p2.position.y+p2.height, 0, 1);
      endShape();
    }
  }
  
  private void drawHitScreen() {
    if(System.currentTimeMillis() >= hitScreenEnd) {
      hit = false;
      return;
    }
    drawWallTexture();
    fill(255);
    textFont(Engine.main, 100);
    textAlign(CENTER, BOTTOM);
    text("HIT!", int(width/2)-1, int(height/2)); 
    text("HIT!", int(width/2), int(height/2)-1); 
    text("HIT!", int(width/2)+1, int(height/2)); 
    text("HIT!", int(width/2), int(height/2)+1); 
    fill(0);
    text("HIT!", width/2, height/2);
    // If it's now player 1's turn, then p2 scored.
    String player = p1turn ? "Player 2 Scored" : "Player 1 Scored";
    textSize(50);
    fill(255);
    text(player, int(width/2)-1, int(height/2)+100); 
    text(player, int(width/2), int(height/2)+99); 
    text(player, int(width/2)+1, int(height/2)+100); 
    text(player, int(width/2), int(height/2)+101); 
    fill(0);
    text(player, width/2, height/2+100);
  }
}