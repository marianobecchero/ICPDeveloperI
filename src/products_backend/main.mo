import Text "mo:base/Text";
import Int "mo:base/Int";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Error "mo:base/Error";

actor {

  //Definición de variables
  type Username = Text;
  type Password = Text;
  type Rol = Text;
  type Name = Text;
  type Stock = Int;

  let users = HashMap.HashMap<Username, Password>(0, Text.equal, Text.hash);
  let usersRoles = HashMap.HashMap<Username, Rol>(0, Text.equal, Text.hash);
  let products = HashMap.HashMap<Name, Stock>(0, Text.equal, Text.hash);
  var activeUser : Text = "";

  //Dar de alta un nuevo usuario
  public func registerUser(username: Username, password: Password) : async Text {
    let newUser : ?Text = users.get(username);

    switch (newUser) {
      case (null) {
        users.put(username, password);
        return "El usuario se registró correctamente";
      };
      case (_) {
        throw Error.reject("Ya existe el nombre de usuario");
      };
    };
  };

  //Un usuario se loguea
  public func login(username: Username, password: Password) : async Text {
    let userPassword : ?Text = users.get(username);
    if (userPassword == ?password) {
      activeUser := username;
      return "Login correcto";
    };

    throw Error.reject("Login incorrecto");
  };

  //Un usuario se desloguea
  public query func logout() : async Text {
    activeUser := "";
    return "Sesión cerrada";
  };

  //Asigna un rol al usuario logueado (seller para vendedor y customer para comprador)
  public func assignRol(rol: Text) : async Text {
    if (activeUser == "") {
      throw Error.reject("Necesita loguearse");
    };

    usersRoles.put(activeUser, rol);

    return "El rol se asignó correctamente";

  };

  //Agrega un nuevo producto (tiene que tener privilegios de seller)
  public func addProduct(name: Name) : async Text {
    if (activeUser == "") {
      throw Error.reject("Necesita loguearse");
    };

    let user : ?Text = usersRoles.get(activeUser);
    if (user == ?"seller") {
      products.put(name, 0);
      return "El producto se cargó correctamente";
    };

    throw Error.reject("No tiene privilegios para esta operación");
  };

  //Realiza la compra de un producto ya cargado (tiene que tener privilegios de seller)
  public func purchaseProduct(product: Name, quantity: Int) : async Text {
    var stockProduct : Int = 0;
    
    if (activeUser == "") {
      throw Error.reject("Necesita loguearse");
    };

    let user : ?Text = usersRoles.get(activeUser);
    if (user == ?"seller") {
      for ((name, stock) in products.entries()) {
        if (name == product) {
          stockProduct := stock + quantity;
        };
      };
      ignore products.replace(product, stockProduct); 
      return "La compra se realizó correctamente";
    };

    throw Error.reject("No tiene privilegios para esta operación");
  };

  //Realiza la venta de un producto ya cargado (tiene que tener privilegios de customer)
  public func sellProduct(product: Name, quantity: Int) : async Text {
    var stockProduct : Int = 0;
    
    if (activeUser == "") {
      throw Error.reject("Necesita loguearse");
    };

    let user : ?Text = usersRoles.get(activeUser);
    if (user == ?"customer") {
      for ((name, stock) in products.entries()) {
        if (name == product) {
          stockProduct := stock - quantity;
        };
      };
      ignore products.replace(product, stockProduct); 
      return "La venta se realizó correctamente";
    };

    throw Error.reject("No tiene privilegios para esta operación");
  };

  //Visualiza todos los productos (no hace falta loguearse)
  public query func getAllProducts() : async [(Name, Stock)] {
    return Iter.toArray<(Name, Stock)>(products.entries());
  };

  //Visualiza el stock de un producto (no hace falta loguearse)
  public query func getStock(name: Name) : async ?Stock {
    return products.get(name);
  };

  //Elimina un producto (tiene que tener privilegios de seller)
  public func removeProduct(product: Name) : async Text {
    if (activeUser == "") {
      throw Error.reject("Necesita loguearse");
    };

    let user : ?Text = usersRoles.get(activeUser);
    if (user == ?"seller") {
      ignore products.remove(product);
      return "El producto se eliminó correctamente";
    };

    throw Error.reject("No tiene privilegios para esta operación");
  };

};
