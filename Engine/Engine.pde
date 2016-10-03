import ddf.minim.*;

static int GROUND_LEVEL = 300;
static PImage texture, grass, block, tRight, tLeft, wall;
static int GAME_WIDTH = 1100, GAME_HEIGHT = 400;
static PFont main, sans;
Game game;
Minim minim;
static AudioPlayer fire, explode;

// Specify canvas size, initialise PVector variables
void setup() {
  size(1100, 400, P2D) ;
  
  // Sound
  minim = new Minim(this);
  fire = minim.loadFile("Explosion+1.wav");
  explode = minim.loadFile("Explosion.wav");
  // Load in floor texture.
  texture = loadImage("texture.png"); // http://opengameart.org/content/lots-of-free-2d-tiles-and-sprites-by-hyptosis
  grass = loadImage("grass.png"); // Same as above.
  block = loadImage("block.png"); // Ditto.
  tLeft = loadImage("tankleft.png"); // http://opengameart.org/content/2d-side-scrolling-tank
  tRight = loadImage("tankright.png");
  wall = loadImage("wall.png");
  main = loadFont("TannenbergFett-48.vlw");
  sans = loadFont("HelveticaNeue-48.vlw");
  textureMode(NORMAL);
  textureWrap(REPEAT);
  
  game = new Game();
  
}

// clear background, render object and textual desc
void draw() {
  background(173,216,230); // Sky.
  ground(); // Render the ground texture
  game.render();
  game.tick();
}

void keyPressed() {
  game.keyPressed();
}

void keyReleased() {
  game.keyReleased();
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