class LoginResponse{
  String codiceStudente;
  String nome;
  String cognome;
  String token;

  LoginResponse({
   required this.codiceStudente,
   required this.nome,
   required this.cognome,
   required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json){
    return LoginResponse(
      codiceStudente: json['ident'],
      nome: json['firstName'],
      cognome: json['lastName'],
      token: json['token'],
    );
  }
}