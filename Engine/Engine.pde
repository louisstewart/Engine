int xStart, yStart, xEnd, yEnd, GROUND_LEVEL = 300 ;
UserForce user;
Particle p;
ForceRegistry forceReg;
PImage texture;

// Specify canvas size, initialise PVector variables
void setup() {
  size(900, 400, P2D) ;
  texture = loadImage("texture.png"); // http://opengameart.org/content/lots-of-free-2d-tiles-and-sprites-by-hyptosis
  textureMode(NORMAL);
  textureWrap(REPEAT);
  
  p = new Particle(150,150,random(0f,.5f),random(0f,.5f),random(0.001f,0.005f)) ; // Create Particle.
  
  // Create force registry
  forceReg = new ForceRegistry();
  
  // Create forces.
  Gravity gravity = new Gravity(new PVector(0f, 0.1f));
  user = new UserForce(new PVector(0f,0f));
  
  forceReg.add(gravity, p);
  forceReg.add(user, p);
}

void ground() {
  beginShape();
  texture(texture);
  vertex(0, height, 0, 0);
  vertex(width, height, 15, 0);
  vertex(width, GROUND_LEVEL, 15, 4);
  vertex(0, GROUND_LEVEL, 0, 4);
  endShape();
  stroke(124, 252, 0);
  fill(124, 252, 0);
  rect(0,GROUND_LEVEL, width, 5);
}

// clear background, render object and textual desc
void draw() {
  background(173,216,230); // Sky.
  ground(); // Render the ground texture
  
  forceReg.updateForces();
  
  stroke(0);
  if (mousePressed) line(xStart, yStart, mouseX, mouseY) ;
  p.integrate();
  PVector pos = p.position;
  stroke(255);
  fill(0);
  rect(pos.x, pos.y, 5,5);
    
}

// When mouse is pressed, store x, y coords
void mousePressed() {
  xStart = mouseX ;
  yStart = mouseY ;
}

// When mouse is released create new vector relative to stored x, y coords
void mouseReleased() {
  xEnd = mouseX ;
  yEnd = mouseY ;
  user.set((xEnd - xStart), (yEnd - yStart)) ;
}