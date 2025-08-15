class Credenziali{
    String code;
    String pass;

    Credenziali({
      required this.code,
      required this.pass,
    });

    factory Credenziali.fromList(List<String> save){
      if(save.isEmpty) {
        return Credenziali(
          code: "",
          pass: "",
        );
      }
      return Credenziali(
        code: save[0],
        pass: save[1],
      );

    }

}