class Particle {
  
  PVector position, velocity, forceAccum; // Use a force accumulator to simplfy multiple forces.
  private float DAMPING = 0.997f;
  
  float invMass; // Store inverse mass to ease calculations and allow infinite mass.
  
  public float getInvMass() {
    return invMass;
  }
  
  public float getMass() { // Retrieve the mass of the particle.
    return 1/invMass;
  }
  
  Particle(PVector pos, PVector vel, float inverse){
    position = pos;
    velocity = vel;
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
    PVector resAcc = forceAccum.copy(); // Get the accumulated forces
    resAcc.mult(invMass);
    
    velocity.add(resAcc);
    
    velocity.mult(DAMPING); // Hack in the drag for now
    
    if((position.x < 0) || (position.x > width)) velocity.x = -velocity.x;
    if((position.y > height)) velocity.y = -velocity.y; // We will actually do collision detect on particles with the ground, this is just a backup.
    
    // Zero the force accumulator
    forceAccum.x = 0;
    forceAccum.y = 0;
  }
  
}