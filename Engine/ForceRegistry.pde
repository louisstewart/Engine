import java.util.Iterator;
import java.util.Map;

class ForceRegistry {
  
  /*
   * Store registrations in a hashmap for access speed.
   * Map is indexed by force generator and valye is a list of particles to act upon.
   */
  private HashMap<ForceGenerator, ArrayList<Particle>> registrations = new HashMap<ForceGenerator, ArrayList<Particle>>();
  
  /*
   * To register a force with a particle, we must first check that the force generator exists 
   * within the registry, if it does, add the praticle to the list of particles which the force
   * generator acts upon.
   */
  void add(ForceGenerator fg, Particle p) {
    if(!registrations.containsKey(fg)) { //<>//
      ArrayList<Particle> n = new ArrayList<Particle>(); //<>//
      n.add(p); // Add in the first particle which is acted upon by the force in fg.
      registrations.put(fg, n);
    }
    else { // Found the force already, so add particle to list
      registrations.get(fg).add(p); //<>//
    }
  }
  
  /*
   * Clear all registrations from the registry.
   */
  void clear() {
    registrations.clear();
  }
  
  /*
   * Remove a particle-force registration.
   */
   boolean remove(ForceGenerator fg, Particle p) {
     if(!registrations.containsKey(fg)) return true;
     else {
       return registrations.get(fg).remove(p);
     }
   }
   
   /*
    * Update forces on all particles for each force generator.
    */
   void updateForces() {
     for(Map.Entry<ForceGenerator, ArrayList<Particle>> ent: registrations.entrySet()) {
       ForceGenerator fg = ent.getKey();
       ArrayList<Particle> n = ent.getValue();
       for(Particle p: n) {
           fg.updateForce(p);
       }
     }
   }
}