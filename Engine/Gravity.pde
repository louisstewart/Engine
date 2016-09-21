class Gravity extends ForceGenerator {
  
  private PVector g; // Gravity vector. 
  
  Gravity(PVector grav) {
    g = grav;
  }
  
  void updateForce(Particle p) {
    // Check for infinite mass, if so don't apply force.
    if(p.getInvMass() <= 0f) return;
    
    // f = ma, so use getMass function to multiply g by mass.
    PVector resF = g.get();
    resF.mult(p.getMass());
    p.addForce(resF); // Update p's forces.
  }
}