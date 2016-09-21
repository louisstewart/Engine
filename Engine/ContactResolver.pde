import java.util.Iterator ;

class ContactResolver {
 
  // Resolves a set of particle contacts
  void resolveContacts(ArrayList contacts) {
    Iterator itr = contacts.iterator() ;
    while(itr.hasNext()) {
      Contact contact = (Contact)itr.next() ;
      contact.resolve() ;
    } 
  }
}