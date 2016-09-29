public class Contact {
  // The two particles in contact
  Particle p1;
  Particle p2;
  
  // Coefficient of restitution - how much elasticity is there in the collision.
  float c;
  
  // The direction of the contact (from p1's perspective)
  // Equivalent to normal of {p1} - {p2}
  PVector contactNormal;
  
  // Construct a new Contact from the given parameters
  public Contact (Particle p1, Particle p2, float c, PVector contactNormal) {
    this.p1 = p1;
    this.p2 = p2;
    this.c = c;
    this.contactNormal = contactNormal; 
  }
  
  // Resolve this contact for velocity
  void resolve () {
    resolveVelocity(); //<>//
  }
  
  // Calculate the separating velocity for this contact
  // This is just the simplified form of the closing velocity eqn
  float calculateSeparatingVelocity() {
    PVector relativeVelocity = p1.velocity.get(); //<>//
    if(p2 != null) relativeVelocity.sub(p2.velocity);
    return relativeVelocity.dot(contactNormal);
  }
  
  // Handle the impulse calculations for this collision
  void resolveVelocity()  {
    //Find the velocity in the direction of the contact
    float separatingVelocity = calculateSeparatingVelocity(); //<>//
        
    // Calculate new separating velocity
    float newSepVelocity = -separatingVelocity * c;
    
    // Now calculate the change required to achieve it
    float deltaVelocity = newSepVelocity - separatingVelocity;
    
    // Apply change in velocity to each object in proportion inverse mass.
    // i.e. lower inverse mass (higher actual mass) means less change to vel.
    float totalInverseMass = p1.invMass;
    if(p2 != null) totalInverseMass += p2.invMass; // In case collision is with scenery.
    
    if(totalInverseMass <= 0) return; // Both infinite mass, so return.
    
    // Calculate impulse to apply
    float impulse = deltaVelocity / totalInverseMass;
        
    // Find the amount of impulse per unit of inverse mass
    PVector impulsePerIMass = contactNormal.get();
    impulsePerIMass.mult(impulse);
    
    // Calculate the p1 impulse
    PVector p1Impulse = impulsePerIMass.get();
    if(p1.invMass > 0) p1Impulse.mult(p1.invMass);
    p1.velocity.add(p1Impulse);
    
    // Calculate the p2 impulse
    // NB Negate this one because it is in the opposite direction 
    if(p2 != null) {
      PVector p2Impulse = impulsePerIMass.get();
      if(p2.invMass > 0) p2Impulse.mult(-p2.invMass);
      p2.velocity.add(p2Impulse);
    }
   
  }
}