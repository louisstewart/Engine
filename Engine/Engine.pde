static int GROUND_LEVEL = 300;
PImage texture, grass;
Game game;

// Specify canvas size, initialise PVector variables
void setup() {
  size(900, 400, P2D) ;
  
  // Load in floor texture.
  texture = loadImage("texture.png"); // http://opengameart.org/content/lots-of-free-2d-tiles-and-sprites-by-hyptosis
  grass = loadImage("grass.png"); 
  textureMode(NORMAL);
  textureWrap(REPEAT);
  
  game = new Game();
  
  //forceReg.add(wind, p);
  //forceReg.add(gravity, p);
  //forceReg.add(user, p);
  
  /*blocks = new Particle[BLOCK_NO][];
  for(int i = 0; i < blocks.length; i++) {
    int r = random(0,10)+1;
    blocks[i] = new Particle[r];
    for(int j = 0; j < r; j++) {
      Particle p = new Particle(PLAYER_WIDTH+i*colWidth, GROUND_LEVEL-(j+1)*10, 0, 0, 0); // Infinite mass
      blocks[i][j] = p;
      forceReg.add(gravity, p); 
    }
  }*/
}

// clear background, render object and textual desc
void draw() {
  background(173,216,230); // Sky.
  ground(); // Render the ground texture
  game.tick();
  game.render();
}

void mousePressed() {
  game.mousePressed(mouseX, mouseY);
}

void mouseReleased() {
  game.mouseReleased(mouseX, mouseY);
}

void ground() {
  noStroke();
  beginShape();
  texture(texture);
  vertex(0, height, 0, 0);
  vertex(width, height, 15, 0);
  vertex(width, GROUND_LEVEL, 15, 4);
  vertex(0, GROUND_LEVEL, 0, 4);
  endShape();
  beginShape();
  texture(grass);
  vertex(0, GROUND_LEVEL+10, 0, 0);
  vertex(width, GROUND_LEVEL+10, 15, 0);
  vertex(width, GROUND_LEVEL, 15, 1);
  vertex(0, GROUND_LEVEL, 0, 1);
  endShape();
  
}

/*void drawBlocks() {
  for(int i = 0; i < blocks.length; i++) {
    for(int j = 0; j < blocks[i].length; j++) {
      blocks[i][j].integrate();
      stroke(255);
      fill(0);
      rect(blocks[i][j].position.x,blocks[i][j].position.y, colWidth, BLOCK_HEIGHT);
    }
  }
}*/