class Tank extends Block {
  
  final float MAX_SPEED = 2f ;
  PImage texture;
  private float DAMPING = 0.95f;
  
  Tank(PVector pos, int w, int h, float iMass, PImage text) {
    super(pos, w, h, iMass);
    this.texture = text;
  }
  
  void integrate() {
    if(invMass <= 0f) return ; // Infinite mass object, so not affected by force.
    
    position.add(velocity); // Update position vector;
    
    // a = f * 1/m 
    PVector resAcc = forceAccum.copy(); // Get the accumulated forces
    resAcc.mult(invMass);
    
    velocity.add(resAcc);
    
    velocity.mult(DAMPING); // Hack in the drag for now
    
    if(velocity.mag() > MAX_SPEED){
      println("here");
      velocity.normalize();
      velocity.mult(MAX_SPEED);
    }
    
    if((position.x < 0) || (position.x+this.width > Engine.GAME_WIDTH)) velocity.x = -velocity.x;
    if((position.y > Engine.GAME_HEIGHT)) velocity.y = -velocity.y; // We will actually do collision detect on particles with the ground, this is just a backup.
    
    // Zero the force accumulator
    forceAccum.x = 0;
    forceAccum.y = 0;
  }
  
}
  