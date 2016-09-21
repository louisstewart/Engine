class Particle {
  
  private PVector position, velocity, forceAccum; // Use a force accumulator to simplfy multiple forces.
  private float DAMPING = 0.995f;
  
  float invMass; // Store inverse mass to ease calculations and allow infinite mass.
  
  public float getInvMass() {
    return invMass;
  }
  
  public float getMass() { // Retrieve the mass of the particle.
    return 1/invMass;
  }
  
  Particle(int x, int y, float xVel, float yVel, float inverse){
    position = new PVector(x,y);
    velocity = new PVector(xVel, yVel);
    forceAccum = new PVector(0f,0f);
    invMass = inverse;  
  }
  
  void addForce(PVector force) {
    forceAccum.add(force); 
  }
  
  void integrate() {
    if(invMass <= 0f) return ; // Infinite mass object, so not affected by force.
    
    position.add(velocity); // Update position vector;
    
    // a = f * 1/m 
    PVector resAcc = forceAccum.get(); // Get the accumulated forces
    resAcc.mult(invMass);
    
    velocity.add(resAcc);
    
    velocity.mult(DAMPING); // Hack in the drag for now
    
    if((position.x < 0) || (position.x > width)) velocity.x = -velocity.x;
    if((position.y < 0) ||  (position.y > GROUND_LEVEL)) velocity.y = -velocity.y;
    
    // Zero the force accumulator
    forceAccum.x = 0;
    forceAccum.y = 0;
  }
  
}