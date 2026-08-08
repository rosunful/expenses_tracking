

// ignore_for_file: avoid_print

class Singleton {

  //this is the constructorand we have made this a private contructor using ._ that means that the outside of the class cant access this constructor
  Singleton._();


  static Singleton? gold ;

  static Singleton fun(){
    gold ??= Singleton._();
    return gold!;
    }
    


}

void main() {
  Singleton? obj1 =Singleton.gold;
  Singleton? obj2 = Singleton.gold;

  if (obj1 == obj2) {
    print("yes they are equal");
  } else {
    print("no they are not equal");
  }
}
